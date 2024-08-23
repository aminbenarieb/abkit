import Foundation
import CoreVideo
import Accelerate
import Logging

/// https://developer.apple.com/documentation/accelerate/finding_the_sharpest_image_in_a_sequence_of_captured_images
public final class LaplacianBlurLevelExtractorAccelerate: ABVisionPipeline {
    enum LaplacianBlurLevelExtractorError: Error {
        case convolutionFilterError
        case areaStatisticsError
    }
    
    public init(){}
    
    public func process(_ context: ABVisionPipelineProcessingContext) async throws -> ABVisionPipelineProcessingContext {
        let blurLevel = try calculateBlurLevel(from: context.pixelBuffer.cvPixelBuffer)
        return context.withMetadata(.blurLevel, value: blurLevel)
    }

    private func calculateBlurLevel(from cvPixelBuffer: CVPixelBuffer) throws -> Float {
        // START
        let pixelBuffer = cvPixelBuffer
        CVPixelBufferLockBaseAddress(pixelBuffer,
                                     CVPixelBufferLockFlags.readOnly)
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let count = width * height


        let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)


        let lumaCopy = UnsafeMutableRawPointer.allocate(
            byteCount: count,
            alignment: MemoryLayout<Pixel_8>.alignment)
        lumaCopy.copyMemory(from: lumaBaseAddress!,
                            byteCount: count)
        // END
        
        // Initialize grayscale source pixel buffer
        let imageBuffer = vImage.PixelBuffer(data: lumaCopy,
                                             width: width,
                                             height: height,
                                             byteCountPerRow: lumaRowBytes,
                                             pixelFormat: vImage.Planar8.self)
        // END
        
        // START: Create floating point pixels to use with vDSP
        let buffer0 = try? vImage_Buffer(width: 10,
                                         height: 5,
                                         bitsPerPixel: 8)


        let buffer1 = vImage.PixelBuffer(width: 10,
                                         height: 5,
                                         pixelFormat: vImage.Planar8.self)
        // END
        
        var laplacianStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: width * height)
        let laplacianBuffer = vImage.PixelBuffer(data: laplacianStorage.baseAddress!,
                                                 width: width,
                                                 height: height,
                                                 byteCountPerRow: width * MemoryLayout<Float>.stride,
                                                 pixelFormat: vImage.PlanarF.self)
        defer {
            laplacianStorage.deallocate()
        }


        imageBuffer.convert(to: laplacianBuffer)
        
        // START: Perform the convolution
        let laplacian: [Float] = [-1, -1, -1,
                                  -1,  8, -1,
                                  -1, -1, -1]
        vDSP.convolve(laplacianStorage,
                      rowCount: height,
                      columnCount: width,
                      with3x3Kernel: laplacian,
                      result: &laplacianStorage)
        // END
        return laplacianBuffer.variance
    }
}

extension AccelerateMutableBuffer where Element == Float {
    var variance: Float {
        
        var mean = Float.nan
        var standardDeviation = Float.nan
        
        self.withUnsafeBufferPointer {
            vDSP_normalize($0.baseAddress!, 1,
                           nil, 1,
                           &mean, &standardDeviation,
                           vDSP_Length(self.count))
        }
        
        return standardDeviation * standardDeviation
    }
}

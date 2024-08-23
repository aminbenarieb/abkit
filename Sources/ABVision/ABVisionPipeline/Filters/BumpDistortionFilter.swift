import Foundation
import CoreVideo
import CoreImage
import CoreImage.CIFilterBuiltins
import Logging

/// https://developer.apple.com/documentation/coreimage/cifilter/4401850-bumpdistortion
public final class BumpDistortionFilter: ABVisionPipeline {
    
    public init() {}
    
    public func process(_ context: ABVisionPipelineProcessingContext) async throws -> ABVisionPipelineProcessingContext {
        return await withCheckedContinuation { continuation in
            let cvPixelBuffer = context.pixelBuffer.cvPixelBuffer
            let width = CVPixelBufferGetWidthOfPlane(cvPixelBuffer, 0)
            let height = CVPixelBufferGetHeightOfPlane(cvPixelBuffer, 0)
            
            let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
            
            let filter = CIFilter.bumpDistortion()
            filter.inputImage = ciImage
            filter.center = CGPoint(x: width/2, y: height/2)
            filter.radius = Float(min(width, height)) / 2.0
            filter.scale = 2
            guard let outputImage = filter.outputImage else {
                continuation.resume(returning: context)
                return
            }
            
            // Render the final image back to the CVPixelBuffer
            let ciContext = CIContext()
            ciContext.render(outputImage, to: cvPixelBuffer)
            
            continuation.resume(returning: context)
        }
    }
}

import Foundation
import CoreVideo
import CoreImage
import CoreImage.CIFilterBuiltins
import Logging

public final class CropProcessor: ABVisionPipeline {
    private let cropRect: CGRect
    private let logger = Logger(label: "CropProcessor")

    public init(cropRect: CGRect) {
        self.cropRect = cropRect
    }

    public func process(_ context: ABVisionPipelineProcessingContext) async throws -> ABVisionPipelineProcessingContext {
        return await withCheckedContinuation { continuation in
            // Perform the cropping
            let ciImage = CIImage(cvPixelBuffer: context.pixelBuffer.cvPixelBuffer)
            let croppedCIImage = ciImage.cropped(to: cropRect)
            let ciContext = CIContext()

            var newPixelBuffer: CVPixelBuffer?
            CVPixelBufferCreate(nil, Int(cropRect.width), Int(cropRect.height), kCVPixelFormatType_32BGRA, nil, &newPixelBuffer)

            if let newPixelBuffer = newPixelBuffer {
                ciContext.render(croppedCIImage, to: newPixelBuffer)
                continuation.resume(returning: context.withReplacedPixelBuffer(newPixelBuffer))
            } else {
                logger.error("Unable to create a buffer")
                continuation.resume(returning: context) // Fallback to original if failed
            }
        }
    }
}

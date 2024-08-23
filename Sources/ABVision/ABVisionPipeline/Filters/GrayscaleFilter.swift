import Foundation
import CoreVideo
import CoreImage
import CoreImage.CIFilterBuiltins
import Logging

public final class GrayscaleFilter: ABVisionPipeline {
    
    private let logger = Logger(label: "GrayscaleFilter")
    
    public init(){}
    
    public func process(_ context: ABVisionPipelineProcessingContext) async throws -> ABVisionPipelineProcessingContext {
        return await withCheckedContinuation { continuation in
            let cvPixelBuffer = context.pixelBuffer.cvPixelBuffer
            let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
            let grayscaleFilter = CIFilter.colorControls()
            grayscaleFilter.inputImage = ciImage
            grayscaleFilter.saturation = 0.0
            guard let grayscaleImage = grayscaleFilter.outputImage else {
                logger.error("Unable to create an output image")
                continuation.resume(returning: context)
                return
            }
            
            let ciContext = CIContext()
            ciContext.render(grayscaleImage, to: cvPixelBuffer)
            
            continuation.resume(returning: context)
        }
    }
}

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

public final class CombinedEffectFilter: ABVisionPipeline {
    
    public init() {}
    
    public func process(_ context: ABVisionPipelineProcessingContext) async throws -> ABVisionPipelineProcessingContext {
        return await withCheckedContinuation { continuation in
            let cvPixelBuffer = context.pixelBuffer.cvPixelBuffer
            let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
            
            // Step 1: Gaussian Blur
            let gaussianBlurFilter = CIFilter.gaussianBlur()
            gaussianBlurFilter.inputImage = ciImage
            gaussianBlurFilter.radius = 10.0
            guard let blurredImage = gaussianBlurFilter.outputImage else {
                continuation.resume(returning: context)
                return
            }
            
            // Step 2: Posterization
            let posterizeFilter = CIFilter.colorPosterize()
            posterizeFilter.inputImage = blurredImage
            posterizeFilter.levels = 6.0
            guard let posterizedImage = posterizeFilter.outputImage else {
                continuation.resume(returning: context)
                return
            }
            
            // Render the final image back to the CVPixelBuffer
            let ciContext = CIContext()
            ciContext.render(posterizedImage, to: cvPixelBuffer)
            
            continuation.resume(returning: context)
        }
    }
}

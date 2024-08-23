import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Logging

/// https://developer.apple.com/documentation/coreimage/cifilter/3228292-colorinvert
public final class ColorInvertFilter: ABVisionPipeline {
    
    private let logger = Logger(label: "ColorInvertFilter")
    
    public init() {}
    
    public func process(_ context: ABVisionPipelineProcessingContext) async throws -> ABVisionPipelineProcessingContext {
        return await withCheckedContinuation { continuation in
            let cvPixelBuffer = context.pixelBuffer.cvPixelBuffer
            let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
            
            let colorInvertFilter = CIFilter.colorInvert()
            colorInvertFilter.inputImage = ciImage
            guard let outputImage = colorInvertFilter.outputImage else {
                logger.error("Unable to create an output image")
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

import Foundation
import CoreVideo
import CoreImage
import CoreImage.CIFilterBuiltins
import Logging

/// https://developer.apple.com/documentation/coreimage/cifilter/4401864-droste
public final class DrosteFilter: ABVisionPipeline {
    
    public init() {}
    
    public func process(_ context: ABVisionPipelineProcessingContext) async throws -> ABVisionPipelineProcessingContext {
        return await withCheckedContinuation { continuation in
            let cvPixelBuffer = context.pixelBuffer.cvPixelBuffer
            let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
            
            let filter = CIFilter.droste()
            filter.inputImage = ciImage
            filter.insetPoint1 = CGPoint(
                x: ciImage.extent.size.width * 0.2,
                y: ciImage.extent.size.height * 0.2
            )
            filter.insetPoint0 = CGPoint(
                x: ciImage.extent.size.width * 0.8,
                y: ciImage.extent.size.height * 0.8
            )
            filter.periodicity = 1
            filter.rotation = 0
            filter.strands = 1
            filter.zoom = 1
            guard let outputImage = filter.outputImage?.cropped(to: ciImage.extent) else {
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

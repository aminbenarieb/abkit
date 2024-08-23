import Foundation
import CoreVideo

public final class ABPixelBuffer {
    public let cvPixelBuffer: CVPixelBuffer

    public init(cvPixelBuffer: CVPixelBuffer) {
        self.cvPixelBuffer = cvPixelBuffer
    }
}

public struct ABVisionPipelineProcessingContext {
    public let pixelBuffer: ABPixelBuffer
    public let metadata: [MetadataKey: Any]; public enum MetadataKey: String {
        case blurLevel
        case brightnessLevel
        case contrastLevel
    }
    
    public static func withPixelBuffer(_ cvPixelBuffer: CVPixelBuffer) -> ABVisionPipelineProcessingContext {
        ABVisionPipelineProcessingContext(pixelBuffer: .init(cvPixelBuffer: cvPixelBuffer), metadata: [:])
    }
    
    public func withMetadata(_ key: MetadataKey, value: Any) -> ABVisionPipelineProcessingContext {
         var newMetadata = metadata
         newMetadata[key] = value
         return ABVisionPipelineProcessingContext(pixelBuffer: pixelBuffer, metadata: newMetadata)
     }

    public func withReplacedPixelBuffer(_ cvPixelBuffer: CVPixelBuffer) -> ABVisionPipelineProcessingContext {
        ABVisionPipelineProcessingContext(pixelBuffer: .init(cvPixelBuffer: cvPixelBuffer), metadata: metadata)
    }
    
}

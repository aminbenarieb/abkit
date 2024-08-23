import Foundation
import CoreVideo
import Logging

public protocol ABVisionPipeline {
    
    func process(_ context: ABVisionPipelineProcessingContext) async throws -> ABVisionPipelineProcessingContext
}

public final class ABVisionPipelineDefault: ABVisionPipeline {
    private var processors: [ABVisionPipeline]

    public init(processors: [ABVisionPipeline]) {
        self.processors = processors
    }

    public func process(_ context: ABVisionPipelineProcessingContext) async throws -> ABVisionPipelineProcessingContext {
        dispatchPrecondition(condition: .notOnQueue(.main))
        var context = context
        for processor in processors {
            context = try await processor.process(context)
        }
        return context
    }
}

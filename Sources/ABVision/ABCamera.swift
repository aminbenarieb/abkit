import Foundation
import AVFoundation
import Combine

public protocol ABCamera: ObservableObject {

    var framePublisher: AnyPublisher<CVPixelBuffer?, Never> { get }
    var currentFrame: CVPixelBuffer? { get }
    
    func startStreaming() async throws
    func stopStreaming() async throws
    
    func configure() async throws
}


public class ABCameraSimulated: ABCamera {
    
    private let videoURL: URL
    private var videoPlayer: AVPlayer?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    private var subject = PassthroughSubject<CVPixelBuffer?, Never>()
    
    @Published public var currentFrame: CVPixelBuffer?
    public var framePublisher: AnyPublisher<CVPixelBuffer?, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    public init(videoURL: URL) {
        self.videoURL = videoURL
    }
    
    public func configure() async throws {
        let asset = AVAsset(url: videoURL)
        let item = AVPlayerItem(asset: asset)
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
        item.add(videoOutput!)
        videoPlayer = AVPlayer(playerItem: item)
        
        displayLink = CADisplayLink(target: self, selector: #selector(processFrame))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    public func startStreaming() async throws {
        self.framePublisher
            .receive(on: RunLoop.main)
            .assign(to: &$currentFrame)
        videoPlayer?.play()
        displayLink?.isPaused = false
    }
    
    public func stopStreaming() async throws {
        videoPlayer?.pause()
        displayLink?.isPaused = true
    }
    
    @objc private func processFrame() {
        guard let videoOutput = videoOutput else { return }
        
        let currentTime = videoPlayer?.currentTime() ?? CMTime.zero
        if let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            subject.send(pixelBuffer)
        }
    }
    
    public func nextFrame() async throws -> CVPixelBuffer? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let currentTime = self?.videoPlayer?.currentTime() ?? CMTime.zero
                if let pixelBuffer = self?.videoOutput?.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
                    self?.subject.send(pixelBuffer)
                    continuation.resume(returning: pixelBuffer)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

}

import Foundation
import SwiftUI
//import CoreImage
//import CoreImage.CIFilterBuiltins

public struct ABCameraView: View {
    @Binding var pixelBuffer: CVPixelBuffer?

    public init(pixelBuffer: Binding<CVPixelBuffer?>) {
        self._pixelBuffer = pixelBuffer
    }
    
    public var body: some View {
        if let pixelBuffer = pixelBuffer, let image = imageFromPixelBuffer(pixelBuffer) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            EmptyView()
        }
    }

    func imageFromPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

import UIKit
import CoreImage

class PhotoProcessor {
    private let context: CIContext
    
    init() {
        context = CIContext()
    }
    
    func processImage(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Apply random color variations
        let colorAdjusted = applyRandomColorAdjustments(to: ciImage)
        
        // Apply Gaussian blur
        let blurred = applyGaussianBlur(to: colorAdjusted)
        
        // Apply vignette
        let vignetted = applyVignette(to: blurred)
        
        // Convert back to UIImage
        guard let outputImage = context.createCGImage(vignetted, from: vignetted.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputImage)
    }
    
    private func applyRandomColorAdjustments(to image: CIImage) -> CIImage {
        // Random color adjustments to simulate film inconsistencies
        let saturation = 0.8 + Double.random(in: -0.2...0.2)
        let brightness = 0.0 + Double.random(in: -0.1...0.1)
        let contrast = 1.1 + Double.random(in: -0.1...0.1)
        
        let colorControls = image
            .applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: saturation,
                kCIInputBrightnessKey: brightness,
                kCIInputContrastKey: contrast
            ])
        
        return colorControls
    }
    
    private func applyGaussianBlur(to image: CIImage) -> CIImage {
        return image.applyingFilter("CIGaussianBlur", parameters: [
            kCIInputRadiusKey: 2.0
        ])
    }
    
    private func applyVignette(to image: CIImage) -> CIImage {
        let vignette = image.applyingFilter("CIVignette", parameters: [
            kCIInputRadiusKey: 1.0,
            kCIInputIntensityKey: 1.0
        ])
        
        return vignette
    }
}
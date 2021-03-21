//
//  XUtils.swift
//  ONUGraphics
//
//  Created by Andrii Zinoviev on 21.03.2021.
//

import Foundation
import Cocoa
import CoreGraphics
import simd

class XUtils {
    private init() {
        fatalError()
    }
    
    public static func chooseImage() -> NSImage? {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        let response = openPanel.runModal()
        
        guard response == .OK else {
            return nil
        }
        
        guard let url = openPanel.url else {
            return nil
        }
        
        return NSImage(byReferencing: url)
    }
    
    public static func processImage(_ image: NSImage, with transform: (NSColor) -> NSColor) -> NSImage? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)?.sRGBImage else {
            return nil
        }
        
        guard var colors = sRGBImageToColors(cgImage) else {
            return nil
        }
        
        for i in 0..<colors.count {
            colors[i] = transform(colors[i])
        }
        
        guard let newCGImage = colorsToSRGBImage(colors, width: cgImage.width, height: cgImage.height) else {
            return nil
        }
        
        return NSImage(cgImage: newCGImage,
                       size: NSSize(width: cgImage.width, height: cgImage.height))
    }
    
    private static func clampToColor(_ x: CGFloat) -> CGFloat {
        return max(0, min(1, x))
    }
    
    public static func colorsToSRGBImage(_ colors: [NSColor], width: Int, height: Int) -> CGImage? {
        assert(colors.count == width * height)
        
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        
        for i in 0..<width*height {
            rawData[4 * i + 0] = UInt8(clampToColor(colors[i].redComponent)  * 255)
            rawData[4 * i + 1] = UInt8(clampToColor(colors[i].greenComponent) * 255)
            rawData[4 * i + 2] = UInt8(clampToColor(colors[i].blueComponent)  * 255)
            rawData[4 * i + 3] = UInt8(clampToColor(colors[i].alphaComponent) * 255)
        }
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        return CGContext(data: &rawData,
                         width: width,
                         height: height,
                         bitsPerComponent: 8,
                         bytesPerRow: 4 * width,
                         space: CGColorSpace.sRGBColorSpace,
                         bitmapInfo: bitmapInfo)?.makeImage()
    }
    
    public static func sRGBImageToColors(_ cgImage: CGImage) -> [NSColor]? {
        let width = cgImage.width
        let height = cgImage.height
        
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4 * width,
                                      space: cgImage.colorSpace!,
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var colors = [NSColor](repeating: .black, count: width * height)
        
        for i in 0..<width*height {
            let red   = CGFloat(rawData[4 * i]    ) / 255.0
            let green = CGFloat(rawData[4 * i + 1]) / 255.0
            let blue  = CGFloat(rawData[4 * i + 2]) / 255.0
            let alpha = CGFloat(rawData[4 * i + 3]) / 255.0
            let color = NSColor(red: red, green: green, blue: blue, alpha: alpha)
            colors[i] = color
        }
        
        return colors
    }
    
    public static func colorTransform(_ rows: [SIMD4<Float>]) -> (NSColor) -> NSColor {
        return { color in
            let matrix: float4x4 = float4x4(rows: rows)
            let colorIn: SIMD4<Float> = [Float(color.redComponent),
                                         Float(color.greenComponent),
                                         Float(color.blueComponent),
                                         Float(color.alphaComponent)]
            let colorOut = simd_mul(matrix, colorIn)
            return NSColor(red: CGFloat(colorOut[0]),
                           green: CGFloat(colorOut[1]),
                           blue: CGFloat(colorOut[2]),
                           alpha: CGFloat(colorOut[3]))
        }
    }
    
    public static func colorTransformG(_ c: SIMD3<Float>) -> (NSColor) -> NSColor {
        return colorTransform([[c[0],c[1],c[2],0],[c[0],c[1],c[2],0],[c[0],c[1],c[2],0],[0,0,0,1]])
    }
}

public extension CGColorSpace {
    static var sRGBColorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
}

public extension CGImage {
    var sRGBImage: CGImage? {
        let desiredColorSpace = CGColorSpace.sRGBColorSpace
        
        if colorSpace == desiredColorSpace {
            return self
        }
        
        return self.copy(colorSpace: desiredColorSpace)
    }
}

public extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
            
            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }
        
        return nil
    }
}

public extension NSLayoutConstraint {
    static func activateConstraints(for innerView: NSView, in outerView: NSView) {
        innerView.translatesAutoresizingMaskIntoConstraints = false
        activate([
            innerView.topAnchor.constraint(equalTo: outerView.topAnchor),
            innerView.bottomAnchor.constraint(equalTo: outerView.bottomAnchor),
            innerView.leftAnchor.constraint(equalTo: outerView.leftAnchor),
            innerView.rightAnchor.constraint(equalTo: outerView.rightAnchor),
        ])
    }
}

//
//  MainViewController.swift
//  ONUGraphics
//
//  Created by Andrii Zinoviev on 21.03.2021.
//

import Cocoa
import simd

struct ImageTransformMode {
    public let name: String
    public let colorTransform: ((NSColor) -> NSColor)
}

class MainViewController: XViewController {
    private static func createImageView() -> XImageTransformationView {
        let view = XImageTransformationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private let imageView: XImageTransformationView = createImageView()
    private let modifiedImageView: XImageTransformationView = createImageView()
    
    private static var allModes: [ImageTransformMode] = [
        ImageTransformMode(name: "None",
                           colorTransform: XUtils.colorTransform([[1, 0, 0, 0],
                                                                  [0, 1, 0, 0],
                                                                  [0, 0, 1, 0],
                                                                  [0, 0, 0, 1]])),
        ImageTransformMode(name: "RGB Red",
                           colorTransform: XUtils.colorTransform([[1, 0, 0, 0],
                                                                  [1, 0, 0, 0],
                                                                  [1, 0, 0, 0],
                                                                  [0, 0, 0, 1]])),
        ImageTransformMode(name: "RGB Green",
                           colorTransform: XUtils.colorTransform( [[0, 1, 0, 0],
                                                                   [0, 1, 0, 0],
                                                                   [0, 1, 0, 0],
                                                                   [0, 0, 0, 1]])),
        ImageTransformMode(name: "RGB Blue",
                           colorTransform: XUtils.colorTransform( [[0, 0, 1, 0],
                                                                   [0, 0, 1, 0],
                                                                   [0, 0, 1, 0],
                                                                   [0, 0, 0, 1]])),
        ImageTransformMode(name: "CMYK",
                           colorTransform: XUtils.colorTransform( [[-1, 0,  1,  1],
                                                                   [0, -1,  1,  1],
                                                                   [0,  0, -1,  1],
                                                                   [0,  0,  0,  1]])),
        ImageTransformMode(name: "Y",
                           colorTransform: XUtils.colorTransformG( [0.3, 0.587, 0.114])),
        ImageTransformMode(name: "Cb",
                           colorTransform: XUtils.colorTransformG( [-0.17, -0.33, 0.5])),
        ImageTransformMode(name: "Cr",
                           colorTransform: XUtils.colorTransformG( [0.5, -0.42, -0.08])),
        ImageTransformMode(name: "Hue",
                           colorTransform: { color in
                            NSColor(hue: color.hueComponent, saturation: 1.0, brightness: 1.0, alpha: color.alphaComponent)
                           }),
        ImageTransformMode(name: "Saturation",
                           colorTransform: { color in
                            NSColor(red: color.saturationComponent, green: color.saturationComponent, blue: color.saturationComponent, alpha: 1.0)
                           }),
        ImageTransformMode(name: "Value",
                           colorTransform: { color in
                            NSColor(red: color.brightnessComponent, green: color.brightnessComponent, blue: color.brightnessComponent, alpha: 1.0)
                           }),
    ]
    
    private let modeSelector: NSPopUpButton = {
        let view = NSPopUpButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addItems(withTitles: allModes.map({$0.name}))
        return view
    }()
    
    public func updateImage(_ image: NSImage) {
        self.imageView.update(image: image, colorTransform: {$0})
        self.modifiedImageView.update(image: image, colorTransform: {$0})
    }
    
    @objc func modeChanged() {
        self.modifiedImageView.update(image: self.modifiedImageView.image,
                                      colorTransform: Self.allModes[modeSelector.indexOfSelectedItem].colorTransform)
    }
    
    override func viewDidLoad() {
        modeSelector.target = self
        modeSelector.action = #selector(modeChanged)
        
        view.addSubview(imageView)
        view.addSubview(modifiedImageView)
        view.addSubview(modeSelector)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 500),
            imageView.widthAnchor.constraint(equalToConstant: 500),
            
            modifiedImageView.topAnchor.constraint(equalTo: view.topAnchor),
            modifiedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            modifiedImageView.leftAnchor.constraint(equalTo: imageView.rightAnchor),
            modifiedImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            modifiedImageView.heightAnchor.constraint(equalToConstant: 500),
            modifiedImageView.widthAnchor.constraint(equalToConstant: 500),
        ])
    }
}

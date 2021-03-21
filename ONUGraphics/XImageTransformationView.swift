//
//  XImageTransformationView.swift
//  ONUGraphics
//
//  Created by Andrii Zinoviev on 21.03.2021.
//

import Foundation
import Cocoa

public class XImageTransformationView: NSView {
    private let imageView: NSImageView = NSImageView()
    private(set) var image: NSImage?
    private(set) var colorTransform: (NSColor) -> NSColor = {$0}
    
    public func update(image: NSImage?, colorTransform: @escaping (NSColor) -> NSColor) {
        self.image = image
        self.colorTransform = colorTransform
        if let image = image {
            let imageSize = NSSize(width: 500, height: 500 / image.size.width * image.size.height)
            self.imageView.image = XUtils.processImage(image, with: colorTransform)?.resized(to: imageSize)
        }
        else {
            self.imageView.image = nil
        }
    }
    
    public init() {
        super.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activateConstraints(for: imageView, in: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

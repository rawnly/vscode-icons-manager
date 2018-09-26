//
//  CollectionViewItem.swift
//  VSCode Icons Manager
//
//  Created by Federico Vitale on 26/09/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    var img: AspectFillImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        img = AspectFillImageView(frame: NSRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        
        img?.imageAlignment = .alignCenter
        img?.imageScaling = .scaleProportionallyDown
        
        view.addSubview(img!)
    }
}

class AspectFillImageView: NSImageView {
    override var intrinsicContentSize: CGSize {
        guard let img = self.image else { return .zero }
        
        let viewWidth = self.frame.size.width
        let ratio = viewWidth / img.size.width
        return CGSize(width: viewWidth, height: img.size.height * ratio)
    }
}

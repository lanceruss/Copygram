//
//  FilterCells.swift
//  Instagram
//
//  Created by Lance Russ on 6/20/16.
//  Copyright © 2016 Paul Lefebvre. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

enum FilterCell: Int {
    
    case Original
    case Sepia
    case Fade
    case Ashen
    case Charcoal
    case September
    //case Pixellate
    //case Gloom

    
    func text() -> String {
        
        switch self {
            
        case .Original: return "Original"
        case .Sepia: return "Sepia"
        case .Fade: return "Fade"
        case .Ashen: return "Ashen"
        case .Charcoal: return "Charcoal"
        case .September: return "September"
        //case .Pixellate: return "Pixellate"
        //case .Gloom: return "Gloom"
        
        }
    }
    
    
    func filter() -> CIFilter {
        
        switch self {
            
        case .Original: return CIFilter()
        case .Sepia: return CIFilter(name: "CISepiaTone")!
        case .Fade: return CIFilter(name: "CIPhotoEffectFade")!
        case .Ashen: return CIFilter(name: "CIPhotoEffectNoir")!
        case .Charcoal: return CIFilter(name: "CIPhotoEffectMono")!
        case .September: return CIFilter(name: "CIPhotoEffectInstant")!
        //case .Pixellate: return CIFilter(name: "CIPixellate")!
        //case .Gloom: return CIFilter(name: "CIGloom")!
        
        }
        
    }
}

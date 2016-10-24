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
    
    case original
    case sepia
    case fade
    case ashen
    case charcoal
    case september
    //case Pixellate
    //case Gloom

    
    func text() -> String {
        
        switch self {
            
        case .original: return "Original"
        case .sepia: return "Sepia"
        case .fade: return "Fade"
        case .ashen: return "Ashen"
        case .charcoal: return "Charcoal"
        case .september: return "September"
        //case .Pixellate: return "Pixellate"
        //case .Gloom: return "Gloom"
        
        }
    }
    
    
    func filter() -> CIFilter {
        
        switch self {
            
        case .original: return CIFilter()
        case .sepia: return CIFilter(name: "CISepiaTone")!
        case .fade: return CIFilter(name: "CIPhotoEffectFade")!
        case .ashen: return CIFilter(name: "CIPhotoEffectNoir")!
        case .charcoal: return CIFilter(name: "CIPhotoEffectMono")!
        case .september: return CIFilter(name: "CIPhotoEffectInstant")!
        //case .Pixellate: return CIFilter(name: "CIPixellate")!
        //case .Gloom: return CIFilter(name: "CIGloom")!
        
        }
        
    }
}

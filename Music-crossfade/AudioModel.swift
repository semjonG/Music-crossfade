//
//  AudioModel.swift
//  Music-crossfade
//
//  Created by mac on 10.04.2022.
//

import Foundation
import UniformTypeIdentifiers

struct AudioModel {
    let types = UTType.types(tag: "mp3",
                             tagClass: UTTagClass.filenameExtension,
                             conformingTo: nil)
    
    var track1URL = URL(string: "")
    var track2URL = URL(string: "")
    
    var crossFadeValue: Double = 0.0
    
    let alertMessage = "Something's wrong. Probably you didn't choose one or both songs."
}

//
//  Item.swift
//  NoteApp
//
//  Created by Iuliana Stecalovici on 22.04.2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

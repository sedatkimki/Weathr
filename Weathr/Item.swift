//
//  Item.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
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

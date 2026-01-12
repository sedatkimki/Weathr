//
//  CityRecord.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import Foundation
import SwiftData

@Model
final class CityRecord {
    @Attribute(.unique) var name: String
    var createdAt: Date

    init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }
}

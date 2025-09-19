//
//  Item.swift
//  ExpressUnited
//
//  Created by Pernell Toney on 9/18/25.
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

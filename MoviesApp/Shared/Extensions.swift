//
//  Extensions.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 30/5/22.
//

import Foundation

// Adds isNotEmpty for better readability where necessary
extension Collection {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

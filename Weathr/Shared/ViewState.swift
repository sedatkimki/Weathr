//
//  File.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//
import Foundation

enum ViewState<Content: Equatable>: Equatable {
    case idle
    case loading
    case content(Content)
    case failed(message: String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var value: Content? {
        if case let .content(value) = self { return value }
        return nil
    }

    var errorMessage: String? {
        if case let .failed(message) = self { return message }
        return nil
    }
}

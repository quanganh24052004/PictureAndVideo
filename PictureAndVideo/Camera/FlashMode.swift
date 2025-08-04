//
//  FlashMode.swift
//  PictureAndVideo
//
//  Created by iKame Elite Fresher 2025 on 8/4/25.
//

private enum FlashMode: CaseIterable {
    case off, auto, on

    var next: FlashMode {
        switch self {
        case .off: return .auto
        case .auto: return .on
        case .on: return .off
        }
    }

    var description: String {
        switch self {
        case .off: return "Off"
        case .auto: return "Auto"
        case .on: return "On"
        }
    }
}

private var currentFlashMode: FlashMode = .off

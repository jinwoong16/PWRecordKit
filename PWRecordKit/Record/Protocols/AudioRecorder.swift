//
//  AudioRecorder.swift
//  PWRecordKit
//
//  Created by jinwoong Kim on 11/15/23.
//

import Foundation
import AVFAudio

public protocol AudioRecorder: Actor {
    var currentTime: TimeInterval? { get }
    
    func requestPermission() async -> Bool
    func start(url: URL) async throws
    func stop()
}

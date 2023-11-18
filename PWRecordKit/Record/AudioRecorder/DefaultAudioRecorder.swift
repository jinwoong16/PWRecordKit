//
//  DefaultAudioRecorder.swift
//  PWRecordKit
//
//  Created by jinwoong Kim on 11/15/23.
//

import Foundation
import AVFAudio

enum AudioError: Error {
    case permissionDenied
}

public actor DefaultAudioRecorder: AudioRecorder {
    var recorder: AVAudioRecorder?
    
    public init() {}
    
    public var currentTime: TimeInterval? {
        guard let recorder = self.recorder,
              recorder.isRecording else {
            return nil
        }
        return recorder.currentTime
    }
    
    public func requestPermission() async -> Bool {
        if #available(iOS 17, *) {
            return await AVAudioApplication.requestRecordPermission()
        } else {
            return await withUnsafeContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { permission in
                    continuation.resume(returning: permission)
                }
            }
        }
    }
    
    public func start(url: URL) async throws {
        guard await requestPermission() else {
            throw AudioError.permissionDenied
        }
        
        let recorder = try AVAudioRecorder(
            url: url,
            settings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
        )
        self.recorder = recorder
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        
        self.recorder?.record()
    }
    
    public func stop() {
        self.recorder?.stop()
        self.recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

import Foundation
import AVFoundation
import SpriteKit

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    private var soundEnabled: Bool {
        GameProgressManager.shared.soundEnabled
    }

    private var musicEnabled: Bool {
        GameProgressManager.shared.musicEnabled
    }

    func playSound(_ name: String) {
        guard soundEnabled else { return }

        if let player = audioPlayers[name], player.isPlaying {
            player.stop()
            player.currentTime = 0
            player.play()
            return
        }

        if let player = audioPlayers[name] {
            player.currentTime = 0
            player.play()
        } else {
            generatePlaceholderSound(name)
        }
    }

    private func generatePlaceholderSound(_ name: String) {
        let duration: Double
        let frequency: Double
        let amplitude: Float

        switch name {
        case "slingshot_pull":
            duration = 0.15; frequency = 200; amplitude = 0.1
        case "launch":
            duration = 0.2; frequency = 400; amplitude = 0.3
        case "bounce":
            duration = 0.08; frequency = 300; amplitude = 0.15
        case "rim_hit":
            duration = 0.12; frequency = 800; amplitude = 0.25
        case "backboard_hit":
            duration = 0.1; frequency = 500; amplitude = 0.2
        case "swish":
            duration = 0.5; frequency = 1200; amplitude = 0.35
        case "star_collect":
            duration = 0.3; frequency = 1500; amplitude = 0.3
        case "ice_break":
            duration = 0.4; frequency = 150; amplitude = 0.4
        case "trampoline":
            duration = 0.25; frequency = 600; amplitude = 0.3
        case "fan":
            duration = 0.3; frequency = 100; amplitude = 0.1
        case "ability":
            duration = 0.3; frequency = 900; amplitude = 0.3
        case "level_complete":
            duration = 1.0; frequency = 800; amplitude = 0.4
        case "button_click":
            duration = 0.05; frequency = 700; amplitude = 0.15
        case "fail":
            duration = 0.5; frequency = 100; amplitude = 0.3
        default:
            duration = 0.1; frequency = 440; amplitude = 0.2
        }

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!

        let frameCount = AVAudioFrameCount(duration * 44100)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        let channelData = buffer.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / 44100.0
            var sample: Float = 0

            switch name {
            case "swish":
                let freq1 = frequency * (1.0 + t * 2)
                let freq2 = frequency * 1.5 * (1.0 + t * 2)
                sample = Float(sin(2 * .pi * freq1 * t) * 0.5 + sin(2 * .pi * freq2 * t) * 0.3)
                sample *= amplitude * Float(1.0 - t / duration)
            case "star_collect":
                let freq1 = frequency * (1.0 + t * 3)
                let freq2 = frequency * 1.25 * (1.0 + t * 2)
                sample = Float(sin(2 * .pi * freq1 * t) * 0.6 + sin(2 * .pi * freq2 * t) * 0.4)
                sample *= amplitude * Float(1.0 - t / duration)
            case "trampoline":
                let freq = frequency * (1.0 - t / duration * 0.5)
                sample = Float(sin(2 * .pi * freq * t))
                sample *= amplitude * Float(exp(-t * 8))
            case "level_complete":
                let notes = [523.25, 659.25, 783.99, 1046.50]
                let noteIndex = min(Int(t / (duration / 4)), 3)
                let noteFreq = notes[noteIndex]
                sample = Float(sin(2 * .pi * noteFreq * t))
                sample *= amplitude * 0.8
            case "ice_break":
                sample = Float((Double(arc4random()) / Double(UInt32.max) - 0.5) * 2.0)
                sample *= amplitude * Float(1.0 - t / duration)
            default:
                sample = Float(sin(2 * .pi * frequency * t))
                sample *= amplitude * Float(exp(-t * 5))
            }

            channelData[i] = sample
        }

        do {
            let tempPlayer = try AVAudioPlayer(data: bufferToData(buffer: buffer, format: format), fileTypeHint: AVFileType.wav.rawValue)
            tempPlayer.prepareToPlay()
            tempPlayer.play()
            audioPlayers[name] = tempPlayer
        } catch {
            print("Sound generation error: \(error)")
        }
    }

    private func bufferToData(buffer: AVAudioPCMBuffer, format: AVAudioFormat) -> Data {
        var data = Data()
        let channels = 1
        let bitsPerSample = 16
        let bytesPerSample = bitsPerSample / 8
        let bytesPerFrame = channels * bytesPerSample
        let sampleRate = Int(format.sampleRate)
        let totalFrames = Int(buffer.frameLength)
        let totalDataBytes = totalFrames * bytesPerFrame

        var header = Data()
        header.append("RIFF".data(using: .ascii)!)
        var chunkSize: UInt32 = UInt32(36 + totalDataBytes)
        header.append(Data(bytes: &chunkSize, count: 4))
        header.append("WAVE".data(using: .ascii)!)
        header.append("fmt ".data(using: .ascii)!)
        var subChunk1Size: UInt32 = 16
        header.append(Data(bytes: &subChunk1Size, count: 4))
        var audioFormat: UInt16 = 1
        header.append(Data(bytes: &audioFormat, count: 2))
        var numChannels: UInt16 = UInt16(channels)
        header.append(Data(bytes: &numChannels, count: 2))
        var sampleRate32: UInt32 = UInt32(sampleRate)
        header.append(Data(bytes: &sampleRate32, count: 4))
        var byteRate: UInt32 = UInt32(sampleRate * bytesPerFrame)
        header.append(Data(bytes: &byteRate, count: 4))
        var blockAlign: UInt16 = UInt16(bytesPerFrame)
        header.append(Data(bytes: &blockAlign, count: 2))
        var bits: UInt16 = UInt16(bitsPerSample)
        header.append(Data(bytes: &bits, count: 2))
        header.append("data".data(using: .ascii)!)
        var dataSize: UInt32 = UInt32(totalDataBytes)
        header.append(Data(bytes: &dataSize, count: 4))

        data.append(header)
        let channelData = buffer.floatChannelData![0]
        for i in 0..<totalFrames {
            var sample = Int16(max(-1.0, min(1.0, channelData[i])) * 32767.0)
            data.append(Data(bytes: &sample, count: 2))
        }
        return data
    }

    func playMusic(_ type: String) {
        guard musicEnabled else { return }
        stopMusic()

        let duration: Double = 30.0
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let frameCount = AVAudioFrameCount(duration * 44100)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        let channelData = buffer.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / 44100.0
            var sample: Float = 0

            if type == "menu" {
                let melody = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25]
                let noteTime = 0.4
                let noteIndex = Int(t / noteTime) % melody.count
                let freq = melody[noteIndex]
                let localT = t.truncatingRemainder(dividingBy: noteTime)
                let envelope = Float(exp(-localT * 3))
                sample = Float(sin(2 * .pi * freq * t)) * 0.08 * envelope
            } else if type == "gameplay" {
                let bass = [130.81, 164.81, 196.00, 146.83]
                let bassIndex = Int(t / 0.8) % bass.count
                let bassFreq = bass[bassIndex]
                sample = Float(sin(2 * .pi * bassFreq * t)) * 0.04

                let melody = [523.25, 587.33, 659.25, 698.46]
                let melodyIndex = Int(t / 0.4) % melody.count
                let melodyFreq = melody[melodyIndex]
                let localT = t.truncatingRemainder(dividingBy: 0.4)
                let envelope = Float(exp(-localT * 4))
                sample += Float(sin(2 * .pi * melodyFreq * t)) * 0.05 * envelope
            } else {
                let notes = [523.25, 659.25, 783.99, 1046.50, 1318.51]
                let noteIndex = min(Int(t / 0.3), 4)
                let freq = notes[noteIndex]
                let localT = t - Double(noteIndex) * 0.3
                let envelope = Float(exp(-localT * 2))
                sample = Float(sin(2 * .pi * freq * t)) * 0.15 * envelope
            }

            channelData[i] = sample
        }

        do {
            let player = try AVAudioPlayer(data: bufferToData(buffer: buffer, format: format), fileTypeHint: AVFileType.wav.rawValue)
            player.numberOfLoops = -1
            player.volume = type == "gameplay" ? 0.3 : 0.4
            player.prepareToPlay()
            player.play()
            backgroundMusicPlayer = player
        } catch {
            print("Music error: \(error)")
        }
    }

    func stopMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }

    func updateAudioSettings() {
        if !musicEnabled {
            stopMusic()
        }
    }
}

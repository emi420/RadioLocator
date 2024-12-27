//
//  DTMFPlayer.swift
//  Radio Map
//
//  Created by Emilio Mariscal on 25/12/2024.
//

/*
 Core inspired in:
 https://github.com/palmerc/DTMFSounds/
 */

import Foundation
import AVFoundation

var _sampleRate: Float = 8000.0
var _engine = AVAudioEngine()
var _player:AVAudioPlayerNode = AVAudioPlayerNode()
var _mixer = _engine.mainMixerNode

public typealias DTMFType = (Float, Float)
public typealias MarkSpaceType = (Float, Float)
public class DTMFPlayer
{
    public static let tone1     = DTMFType(1209.0, 697.0)
    public static let tone2     = DTMFType(1336.0, 697.0)
    public static let tone3     = DTMFType(1477.0, 697.0)
    public static let tone4     = DTMFType(1209.0, 770.0)
    public static let tone5     = DTMFType(1336.0, 770.0)
    public static let tone6     = DTMFType(1477.0, 770.0)
    public static let tone7     = DTMFType(1209.0, 852.0)
    public static let tone8     = DTMFType(1336.0, 852.0)
    public static let tone9     = DTMFType(1477.0, 852.0)
    public static let tone0     = DTMFType(1336.0, 941.0)
    public static let toneStar  = DTMFType(1209.0, 941.0)
    public static let tonePound = DTMFType(1477.0, 941.0)
    public static let toneA     = DTMFType(1633.0, 697.0)
    public static let toneB     = DTMFType(1633.0, 770.0)
    public static let toneC     = DTMFType(1633.0, 852.0)
    public static let toneD     = DTMFType(1633.0, 941.0)

    public static let big  = MarkSpaceType(600.0, 75.0)
    public static let small  = MarkSpaceType(250.0, 75.0)


    /**
     Generates a series of Float samples representing a DTMF tone with a given mark and space.
     
        - parameter DTMF: takes a DTMFType comprised of two floats that represent the desired tone frequencies in Hz.
        - parameter markSpace: takes a MarkSpaceType comprised of two floats representing the duration of each in milliseconds. The mark represents the length of the tone and space the silence.
        - parameter sampleRate: the number of samples per second (Hz) desired.
        - returns: An array of Float that contains the Linear PCM samples that can be fed to AVAudio.
     */
    public static func generateDTMF(_ DTMF: DTMFType, markSpace: MarkSpaceType = small, sampleRate: Float = 44100.0) -> [Float]
    {
        let toneLengthInSamples = 10e-4 * markSpace.0 * sampleRate
        let silenceLengthInSamples = 10e-4 * markSpace.1 * sampleRate

        var sound = [Float](repeating: 0, count: Int(toneLengthInSamples + silenceLengthInSamples))
        let twoPI:Float = 2.0 * .pi

        for i in 0 ..< Int(toneLengthInSamples) {
            // Add first tone at half volume
            let sample1 = 0.5 * sin(Float(i) * twoPI / (sampleRate / DTMF.0));

            // Add second tone at half volume
            let sample2 = 0.5 * sin(Float(i) * twoPI / (sampleRate / DTMF.1));

            sound[i] = sample1 + sample2
        }

        return sound
    }
}

extension DTMFPlayer
{
    enum characterForTone: Character {
        case tone1     = "1"
        case tone2     = "2"
        case tone3     = "3"
        case tone4     = "4"
        case tone5     = "5"
        case tone6     = "6"
        case tone7     = "7"
        case tone8     = "8"
        case tone9     = "9"
        case tone0     = "0"
        case toneA     = "A"
        case toneB     = "B"
        case toneC     = "C"
        case toneD     = "D"
        case toneStar  = "*"
        case tonePound = "#"
    }

    public static func toneForCharacter(character: Character) -> DTMFType?
    {
        var tone: DTMFType?
        switch (character) {
        case characterForTone.tone1.rawValue:
            tone = DTMFPlayer.tone1
            break
        case characterForTone.tone2.rawValue:
            tone = DTMFPlayer.tone2
            break
        case characterForTone.tone3.rawValue:
            tone = DTMFPlayer.tone3
            break
        case characterForTone.tone4.rawValue:
            tone = DTMFPlayer.tone4
            break
        case characterForTone.tone5.rawValue:
            tone = DTMFPlayer.tone5
            break
        case characterForTone.tone6.rawValue:
            tone = DTMFPlayer.tone6
            break
        case characterForTone.tone7.rawValue:
            tone = DTMFPlayer.tone7
            break
        case characterForTone.tone8.rawValue:
            tone = DTMFPlayer.tone8
            break
        case characterForTone.tone9.rawValue:
            tone = DTMFPlayer.tone9
            break
        case characterForTone.tone0.rawValue:
            tone = DTMFPlayer.tone0
            break
        case characterForTone.toneA.rawValue:
            tone = DTMFPlayer.toneA
            break
        case characterForTone.toneB.rawValue:
            tone = DTMFPlayer.toneB
            break
        case characterForTone.toneC.rawValue:
            tone = DTMFPlayer.toneC
            break
        case characterForTone.toneD.rawValue:
            tone = DTMFPlayer.toneD
            break
        case characterForTone.toneStar.rawValue:
            tone = DTMFPlayer.toneStar
            break
        case characterForTone.tonePound.rawValue:
            tone = DTMFPlayer.tonePound
            break
        default:
            break
        }

        return tone
    }

    private static func tonesForString(_ string: String) -> [DTMFType]?
    {
        var tones = [DTMFType]()
        for character in string {
            if let tone = DTMFPlayer.toneForCharacter(character: character) {
                tones.append(tone)
            }
        }

        return tones.count > 0 ? tones : nil
    }
    
    public static func playMessage(message: String) {
        if let tones = DTMFPlayer.tonesForString(message) {
            let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(_sampleRate), channels: 2, interleaved: false)!

                // Fill up the buffer with the message
                var message = [Float]()
                for (index, tone) in tones.enumerated() {
                    let markSpaceValue: (Float, Float)
                    if index == 0 || index == tones.count - 1 {
                        markSpaceValue = DTMFPlayer.big
                    } else {
                        markSpaceValue = DTMFPlayer.small
                    }
                    let samples = DTMFPlayer.generateDTMF(tone, markSpace: markSpaceValue, sampleRate: _sampleRate);  message.append(contentsOf: samples)
                }

                let frameCount = AVAudioFrameCount(message.count)
                let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount)!

                buffer.frameLength = frameCount
                let channelMemory = buffer.floatChannelData!
                for channelIndex in 0 ..< Int(audioFormat.channelCount) {
                    let frameMemory = channelMemory[channelIndex]
                    memcpy(frameMemory, message, Int(frameCount) * MemoryLayout<Float>.size)
                }

                _engine.attach(_player)
                _engine.connect(_player, to:_mixer, format:audioFormat)

                do {
                    try _engine.start()
                } catch let error as NSError {
                    print("Engine start failed - \(error)")
                }

                _player.scheduleBuffer(buffer, at:nil)
                _player.play()
        }
        
    }
}

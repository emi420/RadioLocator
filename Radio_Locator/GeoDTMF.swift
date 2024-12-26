//
//  GeoDTMF.swift
//  Radio Locator
//
//  Created by Emilio Mariscal on 25/12/2024.
//

import Foundation

public class GeoDTMF
{
        
    private func addBBetweenConsecutiveDuplicates(_ str: String) -> String {
        var result = ""
        let chars = Array(str)
        
        for i in 0..<chars.count {
            result.append(chars[i])
            if i > 0 && chars[i] == chars[i - 1] {
                result.append("B")
            }
        }
        return result
    }
    
    public func encodeDTMF(latitude: Double, longitude: Double) -> String {
        let delimiter = "A" // DTMF-compatible delimiter
        let latInt = Int(round(abs(latitude) * 1e6))
        let lonInt = Int(round(abs(longitude) * 1e6))
        
        let latPrefix = latitude < 0 ? "1" : "0"
        let lonPrefix = longitude < 0 ? "1" : "0"
        
        let messageBody = "\(latPrefix)\(latInt)\(delimiter)\(lonPrefix)\(lonInt)"
        return "*\(addBBetweenConsecutiveDuplicates(messageBody))#"
    }
    
}

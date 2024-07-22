//
//  DownloadAPI.swift
//  Combine2AsyncAlgos
//
//  Created by Jacob Bartlett on 21/07/2024.
//

import Foundation

final class DownloadAPI {
    
    func startDownload(_ progress: @escaping (Double) -> Void) async {
        var percentage = 0.0
        while percentage < 100 {
            try? await Task.sleep(for: .milliseconds(10))
            let bits = Double.random(in: 0...0.3)
            percentage += bits
            progress(percentage)
        }
        progress(100)
    }
}

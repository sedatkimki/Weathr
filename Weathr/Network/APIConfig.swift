//
//  APIConfig.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import Foundation

struct APIConfig: Decodable {
    let weatherApiUrl: String
    let apiKey: String
    
    static let shared: APIConfig = {
        guard let url = Bundle.main.url(forResource: "APIConfig", withExtension: "json") else {
            fatalError("APIConfig.json is missing or invalid")
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(APIConfig.self, from: data)
        }catch {
            fatalError("Failed to load or decode APIConfig.json \n\(error.localizedDescription)")
        }
    }()
}

//
//  WeatherService.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import Foundation
import Alamofire

final class WeatherService {
    static let shared = WeatherService()

    private let config: APIConfig
    private let session: Session
    private let decoder = JSONDecoder()

    init(config: APIConfig = .shared, session: Session = .default) {
        self.config = config
        self.session = session
    }

    func fetchCurrent(query: String) async throws -> WeatherResponse {
        print("WeatherService.fetchCurrent query=\(query)")
        let response: WeatherResponse = try await request(
            endpoint: config.currentEndpoint,
            query: ["q": query]
        )
        return response
    }

    func fetchForecast(query: String, days: Int) async throws -> ForecastResponse {
        print("WeatherService.fetchForecast query=\(query) days=\(days)")
        let response: ForecastResponse = try await request(
            endpoint: config.forecastEndpoint,
            query: ["q": query, "days": String(days)]
        )
        return response
    }

    func fetchSearch(query: String) async throws -> [CitySearchResult] {
        print("WeatherService.fetchSearch query=\(query)")
        let response: [CitySearchResult] = try await request(
            endpoint: config.searchEndpoint,
            query: ["q": query]
        )
        return response
    }

    private func request<T: Decodable>(endpoint: String, query: [String: String]) async throws -> T {
        let url = try makeURL(endpoint: endpoint)
        var parameters = query
        parameters["key"] = config.apiKey

        print("WeatherService.request url=\(url.absoluteString) params=\(parameters)")
        let response = await session.request(
            url,
            parameters: parameters,
            encoding: URLEncoding.default,
            requestModifier: {
                $0.cachePolicy = .reloadIgnoringLocalCacheData
                $0.timeoutInterval = 8
            }
        )
            .serializingData()
            .response

        if let statusCode = response.response?.statusCode, !(200...299).contains(statusCode) {
            print("WeatherService.response status=\(statusCode)")
            throw WeatherServiceError.httpStatus(statusCode)
        }

        switch response.result {
        case .success(let data):
            do {
                let value = try decode(T.self, from: data)
                print("WeatherService.response success")
                return value
            } catch {
                print("WeatherService.response failure error=\(error)")
                if let serviceError = error as? WeatherServiceError {
                    throw serviceError
                }
                throw WeatherServiceError.decoding(underlying: error)
            }
        case .failure(let error):
            print("WeatherService.response failure error=\(error)")
            if error.isExplicitlyCancelledError {
                throw CancellationError()
            }
            throw map(error)
        }
    }

    private func makeURL(endpoint: String) throws -> URL {
        guard var components = URLComponents(string: config.weatherApiUrl) else {
            throw WeatherServiceError.invalidBaseURL
        }

        let cleanEndpoint = endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint
        let basePath = components.path.hasSuffix("/") ? String(components.path.dropLast()) : components.path
        components.path = basePath + "/" + cleanEndpoint

        guard let url = components.url else {
            throw WeatherServiceError.invalidBaseURL
        }

        return url
    }

    private func map(_ error: AFError) -> WeatherServiceError {
        if case let .responseSerializationFailed(reason) = error,
           case let .decodingFailed(decodingError) = reason {
            return .decoding(underlying: decodingError)
        }

        if case let .sessionTaskFailed(underlyingError) = error {
            return .network(underlying: underlyingError)
        }

        return .network(underlying: error)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            if let sanitized = try? sanitizeCurrentPayload(data) {
                return try decoder.decode(T.self, from: sanitized)
            }
            throw WeatherServiceError.decoding(underlying: error)
        }
    }

    private func sanitizeCurrentPayload(_ data: Data) throws -> Data {
        guard var root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              var current = root["current"] as? [String: Any] else {
            return data
        }

        current = sanitizeCurrentValues(current)
        root["current"] = current
        return try JSONSerialization.data(withJSONObject: root)
    }

    private func sanitizeCurrentValues(_ current: [String: Any]) -> [String: Any] {
        var result = current
        let keysToCoerce = Set(["uv", "vis_km"])

        for key in keysToCoerce {
            guard let number = result[key] as? NSNumber else { continue }
            let doubleValue = number.doubleValue
            if doubleValue.rounded() != doubleValue {
                result[key] = Int(doubleValue.rounded())
            }
        }

        return result
    }
}

enum WeatherServiceError: LocalizedError {
    case network(underlying: Error)
    case httpStatus(Int)
    case decoding(underlying: Error)
    case invalidBaseURL

    var errorDescription: String? {
        switch self {
        case .network:
            return "Network error. Please try again."
        case .httpStatus(let code):
            return "Unexpected response (HTTP \(code))."
        case .decoding:
            return "Failed to decode server response."
        case .invalidBaseURL:
            return "Invalid base URL."
        }
    }
}

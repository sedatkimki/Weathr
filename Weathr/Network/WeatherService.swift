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

    private func request<T: Decodable>(endpoint: String, query: [String: String]) async throws -> T {
        let url = try makeURL(endpoint: endpoint)
        var parameters = query
        parameters["key"] = config.apiKey

        print("WeatherService.request url=\(url.absoluteString) params=\(parameters)")
        let response = await session.request(
            url,
            parameters: parameters,
            encoding: URLEncoding.default,
            requestModifier: { $0.cachePolicy = .reloadIgnoringLocalCacheData }
        )
            .serializingDecodable(T.self)
            .response

        if let statusCode = response.response?.statusCode, !(200...299).contains(statusCode) {
            print("WeatherService.response status=\(statusCode)")
            throw WeatherServiceError.httpStatus(statusCode)
        }

        switch response.result {
        case .success(let value):
            print("WeatherService.response success = \(value)")
            return value
        case .failure(let error):
            print("WeatherService.response failure error=\(error)")
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

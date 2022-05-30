//
//  MoviesService.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 28/5/22.
//

import Foundation
import UIKit

protocol MoviesEndpoint {
    var url: URL? { get }
}

class MoviesService {
    private static let apiKey = "0bfd4c7216b45fd4488c4e8b7c5dea55"
    
    let httpService: HttpService!
    
    // MARK: Change to SlowConnectionHttpService here to test how the app would work on slow mobile connections
    init(httpService: HttpService = SlowConnectionHttpService()) {
        self.httpService = httpService
    }
    
    
    // This enum contains all needed API methods and provide functionality
    enum ApiEndpoint: MoviesEndpoint {
        private var baseURL: String { "https://api.themoviedb.org/3/" }

        // API methods
        case searchMovie(String, Int)
        
        
        // Create the URL from the API method
        var url: URL? {
            var endpoint: String
            var queryItems: [URLQueryItem] = []
            
            switch self {
            case .searchMovie(let query, let page):
                endpoint = "search/movie"
                queryItems.append(URLQueryItem(name: "query", value: query))
                queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
                
            }
            
            // Construct the URL with baseURL, the API method and parameters (including the api_key)
            var urlComponents = URLComponents(string: baseURL + endpoint)!
            queryItems.append(URLQueryItem(name: "api_key", value: MoviesService.apiKey))
            urlComponents.queryItems = queryItems
            return urlComponents.url
        }
        
    }
    
    // Images referenced on API calls responses are accessed through a different endpoint
    enum ImagesEndpoint: MoviesEndpoint {
        private var baseURL: String { "https://image.tmdb.org/t/p/" }

        enum PosterSizes: String {
            case w92, w154, w185, w342, w500, w780, original
        }
        
        // Image methods
        case getPosterImage(String, PosterSizes)
        
        
        // Create the URL from the image method
        var url: URL? {
            var size: String
            var imagePath: String
            
            switch self {
            case .getPosterImage(let posterPath, let posterSize):
                size = posterSize.rawValue
                imagePath = posterPath
            }
            
            // Construct the URL with baseURL, the size and the image path
            return URL(string: baseURL + size + imagePath)
        }
    }
    
    // Execute the corresponding request and return response data
    private func executeRequest(endpoint: MoviesEndpoint) async throws -> Data? {
        guard let requestUrl = endpoint.url else { return nil }
        let data = try await httpService.executeRequest(url: requestUrl)
        return data
    }
    
        
    // Convenience funcs
    func searchMovies(query: String, page: Int) async throws -> MoviesResponse {
        // Perform the request
        guard let data = try await executeRequest(endpoint: ApiEndpoint.searchMovie(query, page)) else {
            return MoviesResponse(page: 0, results: [], totalPages: 0, totalResults: 0)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Decode the data as JSON and return the movies array
        let moviesResponse = try decoder.decode(MoviesResponse.self, from: data)
        return moviesResponse
    }
    
    func getPosterImage(path: String, size: ImagesEndpoint.PosterSizes) async throws -> UIImage? {
        
        // TODO: Add cache functionality
        
        // Perform the request
        guard let data = try await executeRequest(endpoint: ImagesEndpoint.getPosterImage(path, size)) else {
            return nil
        }
        
        // Decode the data as UIImage and return it
        return UIImage(data: data)
    }
    
}

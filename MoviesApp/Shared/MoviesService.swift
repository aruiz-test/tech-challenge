//
//  MoviesService.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 28/5/22.
//

import Foundation

internal typealias APIResult = ((_ result: Result<Data, Error>) -> Void)
extension String: Error {}

class MoviesService {
        
    // This enum contains all needed API methods and provide functionality
    enum API {
        private var baseURL: String { "https://api.themoviedb.org/3/" }
        private var apiKey: String  { "0bfd4c7216b45fd4488c4e8b7c5dea55" }

        // API methods
        case searchMovie(String)
        // TODO: Add getMoviePoster
        
        
        // Create the URL from the API method
        var url: URL {
            var endpoint: String
            var queryItems: [URLQueryItem] = []
            
            switch self {
            case .searchMovie(let query):
                endpoint = "search/movie"
                queryItems.append(URLQueryItem(name: "query", value: query))
            }
            
            // Construct the URL with baseURL, the API method and parameters (including the api_key)
            var urlComponents = URLComponents(string: baseURL + endpoint)!
            queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
            urlComponents.queryItems = queryItems
            
            return urlComponents.url!
        }
        
        // Execute the corresponding request and return response data
        internal func executeRequest() async throws -> Data {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
    }
    
        
    // Convenience funcs
    func searchMovies(query: String) async throws -> [Movie] {
        // Perform the request
        let data = try await API.searchMovie(query).executeRequest()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        // Decode the data as JSON and return the movies array
        let moviesResponse = try decoder.decode(MoviesResponse.self, from: data)
        return moviesResponse.results
    }
    
}

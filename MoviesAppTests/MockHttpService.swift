//
//  MockMoviesService.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 29/5/22.
//

import Foundation

class MockHttpService: HttpService {
    
    func executeRequest(url: URL) async throws -> Data {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        // Match URLs that we want to mock the request's response
        // Serialize mock data and return it as Data
        switch url.relativePath {
            
        case MoviesService.API.searchMovie("").url.relativePath:
            let data = try! jsonEncoder.encode(MockHttpService.testMoviesResponse)
            return data
            
        default:
            return Data()
        }

    }
    

    // Mock data to return
    static let testMoviesResponse = MoviesResponse(
        page: 1,
        results: testMovies,
        totalPages: 1,
        totalResults: testMovies.count
    )

    static let testMovies = [
        Movie(id: 1,
          title: "TEST MOVIE 1",
          posterPath: "",
          releaseDate: Date(timeIntervalSince1970: 0)
         ),
        Movie(id: 2,
          title: "TEST MOVIE 2",
          posterPath: "",
          releaseDate: Date(timeIntervalSince1970: 1000000000)
         ),
        Movie(id: 3,
          title: "TEST MOVIE 3",
          posterPath: "",
          releaseDate: Date(timeIntervalSince1970: 1500000000)
         )
    ]
}

class FailingHttpService: HttpService {
    
    class MockError: Error {}

    func executeRequest(url: URL) async throws -> Data {
        throw MockError()
    }
}

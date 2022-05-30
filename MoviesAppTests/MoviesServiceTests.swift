//
//  MoviesServiceTests.swift
//  MoviesServiceTests
//
//  Created by Andrés Ruiz on 28/5/22.
//


import AsyncPlus
import XCTest
@testable import MoviesApp

class MoviesServiceTests: XCTestCase {

    var moviesService: MoviesService!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Create a moviesService and inject the MockHttpService to it
        moviesService = MoviesService(httpService: MockHttpService())
    }

    // Test ApiEndpoint
    func testSearchMovies() async throws {

        attempt {
            return try await self.moviesService.searchMovies(query: "TEST")
        }.then {
            movies in
            XCTAssertGreaterThan(movies.count, 0)

            let movie = movies.first
            let movieMock = MockHttpService.testMovies.first!
            
            // Compare first movie from request result with mock
            XCTAssertNotNil(movie)
            XCTAssertEqual(movie?.id, movieMock.id)
            XCTAssertEqual(movie?.title, movieMock.title)
            XCTAssertEqual(movie?.posterPath, movieMock.posterPath)
            XCTAssertEqual(movie?.releaseDate, movieMock.releaseDate)
        }.catch { _ in }
        
    }
    
    // Test ImagesEndpoint
    func testGetPosterImage() async throws {
        
        attempt {
            return try await self.moviesService.getPosterImage(path: "/test.jpg", size: .original)
        }.then {
            image in
            XCTAssertNotNil(image)
        }.catch { _ in }
        
    }
    
}

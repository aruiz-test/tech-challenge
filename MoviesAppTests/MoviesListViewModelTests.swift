//
//  MoviesListViewModelTests.swift
//  MoviesAppTests
//
//  Created by Andrés Ruiz on 29/5/22.
//

import AsyncPlus
import XCTest

class MoviesListViewModelTests: XCTestCase {

    var moviesListViewModel: MoviesListViewModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Create a moviesService and inject the MockHttpService to it
        let moviesService = MoviesService(httpService: MockHttpService())
        
        // Create a MoviesListViewModel and inject the moviesService to it
        moviesListViewModel = MoviesListViewModel(apiService: moviesService)
    }

    func testPresentation() throws {
        // Test all the different public MoviesListViewModel presentation funcs and computed properties
        
        let index = IndexPath(row: 0, section: 0)

        // Before calling searchMovies, there should be no data
        XCTAssertFalse(moviesListViewModel.isFetchingData)
        XCTAssertEqual(moviesListViewModel.numberOfMovies, 0)
        XCTAssertNil(moviesListViewModel.movieTitle(for: index))
        XCTAssertNil(moviesListViewModel.movieYearFormatted(for: index))
        
        // Call searchMovies to start fetching data from the MoviesService
        moviesListViewModel.searchMovies(query: "TEST")
        
        // Immediatelly after we call searchMovies, isFetchingData should be true
        XCTAssertTrue(moviesListViewModel.isFetchingData)
        
        // The rest of presentation funcs and computed properties must be tested after MoviesService is done fetching data, which will invoke dataChanged callback
        moviesListViewModel.dataChanged = {
            XCTAssertGreaterThan(self.moviesListViewModel.numberOfMovies, 0)
            XCTAssertNotNil(self.moviesListViewModel.movieTitle(for: index))
            XCTAssertNotNil(self.moviesListViewModel.movieYearFormatted(for: index))
        }

    }
    
    func testDataChangedCallback() throws {
        
        let dataExpectation = XCTestExpectation(description: "Test dataChanged callback")
        let errorExpectation = XCTestExpectation(description: "Test dataError callback. Shouldn't be fulfilled")
        errorExpectation.isInverted = true // Inverted because we expect it NOT to be fulfilled

        moviesListViewModel.dataChanged = {
            dataExpectation.fulfill()
        }
        moviesListViewModel.dataError = { _ in
            errorExpectation.fulfill()
        }
        moviesListViewModel.searchMovies(query: "TEST")

        // Only dataExpectation should be fulfilled before timeout
        wait(for: [dataExpectation, errorExpectation], timeout: 1.0)
    }
    
    func testDataErrorCallback() throws {
        
        // Create an expectation to test the moviesListViewModel (that uses MockHttpService) fetches data just fine
        let workingExpectation = XCTestExpectation(description: "Test dataError callback. This shoudln't be fulfilled")
        workingExpectation.isInverted = true // Inverted because we expect it NOT to be fulfilled
        
        let workingViewModel = moviesListViewModel
        workingViewModel?.dataError = { _ in
            workingExpectation.fulfill() // This should never be called
        }
        workingViewModel?.searchMovies(query: "TEST")

        // Create a failingViewModel that uses FailingHttpService and an expectation to test that it fails to fetch data
        let failingExpectation = XCTestExpectation(description: "Test dataError callback. This should be fulfilled")

        let failingService = MoviesService(httpService: FailingHttpService())
        let failingViewModel = MoviesListViewModel(apiService: failingService)
        failingViewModel.dataError = { error in
            XCTAssertNotNil(error as? FailingHttpService.MockError)
            failingExpectation.fulfill() // This should be called
        }
        failingViewModel.searchMovies(query: "TEST")
        
        // Only workingExpectation should be fulfilled before timeout
        wait(for: [workingExpectation, failingExpectation], timeout: 1.0)
    }

}




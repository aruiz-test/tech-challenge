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

    func testPresentationMethods() throws {
        // TODO: Implement
    }
    
    func testDataChangedCallback() throws {
        let dataExpectation = XCTestExpectation(description: "Test dataChanged callback")
        
        let errorExpectation = XCTestExpectation(description: "Test dataError callback. Shouldn't be fulfilled")
        errorExpectation.isInverted = true


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
        let workingExpectation = XCTestExpectation(description: "Test dataError callback. This shoudln't be fulfilled")
        workingExpectation.isInverted = true
        
        let workingViewModel = moviesListViewModel
        
        workingViewModel?.dataError = { _ in
            workingExpectation.fulfill() // This should never be called
        }
        
        let failingExpectation = XCTestExpectation(description: "Test dataError callback. This should be fulfilled")

        let failingService = MoviesService(httpService: FailingHttpService())
        let failingViewModel = MoviesListViewModel(apiService: failingService)

        failingViewModel.dataError = { error in
            XCTAssertNotNil(error as? FailingHttpService.MockError)
            failingExpectation.fulfill()
        }
        
        failingViewModel.searchMovies(query: "TEST")

        // Only workingExpectation should be fulfilled before timeout
        wait(for: [workingExpectation, failingExpectation], timeout: 1.0)
    }

}




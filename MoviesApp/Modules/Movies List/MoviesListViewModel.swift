//
//  MoviesListViewModel.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 29/5/22.
//

import Foundation
import AsyncPlus

class MoviesListViewModel: NSObject {
    
    private let apiService: MoviesService!

    // ViewControllers can bind to these closures get notified about data changes and errors
    var dataChanged = { () -> () in }
    var dataError   = { (error: Error) -> () in }
    
    private var fetchingData = false

    private var movies: [Movie] = [] {
        didSet {
            self.dataChanged()
        }
    }
    
    init(apiService: MoviesService = MoviesService()) {
        self.apiService = apiService
        super.init()
    }
    
    private func fetchData(query: String) {
        //if movies.isNotEmpty && fetchingData == false { return }
        self.fetchingData = true
        
        attempt {
            return try await self.apiService.searchMovies(query: query)
        }.then {
            movies in
            self.movies = movies
        }.catch {
            error in
            self.dataError(error)
        }.finally {
            self.fetchingData = false
        }
    }

    
    
    // MARK: - Presentation
    func searchMovies(query: String) {
        fetchData(query: query)
    }

    var isFetchingData: Bool {
        return self.fetchingData
    }

    
    var numberOfMovies: Int {
        return movies.count
    }
        
    func movieTitle(for indexPath: IndexPath) -> String? {
        guard movies.count > indexPath.row else {
            return nil
        }
        return movies[indexPath.row].title
    }
    
    func movieYearFormatted(for indexPath: IndexPath) -> String? {
        guard movies.count > indexPath.row else {
            return nil
        }
        let date = movies[indexPath.row].releaseDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"

        return date.formatted(date: .numeric, time: .omitted) // TODO: Return the year only
    }

}

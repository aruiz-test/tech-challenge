//
//  MoviesListViewModel.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 29/5/22.
//

import Foundation
import AsyncPlus
import UIKit

class MoviesListViewModel: NSObject {
    
    private let moviesService: MoviesService!

    // ViewControllers can bind to these closures get notified about data changes and errors
    var dataChanged = { (isNewSearch: Bool) -> () in }
    var dataError   = { (error: Error) -> () in }
    
    private var fetchingData = false
    private var lastQuery    = ""
    private var currentPage  = 1
    private var totalPages   = 0

    private var movies: [Movie] = [] {
        didSet {
            // Call on main thread so that UI updates are safe
            DispatchQueue.main.async {
                // If fetchingData and movies is empty, it's a new search
                self.dataChanged(self.fetchingData && self.movies.isEmpty)
            }
        }
    }
    
    init(moviesService: MoviesService = MoviesService()) {
        self.moviesService = moviesService
        super.init()
    }
    
    private func fetchData(query: String) {
        if fetchingData { return }
        
        fetchingData = true
        lastQuery = query

        attempt {
            return try await self.moviesService.searchMovies(query: query, page: self.currentPage)
        }.then {
            response in
            self.totalPages = response.totalPages
            self.movies.append(contentsOf: response.results)
        }.catch {
            error in
            self.dataError(error)
        }.finally {
            self.fetchingData = false
        }
    }
    
    
    // MARK: - Presentation
    func searchMovies(query: String) {
        
        // New search -> Reset movies and page
        currentPage = 1
        movies = []

        fetchData(query: query)
    }
    
    func getNextPage() {
        currentPage += 1
        fetchData(query: lastQuery)
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
        
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-mm-dd"

        guard movies.count > indexPath.row,
              let dateString = movies[indexPath.row].releaseDate,
              dateString.isNotEmpty,
              let date = formatter.date(from: dateString)
        else {
            return nil
        }
        
        return "\(date.get(.year))"
    }
    
    func downloadMoviePosterImage(for indexPath: IndexPath, completion: @escaping (UIImage?) -> ()) {
        
        guard movies.count > indexPath.row,
              let posterPath = movies[indexPath.row].posterPath
        else { return }
        
        // Start getPosterImage request
        attempt {
            return try await self.moviesService.getPosterImage(path: posterPath, size: .w185)
        }.then {
            image in
            // Pass downloaded image to completion callback and let the caller handle UI work
            completion(image)
            
        }.catch {
            error in
            print(error)
        }
        
    }

}

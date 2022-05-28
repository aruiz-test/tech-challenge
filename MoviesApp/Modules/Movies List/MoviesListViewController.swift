//
//  MoviesListViewController.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 28/5/22.
//

import UIKit

class MoviesListViewController: UITableViewController {

    // MARK: Properties
    private let reuseIdentifierMovie = "MovieCellReuseIdentifier"
    private let moviesService = MoviesService()
    private var movies: [Movie] = []

    // MARK: - UIViewController + lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.title = "Search movies"
        
        tableView.register(MoviesListTableViewCell.self, forCellReuseIdentifier: reuseIdentifierMovie)
        
        // Start fetching data to fill the table view
        fetchData()
    }
    
    func fetchData() {
        
        Task.init {
            do {
                movies = try await moviesService.searchMovies(query: "Star Wars")
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MoviesListViewController {
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // Avoid highlighting cells on touch, as there is no associated action and we should avoid giving users
        // a misleading visual feedback to touches
        return false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierMovie, for: indexPath)
        cell.textLabel?.text        = nil
        cell.detailTextLabel?.text  = nil
        cell.imageView?.image       = nil

        let movie = movies[indexPath.row]
        
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = movie.releaseDate.formatted() // TODO: Show the year only
        cell.imageView?.image = UIImage(named: "movie_default_icon") // TODO: Request poster asynchronously
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}


// MARK: - Cell subclass
class MoviesListTableViewCell : UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

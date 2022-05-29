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
    private var viewModel: MoviesListViewModel = MoviesListViewModel()


    // MARK: - UIViewController + lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.title = "Search movies"
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.register(MoviesListTableViewCell.self, forCellReuseIdentifier: reuseIdentifierMovie)
        
        // Bind viewModel callbacks
        viewModel.dataChanged = configureView
        viewModel.dataError   = showError(_:)
        
        // Start fetching data to fill the table view
        viewModel.searchMovies(query: "Star Wars") // TODO: Pass a query from search bar
    }
    
    private func configureView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func showError(_ error: Error) {
        // TODO: Implement. Show alert with Retry button
        print(error)
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
        return max(1, viewModel.numberOfMovies) // At least one cell to show the loading message
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue reusable cell and reset everything
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierMovie, for: indexPath)
        cell.textLabel?.text        = nil
        cell.detailTextLabel?.text  = nil
        cell.imageView?.image       = nil
        cell.accessoryType          = .none

        // Show a loading message if data isn't ready yet. Otherwise, fill the cell with viewModel's data
        if viewModel.isFetchingData {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            cell.accessoryView      = activityIndicator
            cell.textLabel?.text    = "Searching movies..."
        } else {
            cell.textLabel?.text = viewModel.movieTitle(for: indexPath)
            cell.detailTextLabel?.text = viewModel.movieYearFormatted(for: indexPath)
            cell.imageView?.image = UIImage(named: "movie_default_icon")
            // TODO: Start actual image async request here. Or maybe create a viewModel method named configureCell that will do everything
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}


// MARK: - Cell subclass to be able to use the .subtitle style
class MoviesListTableViewCell : UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

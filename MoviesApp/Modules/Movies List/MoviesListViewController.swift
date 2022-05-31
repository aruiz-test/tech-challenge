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

    private var lastNumberOfRows: Int = 0

    // MARK: - UIViewController + lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style settings
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        self.title = "Search movies"
        
        // Add and setup a search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = searchController
        
        // Setup the table view
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.register(MoviesListTableViewCell.self, forCellReuseIdentifier: reuseIdentifierMovie)
        
        // Bind viewModel callbacks
        viewModel.dataChanged = configureView
        viewModel.dataError   = showError(_:)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Focus the search bar when the view appears
        self.navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
    
    private func configureView(isNewSearch: Bool) {
        
        // New search: Delete old table view rows
        if isNewSearch {
            let indexPathsToDelete = (0 ..< lastNumberOfRows).map {
                IndexPath(row: $0, section: 0)
            }
            if indexPathsToDelete.isNotEmpty {
                tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
            }
            lastNumberOfRows = 0
            setLoadingFooter()
        }
        
        // New page of old search: Insert new table view rows
        else {
            let indexPathsToInsert = (lastNumberOfRows ..< viewModel.numberOfMovies).map {
                IndexPath(row: $0, section: 0)
            }
            if indexPathsToInsert.isNotEmpty {
                self.tableView.insertRows(at: indexPathsToInsert, with: .automatic)
                setLoadingFooter()
            } else {
                setNoMoreResultsFooter()
            }
            lastNumberOfRows = viewModel.numberOfMovies
        }
    }
    
    private func setLoadingFooter() {
        let activityIndicator = UIActivityIndicatorView(style: .medium); activityIndicator.startAnimating()
        tableView.tableFooterView = activityIndicator
    }
    
    private func setNoMoreResultsFooter() {
        let tableViewFooter = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        tableViewFooter.text = "  No more results 🎬"
        tableViewFooter.textAlignment = .center
        tableView.tableFooterView = tableViewFooter
    }
    
    private func showError(_ error: Error) {
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
        // Return at least one row to show the loading message
        return viewModel.numberOfMovies
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

        // Fill cell properties with data from viewModel
        cell.textLabel?.text = viewModel.movieTitle(for: indexPath)
        cell.detailTextLabel?.text = viewModel.movieYearFormatted(for: indexPath)
        cell.imageView?.image = UIImage(named: "movie_default_icon")
        
        // Start async download of the poster image
        viewModel.downloadMoviePosterImage(for: indexPath) { image in
            UIView.transition(
                with: cell.imageView!,
                duration: 0.35,
                options: .transitionCrossDissolve,
                animations: { cell.imageView!.image = image }
            )
        }
        
        // If this is the last cell, request next page
        if indexPath.row + 1 == viewModel.numberOfMovies {
            viewModel.getNextPage()
        }
                        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}


// Cell subclass to be able to use the .subtitle style and other customisations
class MoviesListTableViewCell : UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect(x: 0, y: 0, width: 80, height: 100)
    }
}


// MARK: - UISearchBarDelegate
extension MoviesListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.isNotEmpty else { return }
        // Start a new search when the search button is clicked
        viewModel.searchMovies(query: searchText)
    }
}

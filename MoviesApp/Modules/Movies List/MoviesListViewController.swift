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
    
    private func configureView() {
        self.tableView.reloadSections(IndexSet(integer:0), with: .automatic)
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
        return viewModel.isFetchingData ? 1 : viewModel.numberOfMovies
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
            viewModel.downloadMoviePosterImage(for: indexPath) {
                image in
                // Update UI on main thread
                DispatchQueue.main.async {
                    //guard let imageView = cell.imageView else { return }
                    UIView.transition(
                        with: cell.imageView!,
                        duration: 0.35,
                        options: .transitionCrossDissolve,
                        animations: { cell.imageView!.image = image }
                    )
                }
            }
        }
        
        // TODO: Handle no-results case
        
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


// MARK: - UISearchBarDelegate
extension MoviesListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.isNotEmpty else { return }
        viewModel.searchMovies(query: searchText)
        configureView()
    }
}

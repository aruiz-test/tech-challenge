//
//  MoviesListViewController.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 28/5/22.
//

import UIKit

class MoviesListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .systemBackground
        self.title = "Search movies"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCellReuseIdentifier")
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MoviesListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellReuseIdentifier", for: indexPath)
        cell.textLabel?.text = "Test Movie \(indexPath.row)"
        return cell
    }
}

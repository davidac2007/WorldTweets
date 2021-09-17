//
//  HomeViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 14/09/21.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift

class HomeViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private let cellId = "TweetTableViewCell"
    private var dataSource = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts()
    }
    
    private func setupUI(){
        // Assign data source
        // Register cell
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        
    }
    
    private func getPosts(){
        // Show loading
        SVProgressHUD.show()
        // Consume web service
        SN.get(endpoint: Endpoints.getPosts) { (result: SNResultWithEntity<[Post], ErrorResponse>) in
            
            switch result {
                // Success login
                case .success(let posts):
                    self.dataSource = posts
                    self.tableView.reloadData()
            
                // Unknown errors
                case .error(let error):
                    NotificationBanner(title: "Error",
                                       subtitle: error.localizedDescription,
                                       style: .danger).show()
                   
                // Errrors from the server
                case .errorResult(let entity):
                    NotificationBanner(title: "Error",
                                    subtitle: entity.error,
                                    style: .warning).show()
            }
            
        }
    }
}


extension HomeViewController: UITableViewDataSource{
    // Total number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    // Set up cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        if let cell = cell as? TweetTableViewCell {
            cell.setupCellWith(post: dataSource[indexPath.row])
        }
        return cell
    }
    
}

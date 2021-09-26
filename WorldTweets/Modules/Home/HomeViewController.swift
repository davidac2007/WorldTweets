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
    
    let currentEmail = UserDefaults.standard.string(forKey: "email")

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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        
        
    }
    
    private func getPosts(){
        // Show loading
        print("Loading tweets")
        SVProgressHUD.show()
        // Consume web service
        SN.get(endpoint: Endpoints.getPosts) { (result: SNResultWithEntity<[Post], ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            
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
    
    private func deletePostAt(indexPath: IndexPath){
        // Show loading
        SVProgressHUD.show()
        
        // Get post ID to be deleted
        let postId = dataSource[indexPath.row].id
        
        // Call API to delete post
        let endpoint = Endpoints.delete + postId
        
        SN.delete(endpoint: endpoint) { (result: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            
            switch result {
                // Success login
                case .success(_):
                
                    // Delete post from data source
                self.dataSource.remove(at: indexPath.row)
                    // Delete cell from table
                self.tableView.deleteRows(at: [indexPath], with: .left)
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

extension HomeViewController: UITableViewDelegate{
    // Actions that can be executed for each cell
   
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAcrtion = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Delete") { (_, _) in
            // Deleted tweet
            self.deletePostAt(indexPath: indexPath)
        }
        return [deleteAcrtion]
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.dataSource[indexPath.row].author.email == currentEmail
    }
}


extension HomeViewController: UITableViewDataSource{
    // Total number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SVProgressHUD.show()
        return dataSource.count
    }
    
    // Set up cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        SVProgressHUD.dismiss()
        
        if let cell = cell as? TweetTableViewCell {
            cell.setupCellWith(post: dataSource[indexPath.row])
        }
        return cell
    }
    
}

//
//  AllNewsViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 1.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit

class AllNewsViewController: UIViewController {

    @IBOutlet weak var newsTableView: UITableView!
    
    var currentPage: Int = 1
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        newsTableView.addSubview(refreshControl)
        
        loadNewsForPage()
        
        // Observe for changes in the interests of the user
        UserDefaults.standard.addObserver(self, forKeyPath: "interests", options: .new, context: nil)
    }
}

// MARK: Helper Functions
extension AllNewsViewController {
    @objc func handleRefresh() {
        // reset the page count
        currentPage = 1
        
        News.shared.getAllNews(page: currentPage) { (news) in
            News.shared.allNews = news?.articles ?? []
            
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func loadNewsForPage() {
        News.shared.getAllNews(page: currentPage) { (news) in
            News.shared.allNews += news?.articles ?? []
            
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
            }
        }
    }
}

// MARK: UITableView
extension AllNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return News.shared.allNews.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == News.shared.allNews.count {
            let cell = newsTableView.dequeueReusableCell(withIdentifier: Constants.TableCell.allNewsLoading, for: indexPath)
            
            currentPage += 1
            
            loadNewsForPage()
            
            return cell
        }
        
        let cell = newsTableView.dequeueReusableCell(withIdentifier: Constants.TableCell.allNews, for: indexPath) as! AllNewsTableViewCell
        
        cell.titleLabel.text = News.shared.allNews[indexPath.row].title
        cell.descLabel.text = News.shared.allNews[indexPath.row].description
        
        if let url = URL(string: News.shared.allNews[indexPath.row].urlToImage ?? "") {
            cell.newsImage.load(url: url)
        } else {
            cell.newsImage.image = UIImage(named: "Placeholder Image")
        }
        
        return cell
    }
    
    
}

// MARK: User Defaults Observation Handler
extension AllNewsViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        handleRefresh()
    }
}
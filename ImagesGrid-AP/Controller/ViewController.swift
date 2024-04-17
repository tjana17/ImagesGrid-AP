//
//  ViewController.swift
//  ImagesGrid-AP
//
//  Created by Janarthanan Kannan on 17/04/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let network = NetworkManager.shared
    
    var posts: [ResponseModel] = []
    
    let cellIdentifier = "ImageCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ///Registering the collectionview cell.
        collectionView.register(UINib(nibName: cellIdentifier, bundle: .main), forCellWithReuseIdentifier: cellIdentifier)
        
        network.posts(query: "100") { [weak self] posts, error in
            
            if let error = error {
                print("Error: ", error)
                return
            }
            
            guard let self = self else { return }
            ///Posts are success reload the collection view
            self.posts = posts!
            debugPrint("Posts == \(self.posts)")
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

}

//MARK: - UICollectionView DataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        ///Dequeue the cell with identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, 
                                                      for: indexPath) as! ImageCell
        
        let post = posts[indexPath.item]
        cell.title = post.title
        
        /// Clearing the image first
        cell.image = nil
        
        ///Assign the identifier for cell using cache.
        let representedIdentifier = post.id
        cell.representedIdentifier = representedIdentifier
        
        ///Get the image data
        func image(data: Data?) -> UIImage? {
            if let data = data {
                return UIImage(data: data)
            }
            return UIImage(systemName: "picture")
        }
        
        ///Download the image from URL.
        network.image(post: post.thumbnail) { data, error in
            let img = image(data: data)
            DispatchQueue.main.async {
                ///If identifiers are same append the image
                if (cell.representedIdentifier == representedIdentifier) {
                    cell.image = img
                }
            }
        }
        
        ///Customize the cell.
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }
}

//MARK: - UICollectionView Flowlayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        ///Setting the cell size for 3x3 grid.
        return CGSize(width: (self.collectionView.frame.width/3.0) - 10,
                      height: (self.collectionView.frame.height/4.0))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

//MARK: - UICollectionView Delegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /// Open the browser for tapping cell image.
        let post = posts[indexPath.item]
        if let url = URL(string: post.coverageURL) {
            UIApplication.shared.open(url)
        }
    }
}

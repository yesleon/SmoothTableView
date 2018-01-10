//
//  TableViewController.swift
//  SmoothTableView
//
//  Created by Li-Heng Hsu on 10/01/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    private var catURLs: [URL] = [
        URL(string: "https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg")!,
        URL(string: "https://www.bluecross.org.uk/sites/default/files/assets/images/124044lpr.jpg")!,
        URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Cat03.jpg/1200px-Cat03.jpg")!,
        URL(string: "https://www.pets4homes.co.uk/images/articles/771/large/cat-lifespan-the-life-expectancy-of-cats-568e40723c336.jpg")!,
        URL(string: "https://static.pexels.com/photos/126407/pexels-photo-126407.jpeg")!,
        URL(string: "https://news.nationalgeographic.com/content/dam/news/photos/000/755/75552.ngsversion.1422285553360.adapt.1900.1.jpg")!,
        URL(string: "https://metrouk2.files.wordpress.com/2017/10/523733805-e1508406361613.jpg?quality=80&strip=all")!,
        URL(string: "https://cdn-images-1.medium.com/max/1600/1*mONNI1lG9VuiqovpnYqicA.jpeg")!,
        URL(string: "https://fthmb.tqn.com/ch8UN_4axgisolBU1tzo_2UUrLs=/3466x2599/filters:fill(auto,1)/GettyImages-459759125-584b87dc3df78c491ed25012.jpg")!,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        tableView.rowHeight = 500
    }

}

extension TableViewController: URLSessionDelegate {
    
}

// MARK: - UITableViewDataSourcePrefetching
extension TableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let request = URLRequest(url: catURLs[indexPath.row])
            if URLSession.shared.configuration.urlCache!.cachedResponse(for: request) == nil {
                URLSession.shared.dataTask(with: request).resume()
            }
        }
    }
    
}

// MARK: - UITableViewDataSource
extension TableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catURLs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let request = URLRequest(url: catURLs[indexPath.row])
        func didGetData(_ data: Data) {
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }
            let options = [
                kCGImageSourceCreateThumbnailWithTransform : true,
                kCGImageSourceCreateThumbnailFromImageAlways : true,
                kCGImageSourceThumbnailMaxPixelSize : 1024
            ] as CFDictionary
            guard let scaledImageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return }
            DispatchQueue.main.async {
                cell.imageView?.image = UIImage(cgImage: scaledImageRef)
            }
        }
        if let response = URLSession.shared.configuration.urlCache?.cachedResponse(for: request) {
            DispatchQueue.global().async {
                didGetData(response.data)
            }
        } else {
            cell.imageView?.image = nil
            URLSession.shared.dataTask(with: request) { (data, response, _) in
                guard let data = data, let response = response else { return }
                URLSession.shared.configuration.urlCache?.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                didGetData(data)
            }.resume()
        }
        return cell
    }
    
}


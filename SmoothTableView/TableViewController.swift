//
//  TableViewController.swift
//  SmoothTableView
//
//  Created by Li-Heng Hsu on 10/01/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    /// URLs of large resolution images.
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
        URL(string: "https://static.pexels.com/photos/54632/cat-animal-eyes-grey-54632.jpeg")!,
        URL(string: "https://www.proplanveterinarydiets.com/media/2473/purina_ppvd_ppd_con_dsk_carousel_cat_om.jpg")!,
        URL(string: "https://media1.britannica.com/eb-media/47/158247-050-70FEB8D4.jpg")!,
        URL(string: "https://vignette.wikia.nocookie.net/animal-jam-clans-1/images/b/bd/Siamese-cat.jpg/revision/latest?cb=20161006015008")!,
        URL(string: "https://cdn-images-1.medium.com/max/1600/1*6wMP9_oZ7HEa_Mjau8nBpQ.jpeg")!,
        URL(string: "https://fthmb.tqn.com/UysbMNXu5oQb54kHjOj6Kq-WIBs=/2121x1414/filters:fill(auto,1)/Calicocat-GettyImages-638741138-5931a1125f9b589eb48ff29d.jpg")!,
        URL(string: "https://peopledotcom.files.wordpress.com/2017/12/smush-the-cat-1.jpg")!,
        URL(string: "https://thecatsite.com/attachments/06-japan-cat-snow-jpg.200900/")!
    ]
    
    private lazy var dataPrefetcher = DataPrefetcher(requestForIndexPath: { URLRequest(url: self.catURLs[$0.row]) }) 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = dataPrefetcher
        tableView.rowHeight = 500
    }

}

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        dataPrefetcher.cancel([URLRequest(url: catURLs[indexPath.row])])
    }
    
}

// MARK: - UITableViewDataSource
extension TableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catURLs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cleanup the cell first or the old image would still be there before we update it asynchronously.
        cell.imageView?.image = nil
        
        // Retrieve image data from cachedResponse.
        dataPrefetcher.request(catURLs[indexPath.row]) { data in
            
            // Using CGImage to resize the image since it would not block the main thread like UIImage.
            guard let thumbnailCGImage = CGImage.makeThumbnail(data: data, maxPixelSize: 1024) else { return }
            DispatchQueue.main.async {
                
                // Check if the cell has not been reused yet.
                guard indexPath == tableView.indexPath(for: cell) else { return }
                cell.imageView?.alpha = 0
                cell.imageView?.image = UIImage(cgImage: thumbnailCGImage)
                UIView.animate(withDuration: 0.15) {
                    cell.imageView?.alpha = 1
                }
            }
        }
        
        // Cell should be returned as soon as possible, so all the consuming tasks should be on background threads,
        // except for UIKit tasks.
        return cell
    }
    
}


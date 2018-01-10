//
//  DataFetcher.swift
//  SmoothTableView
//
//  Created by Li-Heng Hsu on 10/01/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

class DataFetcher: NSObject, UITableViewDataSourcePrefetching {
    
    let requestForIndexPath: (IndexPath) -> URLRequest
    let session = URLSession(configuration: .default)
    
    init(cache: URLCache = .shared, requestForIndexPath: @escaping (IndexPath) -> URLRequest) {
        self.requestForIndexPath = requestForIndexPath
        self.session.configuration.urlCache = cache
    }
    
    func request(_ url: URL, handler: @escaping (Data) -> Void) {
        request(URLRequest(url: url), handler: handler)
    }
    
    func request(_ request: URLRequest, handler: @escaping (Data) -> Void) {
        let session = self.session
        if let response = session.configuration.urlCache?.cachedResponse(for: request) {
            DispatchQueue.global().async {
                handler(response.data)
            }
            
            // Or send the request and save it if there is no cachedResponse.
        } else {
            session.dataTask(with: request) { (data, response, _) in
                guard let data = data, let response = response else { return }
                session.configuration.urlCache?.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                handler(data)
            }.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let session = self.session
        for indexPath in indexPaths {
            
            // Send request and save it if there is no cachedResponse already.
            let request = requestForIndexPath(indexPath)
            if session.configuration.urlCache?.cachedResponse(for: request) == nil {
                // This would save the request to URLCache.shared.
                session.dataTask(with: request).resume()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        session.getTasksWithCompletionHandler { (tasks, _, _) in
            for indexPath in indexPaths {
                tasks.filter { $0.originalRequest == self.requestForIndexPath(indexPath) }.forEach { $0.cancel() }
            }
        }
    }
    
}

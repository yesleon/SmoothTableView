//
//  DataPrefetcher.swift
//  SmoothTableView
//
//  Created by Li-Heng Hsu on 10/01/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

class DataPrefetcher: NSObject {
    
    private let requestForIndexPath: (IndexPath) -> URLRequest
    lazy var session = URLSession(configuration: .default)
    
    init(requestForIndexPath: @escaping (IndexPath) -> URLRequest) {
        self.requestForIndexPath = requestForIndexPath
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
        } else {
            session.dataTask(with: request) { (data, response, _) in
                guard let data = data, let response = response else { return }
                session.configuration.urlCache?.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                handler(data)
            }.resume()
        }
    }
    
    func cancel(_ requests: [URLRequest]) {
        session.getTasksWithCompletionHandler { (tasks, _, _) in
            for request in requests {
                tasks.filter { $0.originalRequest == request }.forEach { $0.cancel() }
            }
        }
    }
    
}

extension DataPrefetcher: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let session = self.session
        for indexPath in indexPaths {
            let request = requestForIndexPath(indexPath)
            if session.configuration.urlCache?.cachedResponse(for: request) == nil {
                session.dataTask(with: request).resume()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        let requests = indexPaths.map { self.requestForIndexPath($0) }
        cancel(requests)
    }
    
}

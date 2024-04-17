//
//  NetworkManager.swift
//  ImagesGrid-AP
//
//  Created by Janarthanan Kannan on 17/04/24.
//

import Foundation

enum NetworkManagerError: Error {
    case badResponse(URLResponse?)
    case badData
    case badLocalURL
}

class NetworkManager {
    
    static var shared = NetworkManager()
    
    ///Store the images in NSCache Manager
    private var images = NSCache<NSString, NSData>()
    
    let session: URLSession
    
    ///Initialize
    init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    /// Build the Base URL of the API Call.
    /// - Returns: Returns the domain URL.
    private func components() -> URLComponents {
        var comp = URLComponents()
        comp.scheme = "https"
        comp.host = "acharyaprashant.org"
        return comp
    }
    
    private func request(url: URL) -> URLRequest {
        let request = URLRequest(url: url)
        return request
    }
    
    
    /// Calling the API
    /// - Parameters:
    ///   - query: In query we are passing the limit of the items.
    ///   - completion: Assign the response into the Model Class.
    func posts(query: String, completion: @escaping([ResponseModel]?, Error?) -> (Void)) {
        var comp = components()
        comp.path = "/api/v2/content/misc/media-coverages"
        comp.queryItems = [
            URLQueryItem(name: "limit", value: query)
        ]
        
        let req = request(url: comp.url!)
        
        let task = session.dataTask(with: req) { data, response, error in
            ///Error
            if let error = error {
                completion(nil, error)
                return
            }
            
            ///If response gets failure status codes.
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(nil, NetworkManagerError.badResponse(response))
                return
            }
            
            ///If bad data returns
            guard let data = data else {
                completion(nil, NetworkManagerError.badData)
                return
            }
            
            ///Success - Response
            do {
                let response = try JSONDecoder().decode([ResponseModel].self, from: data)
                completion(response, nil)
            } catch let error {
                completion(nil, error)
            }
            
        }
        task.resume()
    }
    
    
    /// This function is to Download images from URL.
    /// - Parameters:
    ///   - imageURL: imageURL represents the image URL.
    ///   - completion: returns the image data.
    private func download(imageURL: URL, completion: @escaping(Data?, Error?) -> (Void)) {
        ///Image using Cache
        if let imageData = images.object(forKey: imageURL.absoluteString as NSString) {
            print("using cached images...")
            completion(imageData as Data, nil)
            return
        }
        
        /// Session Task to Download.
        let task = session.downloadTask(with: imageURL) { localURL, response, error in
            
            ///Error
            if let error = error {
                completion(nil, error)
                return
            }
            
            ///If response gets failure status codes.
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(nil, NetworkManagerError.badResponse(response))
                return
            }
            
            ///If bad data localURL
            guard let localURL = localURL else {
                completion(nil, NetworkManagerError.badLocalURL)
                return
            }
            
            ///Success - Response
            do {
                let data = try Data(contentsOf: localURL)
                ///Storing images in Cache.
                self.images.setObject(data as NSData, forKey: imageURL.absoluteString as NSString)
                completion(data, nil)
            } catch let error {
                completion(nil, error)
            }
            
        }
        task.resume()
        
    }
    
    
    /// This function is to build the URL from the API Response
    /// - Parameters:
    ///   - post: Thumbnail object from the response
    ///   - completion: Returns the image data.
    func image(post: Thumbnail, completion: @escaping(Data?, Error?) -> (Void)) {
        ///Build the image URL from thumbnail object.
        let domain = post.domain
        let basePath = post.basePath
        let qualities = post.qualities.last ?? 30
        let key = post.key
        let imgURL = domain + "/" + basePath + "/" + "\(qualities)" + "/" + key
        
        let url = URL(string: imgURL)!
        download(imageURL: url, completion: completion)
    }
    
    
}

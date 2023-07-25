//
//  Endpoint.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 20/07/2023.
//

import Foundation


/**
 - Description: A nice protocol that represents an endpoint
 */
protocol Endpoint {
    var base: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Encodable? { get }
    var queryParameters: [URLQueryItem] { get }
    var port: Int? { get }
    var queryItems: [URLQueryItem] { get }
}

/**
 - Description: Here we extendes the Requestable protocol with convenient functions/properties
 */
extension Endpoint {
    
    private var url: URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = base
        components.path = path
        components.queryItems = queryParameters
        components.port = port
        components.queryItems = queryItems

        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        print("url: \(url)")
        return url
    }

    var urlRequest: URLRequest {
            var request = URLRequest(url: self.url)
            request.httpMethod = self.method.rawValue
            
            self.headers.forEach { (k, v) in
                request.setValue(v, forHTTPHeaderField: k)
            }
            
            if self.method == HTTPMethod.post || self.method == .put {
                if let body = self.body {
                    let encoder: JSONEncoder = JSONEncoder()
                    encoder.keyEncodingStrategy = .convertToSnakeCase
                    
                    request.httpBody = try? encoder.encode(body)
                }
            }
            
            return request
        }
}

/**
 - Description: List of http methods. We could have used the type Strings,
 but it is always nice to have them statically typed for exhaustivity when switching over it
 */
enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
}


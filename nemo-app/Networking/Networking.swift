//
//  Networking.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 20/07/2023.
//

import Foundation

/**
 - Description: Networking error represents error returned by the networking error
 */
enum NetworkingError: Error {
    case networkError
    case decodingError
    case notfoundError
    case apiError
}


/**
 - Description: Networking is a simple object that abstract the API calls.
 */
@MainActor
struct Networking {
    
    let urlSessionConfiguration: URLSessionConfiguration
    
    init(urlSessionConfiguration: URLSessionConfiguration = .default) {
        self.urlSessionConfiguration = urlSessionConfiguration
    }
    
    /**
     - Description: Performs a request for a given request.
        It is generic over any decodable type.
        Note that the compiler will need a type hint to correctly infer the type of the generic object T when the method is expended
     */
    func performRequest<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder = JSONDecoder()) async ->  Result<T, NetworkingError>  {
        
        do {
            // run the request
            let (data, response) = try await URLSession(configuration: self.urlSessionConfiguration).data(for: endpoint.urlRequest)

            // check the status code
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.networkError)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return .failure(.apiError)
            }

            // decode the response data
            let result = try? decoder.decode(T.self, from: data)
            
            // check the object got decoded properly
            guard let result = result else {
                return .failure(.decodingError)
            }
            
            // return the object as success
            return .success(result)
        } catch {
            return .failure(.networkError)
        }
    }
}

//
//  NetworkLayer.swift
//
//  Created by Diego Barroso on 20.11.19.
//  Copyright © 2019 Diego Jerez Barroso. All rights reserved.
//

import Foundation

public typealias NetworkResult<T: Decodable> = (Result<T, Error>) -> Void

/// Wrapper for URLSession
public class NetworkLayer {
    
    enum ValidationResult {
        case success
        case failure(Error)
    }
    
    public static func requestDecodable<T: Decodable>(router: EndpointRouter,
                                               decoder: JSONDecoder = JSONDecoder(),
                                               completion: @escaping NetworkResult<T>) {
        
        guard let urlRequest = router.urlRequest else {
            
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        launchDataTask(urlRequest: urlRequest) { (result) in
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                
                do {
                    let responseObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(responseObject))
                } catch let error {
                    print("Error Request NetworkLayer")
                    completion(.failure(error))
                }
            }
        }
    }
    
    private static func launchDataTask(urlRequest: URLRequest,
                                       completion: @escaping (Result<Data, Error>) -> Void) {
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            // 1. Check for any errors
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            // 2. Validate the response
            
            switch self.validation(response: response, data: data) {
            case .success:
                break
                
            case .failure(let error):
                completion(.failure(error))
                return
            }
            
            // 3. Extract the JSON
            
            guard let data = data else {
                
                print("Error unwrapping data")
                
                let error = NSError()
                completion(.failure(error))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    private static func validation(response: URLResponse?,
                                  data: Data?) -> NetworkLayer.ValidationResult {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            
            print("Error casting to HTTPURLResponse")
            
            let error = NSError()
            return .failure(error)
        }

        switch httpResponse.statusCode {
        case 200..<400:
            return .success

        default:
            let httpError = HttpError.map(statusCode: httpResponse.statusCode, data: data)
            return .failure(httpError)
        }
    }
    
    
}

enum NetworkError: Error {
    
    case invalidURL
}

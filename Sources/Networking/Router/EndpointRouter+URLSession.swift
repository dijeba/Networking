//
//  EndpointRouter+URLSession.swift
//
//  Created by Diego Barroso on 20.11.19.
//  Copyright © 2019 Diego Jerez Barroso. All rights reserved.
//

import Foundation

extension EndpointRouter {
    
    // MARK: - Properties
    
    /// Get the generated URLRequest with all necessary information (Get only)
    public var urlRequest: URLRequest? {
        
        guard let url = URL(string: self.baseURL) else {
            return nil
        }
        
        return self.getUrlRequest(with: url, headers: self.httpHeaders)
    }
    
    public func getUrlRequest(with url: URL, headers: [String: String]? = nil) -> URLRequest? {
        
        var urlRequest             = URLRequest(url: url.appendingPathComponent(self.path))
        urlRequest.httpMethod      = self.method.rawValue.uppercased()
        urlRequest.timeoutInterval = self.timeout
        
        if let headers = headers {
            self.setupHTTPHeaders(headers, for: &urlRequest)
        }
        
        guard let encodedRequest = self.setupDefaultEncoding(for: &urlRequest) else {
            return nil
        }
        
        return encodedRequest
    }
    
    
    // MARK: - Helper

    private func setupDefaultEncoding(for urlRequest: inout URLRequest) -> URLRequest? {
        
        guard let url = urlRequest.url else {
            return urlRequest
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.path = self.path
        
        if let parameters = self.parameters {
            
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        if let parametersOneKey = self.parametersOneKey {
            
            let key = parametersOneKey.keys.first!
            
            if let array = parametersOneKey[key] {
                
                urlComponents.queryItems = array.map { URLQueryItem(name: key, value: $0) }
            }
        }
        
        urlRequest.url = urlComponents.url?.absoluteURL

        return urlRequest
    }
    
    private func setupHTTPHeaders(_ headers: [String: String], for urlRequest: inout URLRequest) {
        
        for (key, value) in headers {
            
            if urlRequest.allHTTPHeaderFields?[key] == nil {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            } else {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
}

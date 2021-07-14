//
//  NetworkErrors.swift
//  Currencies
//
//  Created by Diego Barroso on 20.11.19.
//  Copyright © 2019 Diego Jerez Barroso. All rights reserved.
//

import Foundation

// MARK: - HttpError

/// Type that represents http request related errors
public enum HttpError: Error {
    case badGateway(data: Data?)
    case badRequest(data: Data?)
    case conflict(data: Data?)
    case forbidden(data: Data?)
    case internalServerError(data: Data?)
    case notAllowed(data: Data?)
    case notFound(data: Data?)
    case unauthorized(data: Data?)
    case unspecific(data: Data?)
}


extension HttpError {
    
    static func map(statusCode: Int, data: Data?) -> HttpError {
        
        switch statusCode {
        case 400:    return .badRequest(data: data)
        case 401:    return .unauthorized(data: data)
        case 403:    return .forbidden(data: data)
        case 404:    return .notFound(data: data)
        case 405:    return .notAllowed(data: data)
        case 409:   return .conflict(data: data)
        case 500:    return .internalServerError(data: data)
        case 502:    return .badGateway(data: data)
        default:    return .unspecific(data: data)
        }
    }
}

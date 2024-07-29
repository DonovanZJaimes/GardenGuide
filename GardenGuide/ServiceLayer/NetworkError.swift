//
//  NetworkError.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

enum NetworkError: String, Error {
    case jsonDecoder
    case invalidURL
    case generic
    case couldNotDecodeData
    case statusCodeError
    case httpResponseError
    case badRequest = "Empty feedback provided."
    case Unauthorized = "The specified api key not found."
    case notFound = "The requested identification does not exist."
    case tooManyRequests = "The specified api key does not have sufficient number of available credits."
}


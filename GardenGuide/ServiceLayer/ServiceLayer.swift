//
//  ServiceLayer.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 13/05/24.
//

import Foundation

class ServiceLayer {
    static func callService<T: Decodable>(_ requestModel: RequestModel, _ modelType: T.Type) async throws -> T {
        //Get query parameters
        var serviceUrl = URLComponents(string: requestModel.getURL())
        serviceUrl?.queryItems = requestModel.queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        //Unwrap URL
        guard let componentURL = serviceUrl?.url else {
            throw NetworkError.invalidURL
        }
        
        //URLRequest
        var request = URLRequest(url: componentURL, timeoutInterval: Double.infinity)
        request.addValue(Constants.apyKey, forHTTPHeaderField: "Api-Key")
        request.addValue(Constants.ContentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = requestModel.httpMethod.rawValue
        
        //httpBody
        if let postData = requestModel.postData {
            request.httpBody = postData
        }else {
            print(request)
        }
        
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else{
                throw NetworkError.httpResponseError
            }
            
            switch httpResponse.statusCode {
            case 400:
                throw NetworkError.badRequest
            case 401:
                throw NetworkError.Unauthorized
            case 404:
                throw NetworkError.notFound
            case 429:
                throw NetworkError.tooManyRequests
            default :
                if httpResponse.statusCode > 400 {
                    throw NetworkError.statusCodeError
                }
            }
            
            let decoder = JSONDecoder()
            do{
                //print("BRUTO")
                //print(String(data: data, encoding: .utf8)!)
                let decodeData = try decoder.decode(T.self, from: data)
                //print("LIMPIO")
                //print(decodeData)
                return decodeData
            }catch{
                print(error)
                throw NetworkError.couldNotDecodeData
            }
            
        }catch{
            throw NetworkError.generic
        }
       
    }
}

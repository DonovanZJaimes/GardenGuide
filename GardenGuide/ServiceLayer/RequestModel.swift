//
//  RequestModel.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 13/05/24.
//

import Foundation

struct RequestModel {
    let endpoint : Endpoints
    let httpMethod : HttpMethod
    var queryItems : [String:String]
    var baseUrl : URLBase = .plant
    var extra: String?
    let postData: Data?
    
    func getURL() -> String{
        return baseUrl.rawValue + endpoint.rawValue + (extra ?? "")
    }
    
    enum Endpoints : String   {
        case identification = "/identification"
        case plants = "/kb/plants/name_search"
        case detail = "/kb/plants/"
    }
    
    enum HttpMethod : String{
        case GET
        case POST
    }
    
    enum URLBase : String{
        case plant = "https://plant.id/api/v3"
    }
    
    
}

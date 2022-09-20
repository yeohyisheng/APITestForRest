//
//  MaskApi.swift
//  APITestForRest
//
//  Created by yeoh on 14/09/2022.
//

import Foundation


struct Pharmacies: Decodable {
    let type: String
    var features: [Feature]
    
    struct Feature: Decodable {
        let type: String
        var properties: Properties
        
        struct Properties: Decodable {
            var id: String
            var name: String
            var phone: String
            var address: String
            var mask_adult: Int
            var mask_child: Int
            var county: String
            var town: String
            var cunli: String
        }
    }
}





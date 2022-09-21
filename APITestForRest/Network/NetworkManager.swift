//
//  NetworkManager.swift
//  APITestForRest
//
//  Created by yeoh on 15/09/2022.
//

import Foundation
import Alamofire
import Kanna

class NetworkManager: NSObject {
    static let shared = NetworkManager()

    //解析maskapi資訊
    func getPharmaciesData(success: @escaping(Pharmacies?) -> Void, failure: @escaping(String?) -> Void){
        let urlString = "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json"
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response , error in
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode(Pharmacies.self, from: data)
                        success(result)
                    } catch {
                        print(error)
                    }
                } else {
                    print("error")
                }
            }.resume()
        }
    }
    //解析每日一句資訊
    func loadData(success: @escaping(String?) -> Void, failure: @escaping(String?) -> Void){
        let urlString = "https://tw.feature.appledaily.com/collection/dailyquote"
        if let url = URL(string: urlString){
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do{
                        let contents = String(data: data, encoding: .utf8)
//                        print("Html: \(contents)")
                        success(contents)
                    } catch {
                        print(error)
                    }
                    
                } else {
                    print("error")
                }
            }.resume()
        }
    }
}


//
//  Networking.swift
//  Restaurant Roulette
//
//  Created by Jared Cassoutt on 10/28/20.
//

import Foundation

class Networking {
    
    let apiKey = "ko9wDV10ULeISEP_38XdFjx5zFGvMMayLn0bm9qPcPGg-l13SjoDxjA_xPiRkLG0KU3cYAF8kBoxjnBfMqvW2suUurSFbfn1CrrgUvaf_R5jGXazE6OrbTQU1o0EX3Yx"
    let clientID = "1rTDBr9Yxsqfj-iUAXbxrA"
    
    func fetchRestaurant(phone: String, completion: @escaping (_ data:restaurant)->(),failure:@escaping (_ error:Error)->()) {
        let urlString = "https://api.yelp.com/v3/businesses/search/\(phone)&apiKey=\(apiKey)"
        //create a url
        if let url = URL(string: urlString) {
            //create URLSession
            let session = URLSession(configuration: .default)
            //give session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error ?? "error")
                    return
                }
                if let safeData = data {
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(restaurant.self, from: safeData)
                        print(decodedData)
                        completion(decodedData)
                    }
                    catch {
                        print(error)
                    }
                }
            }
            //Start task
            task.resume()
        }
    }
    
    
    func findRestaurant(phone: String, completion: @escaping (_ data:restaurant)->(),failure:@escaping (_ error:Error)->()) {
        let urlString = "https://api.yelp.com/v3/businesses/search/\(phone)"
        //create a url
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data,response,error) in
                if let error = error {
                    print(error)
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    guard let resp = json as? NSDictionary else {return}
                    guard let finalRestaurant = resp.value(forKey: "businesses") as? restaurant else {return}
                    print(finalRestaurant)
                    print(data)
                    completion(finalRestaurant)
                } catch {
                    print("caught error")
                }
            }.resume()
        }
    }
    
}

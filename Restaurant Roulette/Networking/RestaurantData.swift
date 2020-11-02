//
//  RestaurantData.swift
//  Restaurant Roulette
//
//  Created by Jared Cassoutt on 10/28/20.
//

import Foundation
struct restaurant: Decodable{
    let businesses: [businesses]
    private enum CodingKeys: String, CodingKey {
        case businesses = "businesses"
    }
}
struct businesses: Decodable{
    let rating: String
    let image_url: String
    private enum CodingKeys: String, CodingKey {
        case rating = "rating"
        case image_url = "image_url"
    }
}

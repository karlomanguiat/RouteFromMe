//
//  File.swift
//  RouteFromMe
//
//  Created by Glenn Karlo Manguiat on 7/18/25.
//

import Foundation

protocol UserServiceProtocol {
    func fetchUser(completion: @escaping (User?) -> Void)
}

struct User: Decodable {
    let name: String
    let address: Address
}

struct Address: Decodable {
    let geo: Geo
}

struct Geo: Decodable {
    let lat: String
    let lng: String
}


class UserService: UserServiceProtocol {
    func fetchUser(completion: @escaping (User?) -> Void) {
        let urlString = "https://jsonplaceholder.typicode.com/users"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let users = try? JSONDecoder().decode([User].self, from: data) else {
                completion(nil)
                return
            }

            completion(users.randomElement())
        }.resume()

    }
}

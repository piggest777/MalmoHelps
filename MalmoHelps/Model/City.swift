//
//  City.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-11-21.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift


struct City: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    let city: String
    let region: String

    enum CodingKeys: String, CodingKey {
        case id, city, region
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        city = try container.decode(String.self, forKey: .city)
        region = try container.decode(String.self, forKey: .region)
    }
}

//
//  User.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-07-17.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift

struct User: Codable {
    @DocumentID var uid: String?
    let email: String
    let name: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case uid, email, name, role
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self._uid = try container.decode(DocumentID<String>.self, forKey: .uid)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        role = try container.decode(String.self, forKey: .role)
    }
}


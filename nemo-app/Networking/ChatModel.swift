//
//  ChatModel.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 21/07/2023.
//

import Foundation


struct ChatSchema {
    var user_id: String
    var message: String
}

struct ChatModel: Codable {
    var message: String

}

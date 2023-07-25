//
//  OnboardingEndpoint.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 20/07/2023.
//

import Foundation


struct OnboardingEndpointSchema {
    var user_id: String
    var message: String
}


struct OnboardingModel: Decodable {
    var message: String
    var overallOnboardingDone: Bool
    
    private enum CodingKeys: String, CodingKey {
        case message, overallOnboardingDone
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decode(String.self, forKey: .message)
        overallOnboardingDone = try values.decode(Bool.self, forKey: .overallOnboardingDone)
    }
}

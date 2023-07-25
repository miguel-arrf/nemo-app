//
//  PlanModel.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 21/07/2023.
//

import Foundation

struct PlanSchema {
    var user_id: String
    var plan: String
}

struct PlanChatSchema {
    var user_id: String
    var message: String
    var start: Bool
}

struct PlanInnerModel: Equatable, Codable, Hashable {
    var planName: String
    var exercisesNames: [String]
    var estimatedDuration: Int
    var description: String
    var id: UUID
    
        private enum CodingKeys: String, CodingKey {
            case plan_name, exercises_names, estimated_duration, description, user_id
        }
    
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(planName, forKey: .plan_name)
            try container.encode(exercisesNames, forKey: .exercises_names)
            try container.encode(estimatedDuration, forKey: .estimated_duration)
            try container.encode(description, forKey: .description)
            try container.encode(id, forKey: .user_id)
    
        }
    
        init(planName: String, exercisedNames: [String], estimatedDuration: Int, description: String, id: UUID) {
            self.planName = planName
            self.exercisesNames = exercisedNames
            self.estimatedDuration = estimatedDuration
            self.description = description
            self.id = id
        }
    
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            planName = try values.decode(String.self, forKey: .plan_name)
            exercisesNames = try values.decode([String].self, forKey: .exercises_names)
            estimatedDuration = try values.decode(Int.self, forKey: .estimated_duration)
            description = try values.decode(String.self, forKey: .description)
            id = try values.decode(UUID.self, forKey: .user_id)
    
        }
}

struct PlanModels: Equatable, Codable {
    var plans: [PlanInnerModel]
}

struct PlanModel: Equatable, Codable {
    var plan: PlanInnerModel
}

let teste = """
{'plan_preview': {'plan_name': 'The Aquatic Adventure', 'exercises_names': ['Shoulder Rolls', 'Knee Extension', 'Ankle Pumps', 'Arm Raises', 'Hip Flexion'], 'estimated_duration': 40, 'description': 'A beginner-friendly plan focusing on improving mobility and strength in your upper body and lower body.'}, 'assistant_message': "Here's a plan I've created for you! How does it look?", 'interface': {'button': ['Looks great!', 'Change exercises', 'Change duration']}}
"""


struct PlanChatModel: Decodable {
    

    let planPreview: PlanPreview
    let assistantMessage: String
    let interface: Interface
    
    enum CodingKeys: String, CodingKey {
        case planPreview = "plan_preview"
        case assistantMessage = "assistant_message"
        case interface
    }
    
    
    struct PlanPreview: Codable {
        let planName: String
        let exercisesNames: [String]
        let estimatedDuration: Int
        let description: String
        
        enum CodingKeys: String, CodingKey {
            case planName = "plan_name"
            case exercisesNames = "exercises_names"
            case estimatedDuration = "estimated_duration"
            case description
        }
    }
    
    struct Interface: Codable {
        let button: [String]?
        let toggle: [String]?
        let slider: [SliderValue]?
    }
    
}


enum SliderValue: Codable {
    case int(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .int(try container.decode(Int.self))
        } catch DecodingError.typeMismatch {
            do {
                self = .string(try container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(SliderValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Mismatched Types"))
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let int):
            try container.encode(int)
        case .string(let string):
            try container.encode(string)
        }
    }
}

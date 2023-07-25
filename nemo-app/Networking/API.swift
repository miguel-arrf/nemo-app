//
//  API.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 20/07/2023.
//

import Foundation


//fileprivate let serviceURL = "127.0.0.1"
//fileprivate let servicePort: Int? = 5001

import Foundation

struct SchedulerSchema {
    var user_id: String
    var calendar: [String]
}

extension Encodable {
    /// Converting object to postable JSON
    func toJSON(_ encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let data = try encoder.encode(self)
        let result = String(decoding: data, as: UTF8.self)
        return NSString(string: result) as String
    }
}

struct NotificationSchema: Codable {
    var user_id: String
}

struct ResetSchema: Codable {
    var user_id: String
    var tables: [String]
}

struct AppleHealthKitSchema: Codable {
    var apple_health_kit_data: String
}

struct AddPlansSchema: Codable {
    var plans: PlanInnerModel
    var user_id: String
}

struct AddPlansModel: Codable {
    var plans: PlanInnerModel
}


enum API: Endpoint {
    var port: Int? {
//        return servicePort
        let hasPort = UserDefaults.standard.bool(forKey: "hasPort")
        if hasPort {
            return UserDefaults.standard.integer(forKey: "port")
        } else {
            return nil
        }
    }
    
    case addUser(username: String)
    case getUser(username: String)
    case onboarding(onboardingEndpointSchema: OnboardingEndpointSchema)
    case getPlan(user_id: String)
    case getChat(onboardingChatSchema: ChatSchema)
    case getScheduler(schedulerSchema: SchedulerSchema)
    case getGeneratedPlan(user_id: String)
    case addPlanByChatting(planChatSchema: PlanChatSchema)
    case planExecutor(planExecutorSchema: PlanExecutorSchema)
    case getNotifications(notificationSchema: NotificationSchema)
    case reset(resetSchema: ResetSchema)
    case appleHealthKit(appleHealthKitSchema: AppleHealthKitSchema)
    case generatePersona(user_id: String)
    case addPlan(addPlansSchema: AddPlansSchema)
    case getInfo(user_id: String)
    
    /**
     - Description: The baseURL of the API
     */
    var base: String {
//        return serviceURL
        return UserDefaults.standard.string(forKey: "domain") ?? ""
    }
    
    /**
     - Description: The path of the URL for the current endpoint
     */
    var path: String {
        switch self {
        case .addUser(username: _):
            return "/users"
        case .getUser(username: _):
            return "/users"
        case .getPlan(user_id: let username):
            return "/users/\(username)/plans"
        case .onboarding(onboardingEndpointSchema: let onboardingEndpointSchema):
            return "/users/\(onboardingEndpointSchema.user_id)/onboarding"
        case .getChat(onboardingChatSchema: let onboardingChatSchema):
            return "/users/\(onboardingChatSchema.user_id)/chat"
        case .getScheduler(schedulerSchema: let schedulerSchema):
            return "/scheduler/\(schedulerSchema.user_id)"
        case .addPlan(addPlansSchema: let addPlansSchema):
            return "/users/\(addPlansSchema.user_id)/plans"
        case .getGeneratedPlan(user_id: let user_id):
            return "/users/\(user_id)/plans/generate"
        case .addPlanByChatting(planChatSchema: let planChatSchema):
            return "/users/\(planChatSchema.user_id)/plans/chat"
        case .planExecutor(planExecutorSchema: let planExecutorSchema):
            return "/users/\(planExecutorSchema.user_id)/plan-executor"
        case .getNotifications(notificationSchema: let notificationSchema):
            return "/users/\(notificationSchema.user_id)/notifications"
        case .reset(resetSchema: let resetSchema):
            return "/users/\(resetSchema.user_id)/reset"
        case .appleHealthKit(_):
            return "/users/apple-health-kit"
        case .generatePersona(user_id: let user_id):
            return "/users/\(user_id)/persona/generate"
        case .getInfo(user_id: let user_id):
            return "/users/\(user_id)/info"
        }
    }
    
    
    
    var queryItems: [URLQueryItem] {
        var urlItems: [URLQueryItem] = .init()
        switch self {
        case .addPlanByChatting(planChatSchema: let planChatSchema):
            urlItems.append(.init(name: "start", value: String(planChatSchema.start)))
        default:
            break
        }
        
        return urlItems
    }
        
    /**
     - Description: The method for the current endpoint
     */
    var method: HTTPMethod {
        switch self {
        case .getUser(_), .getPlan(_), .getGeneratedPlan(_), .generatePersona(_), .getInfo(_):
            return .get
        case .addUser(_), .onboarding(_), .getChat(_), .addPlan(_), .addPlanByChatting(_), .planExecutor(_), .reset(_), .appleHealthKit(_), .getScheduler(_), .getNotifications(_):
            return .post
        }
    }
    
    /**
     - Description: The headers for the current endpoint
     */
    var headers: [String : String] {
        return ["content-type": "application/json"]
    }
    
    /**
     - Description: The payload for the current endpoint
     */
    var body: Encodable? {
        switch self {
        case .addUser(let user):
            return ["username": user]
        case .getUser(_), .getPlan(_), .getGeneratedPlan(_), .generatePersona(_), .getNotifications(_):
            return nil
        case .onboarding(let onboardingEndpointSchema):
            return ["message": onboardingEndpointSchema.message]
        case .getChat(let onboardingChatSchema):
            return ["message": onboardingChatSchema.message]
        case .getScheduler(let schedulerSchema):
            return ["calendar": schedulerSchema.calendar]
        case .addPlan(addPlansSchema: let addPlansSchema):
            return addPlansSchema
        case .addPlanByChatting(planChatSchema: let planChatSchema):
            return ["message": planChatSchema.message]
        case .planExecutor(planExecutorSchema: let planExecutorSchema):
            return planExecutorSchema
        case .reset(resetSchema: let resetSchema):
            return ["tables": resetSchema.tables]
        case .appleHealthKit(appleHealthKitSchema: let appleHealthKitSchema):
            return ["apple_health_kit_data": appleHealthKitSchema.apple_health_kit_data]
        case .getInfo(_):
            return nil
        }
    }
    
    /**
     - Description: the query parameters for the current endpoint
     */
    var queryParameters: [URLQueryItem] {
        return []
    }
}


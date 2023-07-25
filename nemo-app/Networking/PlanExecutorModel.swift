//
//  PlanExecutorModel.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 22/07/2023.
//

import Foundation

struct PlanExecutorSchema: Codable {
    var user_id: String
    var messages: [[String]]
    var userPlan: PlanModel
}


struct PlanExecutionModel: Codable {
    var isExecutionFinished: Bool
    var messageToReadToUser: String
    /*
     {"isExecutionFinished": false, "messageToReadToUser": "Hello! Today, we will be working on 'The Sea Turtle Plan'. This plan focuses on improving balance, leg strength, and core stability. We have three exercises to do: Balance Exercises, Squats, and Plank. We will be doing each exercise in sets and repetitions to fit within our estimated 40-minute workout. Let's start with the Balance Exercises. Are you ready?"}
     */
}



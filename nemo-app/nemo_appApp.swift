//
//  nemo_appApp.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 19/07/2023.
//

import SwiftUI

class User {
    public static var shared: User = .init()
    
    public var id: String = ""
    
}

@main
struct nemo_appApp: App {

    var healthKitManager: HealthKitManager = HealthKitManager.shared
    @State private var loggedIn: Bool = false
    @State private var hasDoneOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            
//                    print(fetchCalendarEvents())
//                    healthKitManager.authorizeHealthKit()
//                    healthKitManager.printActivitySummaries()
//                    healthKitManager.printWorkouts()
//                    healthKitManager.printSleepData()
//                    healthKitManager.printWaterIntake()
  
            ZStack {
                if !loggedIn {
                    
                    RegisterUser() { hasDoneOnboarding in
                        withAnimation {
                            self.hasDoneOnboarding = hasDoneOnboarding
                            loggedIn = true
                        }
                    }
                }
                
                if loggedIn && hasDoneOnboarding {
                    ContentView()
                }
                
                if loggedIn && !hasDoneOnboarding {
                    OnboardingView {
                        withAnimation {
                            self.hasDoneOnboarding = true
                        }
                    }
                }
            }
            .onAppear {
                healthKitManager.authorizeHealthKit()
            }
           
            
//            PlanExecutorView(plan: .init(planName: "The Sea Turtle Plan", exercisesNames: ["Balance Exercises", "Squats", "Plank"], estimatedDuration: 40, description: "his plan focuses on improving balance, leg strength, and core stability", id: .init()))
            
        }
    }
}

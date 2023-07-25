//
//  HealthKitDataManager.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 19/07/2023.
//

import Foundation
import HealthKit
import Combine

struct AppleHealthKitResponse: Codable {
    var apple_health_cards: [AppleHealthKitCardResponse]
    
    struct AppleHealthKitCardResponse: Codable {
        var title: String
        var description: String
        var advantadgeTheUserWillGain: String
        var levelOfImportance: String
    }
}

class HealthKitManager {
    public static var shared: HealthKitManager = .init()
    var activitySummariesData: [String] = .init()
    var workoutsData: [String] = .init()
    var sleepData: [String] = .init()
    var waterIntakeData: [String] = .init()
    
    @Published var activitySummaryDone: Bool = false
    @Published var workoutsDataDone: Bool = false
    @Published var sleepDataDone: Bool = false
    @Published var waterIntakeDataDone: Bool = false

    var cancellableSet: Set<AnyCancellable> = []

    var allPublishersDone: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3($activitySummaryDone, $workoutsDataDone, $sleepDataDone)
            .combineLatest($waterIntakeDataDone)
            .map { $0.0 && $0.1 && $0.2 && $1 }
            .eraseToAnyPublisher()
    }
        
    func areAllValuesTrue(onComplete: @escaping (AppleHealthKitResponse) -> Void) {
        
       
        allPublishersDone
            .sink { done in
                if done {
                    print("All tasks are done!")
                    // place desired tasks you want to do when all variables are true here
                    
                    Task {
                        let network: Networking = await .init()
                        
                        let activitySummariesString = self.activitySummariesData.joined(separator: "\n")
                        let workoutsDataString = self.workoutsData.joined(separator: "\n")
                        let sleepDataString = self.sleepData.joined(separator: "\n")
                        let waterIntakeDataString = self.waterIntakeData.joined(separator: "\n")

                           let allData = [activitySummariesString, workoutsDataString, sleepDataString, waterIntakeDataString].joined(separator: "\n\n")
                        
                        let appleHealthKitResult: Result<AppleHealthKitResponse, NetworkingError> = await network.performRequest(endpoint: API.appleHealthKit(appleHealthKitSchema: .init(apple_health_kit_data: allData)))
                        switch appleHealthKitResult {
                        case .success(let success):
                            onComplete(success)
                        case .failure(let _):
                            print("There was an error getting Apple Health Kit answers")
                        }
                    }
                }
            }
            .store(in: &cancellableSet)
    }
    
    let healthStore = HKHealthStore()

    func authorizeHealthKit() {
        // Specify the data types that your app can read from HealthKit
        let readDataTypes: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
            HKObjectType.activitySummaryType(),
            HKObjectType.workoutType()
        ]

        // Request authorization for those data types
        healthStore.requestAuthorization(
            toShare: [],
            read: readDataTypes)
        { (success, error) in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    private func getPredicate() -> NSPredicate {
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
            return predicate
    }

    func printSleepData() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let query = HKSampleQuery(sampleType: sleepType, predicate: getPredicate(), limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let error = error {
                print("Error retrieving sleep data: \(error.localizedDescription)")
                return
            }
            if let results = results {
                for sleep in results {
                    if let sleep = sleep as? HKCategorySample {
                        if sleep.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                            print("Sleep analysis: Asleep, start time: \(sleep.startDate), end time: \(sleep.endDate).")
                            self.sleepData.append("Sleep analysis: Asleep, start time: \(sleep.startDate), end time: \(sleep.endDate).")
                        } else if sleep.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                            print("Sleep analysis: In bed, start time: \(sleep.startDate), end time: \(sleep.endDate).")
                            self.sleepData.append("Sleep analysis: In bed, start time: \(sleep.startDate), end time: \(sleep.endDate).")
                        }
                    }
                }
                self.sleepDataDone = true
            }
        }
        healthStore.execute(query)
    }
    
    func printWaterIntake() {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            print("DietaryWater type is no longer available in HealthKit")
            return
        }
        
        let query = HKSampleQuery(sampleType: waterType, predicate: getPredicate(), limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let error = error {
                print("Error retrieving water intake: \(error.localizedDescription)")
                return
            }
            
            if let results = results {
                for result in results {
                    if let sample = result as? HKQuantitySample {
                        let waterAmount = sample.quantity.doubleValue(for: HKUnit.literUnit(with:.none))
                        print("Water: \(waterAmount) liters at \(sample.startDate)")
                        self.waterIntakeData.append("Water: \(waterAmount) liters at \(sample.startDate)")
                    }
                }
                self.waterIntakeDataDone = true
            }
        }
        healthStore.execute(query)
    }
    
    private func getActivitySummaryPredicate() -> NSPredicate? {
        let calendar = Calendar.current
        let now = Date()

        guard let startDate = calendar.date(byAdding: .day, value: -7, to: now) else {
            return nil
        }

        let endDate = now

        var startDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        var endDateComponents = calendar.dateComponents([.year, .month, .day], from: endDate)

        // Set the calendars for date components
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar
        
        print("start: \(String(describing: startDate)), ending: \(String(describing: endDateComponents))")

        let predicate = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)

        return predicate
    }
    
    func printActivitySummaries() {
        
        let query = HKActivitySummaryQuery(predicate: getActivitySummaryPredicate()) { (query, summaries, error) in
            if let error = error {
                print("Error retrieving activity summary teste: \(error.localizedDescription)")
                return
            }
            
            summaries?.forEach { summary in
                let calendar = Calendar.current.dateComponents([.day, .month, .year], from: Date.distantPast)
                print("Date components: \(String(describing: calendar.day))/\(String(describing: calendar.month))/\(String(describing: calendar.year))")
                print("Active Energy Burned = \(summary.activeEnergyBurned)")
                print("Exercise Time = \(summary.appleExerciseTime)")
                print("Stand Hours = \(summary.appleStandHours)")
                print("-------------------------")
                
                self.activitySummariesData.append("Date components: \(String(describing: calendar.day))/\(String(describing: calendar.month))/\(String(describing: calendar.year))")
                self.activitySummariesData.append("Active Energy Burned = \(summary.activeEnergyBurned)")
                self.activitySummariesData.append("Exercise Time = \(summary.appleExerciseTime)")
                self.activitySummariesData.append("Stand Hours = \(summary.appleStandHours)")
                self.activitySummariesData.append("-------------------------")
                
            }
            self.activitySummaryDone = true
        }
        
        healthStore.execute(query)
    }
    
    func printWorkouts() {
        let workoutType = HKObjectType.workoutType()
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: getPredicate(), limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let error = error {
                print("Error retrieving workouts: \(error.localizedDescription)")
                return
            }
            
            if let results = results {
                for workout in results {
                    if let workout = workout as? HKWorkout {
                        print("Workout type: \(workout.workoutActivityType.name)")
                        print("Start time: \(workout.startDate)")
                        print("End time: \(workout.endDate)")
                        print("Duration: \(workout.duration) seconds")
                        print("Total energy burned: \(String(describing: workout.totalEnergyBurned))")
                        print("Total distance: \(String(describing: workout.totalDistance))")
                        print("-------------------------")
                        
                        self.workoutsData.append("Workout type: \(workout.workoutActivityType.name)")
                        self.workoutsData.append("Start time: \(workout.startDate)")
                        self.workoutsData.append("End time: \(workout.endDate)")
                        self.workoutsData.append("Duration: \(workout.duration) seconds")
                        self.workoutsData.append("Total energy burned: \(String(describing: workout.totalEnergyBurned))")
                        self.workoutsData.append("Total distance: \(String(describing: workout.totalDistance))")
                        self.workoutsData.append("-------------------------")
                    }
                }
            }
            self.workoutsDataDone = true
        }
        healthStore.execute(query)
    }
}

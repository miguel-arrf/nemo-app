//
//  HomeView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 20/07/2023.
//

import SwiftUI
import SwiftUISnappingScrollView

class OverlayViewModel: ObservableObject {
    @Published var overlayView: AnyView? = nil
    @Published var showing: Bool = false
}

struct SchedulerModel: Codable {
    var schedule: [[String]]
}

struct NotificationsModel: Codable {
    var notifications: [[String]]
}



struct HomeView: View {
    var healthKitManager: HealthKitManager = .shared
    @State var cards: [AppleHealthKit] = .init() //getTestCards()
    @EnvironmentObject var overlayViewModel: OverlayViewModel
    @State var lastAppleHealthCardsSave: Date?

    init() {
        
        if let data = UserDefaults.standard.object(forKey: "appleHealthCards") as? Data,
           let appleHealthCards = try? JSONDecoder().decode([AppleHealthKit].self, from: data) {
            self._cards = .init(initialValue: appleHealthCards)
        }
        
        let lastAppleHealthCardsSave = UserDefaults.standard.object(forKey: "lastAppleHealthCardsSave") as? Date
        
        if let lastAppleHealthCardsSave = lastAppleHealthCardsSave {
            self._lastAppleHealthCardsSave = .init(initialValue: lastAppleHealthCardsSave)
        }
        
    }
    
    func saveCardsAndDate() {
        let defaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(cards) {
            defaults.set(encoded, forKey: "appleHealthCards")
        }
        defaults.set(Date.now, forKey: "lastAppleHealthCardsSave")
    }
    
    @State private var scheduler: SchedulerModel?
    @State private var notifications: NotificationsModel?
    
    var body: some View {
        ScrollView(.vertical) {
            
            VStack(alignment: .leading) {
                //                Text("Tips & Tricks")
                //                    .font(.title)
                //                    .fontDesign(.rounded)
                //                    .fontWeight(.black)
                //                    .padding()
                //
                SnappingScrollView(.horizontal, decelerationRate: .fast, showsIndicators: true, content: {
                    HStack(alignment: .top, spacing: 20, content:  {
                        ForEach($cards, id: \.self) { $card in
                            HomeCardView(card: card)
                                .frame(width: UIScreen.screenWidth - 40)
                                .environmentObject(overlayViewModel)
                                .scrollSnappingAnchor(.bounds)
                            
                        }
                    })
                    .padding(.horizontal)
                })
                
                VStack {
                    if let scheduler = scheduler {
                        if !scheduler.schedule.isEmpty {
                           
                            let grouped = groupByFirstItem(toGroup: scheduler.schedule)
                               let sortedGrouped = grouped.sorted(by: { $0.key < $1.key })
                            
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Schedule")
                                    .bold()
                                    .font(.title2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                ForEach(sortedGrouped, id: \.key) { key, value in
                                    
                                    VStack(alignment: .leading) {
                                        Text(key)
                                            .bold()
                                            .font(.title3)
                                        
                                        ForEach(value, id: \.self) { item in
                                            HStack {
                                                Text(item[1])
                                                Spacer()
                                                Text("\(item[2]) \(Image(systemName: "calendar.badge.clock"))")
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            .padding()
                        }
                    }
                    
                    if let notifications = notifications {
                        VStack(spacing: 18) {
                            
                            Text("Planned Notifications:")
                                .font(.title2)
                                .bold()
                                .fontDesign(.monospaced)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(notifications.notifications, id: \.self) { notification in
                                if notification.count == 2 {
                                    let description = notification[0]
                                    let hour = notification[1]
                                    let last: Bool = notifications.notifications.last == notification
                                    VStack {
                                        Text(description)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.white)
                                        
                                        HStack {
                                            Text("\(hour) | \(Image(systemName: "clock.badge.checkmark"))")
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 2)
                                                .background(Color.white.opacity(0.2), in: Capsule())
                                            Spacer()
                                        }
                                        
                                        if !last {
                                            Divider()
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        
                                    }
                                }
                               
                            }
                        }
                        .padding()
                        .background(Color.black, in: RoundedRectangle(cornerRadius: 12))
                        .padding()
                    }
                       
                }
                
                
                
                
            }
            
        }
        .onAppear {
            Task {
                if let date = lastAppleHealthCardsSave {
                    let currentDate = Date()
                    let calendar = Calendar.current

                    let components = calendar.dateComponents([.minute], from: date, to: currentDate)

                    if let minutes = components.minute, minutes >= 30 {
                      print("More than 30 minutes have passed for appleCards")
                        await getAppleHealthTips()
                    } else {
                      print("Less than 30 minutes have passed, we won't update the appleCards")
                    }
                } else {
                    await getAppleHealthTips()
                }
            }
            
            Task {
                await getScheduler()
            }
            
            
            Task {
                await getNotifications()
            }
        }

    }
    
    var groupedItems: [String: [[String]]] {
        var result = [String: [[String]]]()
        for item in scheduler!.schedule {
           let key = item[0] // use the first string as the key
           if result[key] != nil {
              // if the key already exists, append the new item to the existing array
              result[key]!.append(item)
           } else {
              // if the key doesn't exist, add a new key-value pair to the dictionary with the key and an array containing the item
              result[key] = [item]
           }
        }
        return result
    }
    
    func groupByFirstItem(toGroup: [[String]]) -> [String: [[String]]] {
        var result = [String: [[String]]]()
        for item in toGroup {
            let key = item[0]
            if result[key] != nil {
                result[key]!.append(item)
            } else {
                result[key] = [item]
            }
        }
        return result
    }
    
    func getNotifications() async {
        let network: Networking = .init()
        
        let result: Result<NotificationsModel, NetworkingError> = await network.performRequest(endpoint: API.getNotifications(notificationSchema: .init(user_id: User.shared.id)))
        
        switch result {
        case .success(let success):
            print("obtained notifications: \(success)")
            withAnimation {
                self.notifications = success
            }
        case .failure(let failure):
            print("failure obtaining notifications: \(failure)")
        }
    }
    
    func getScheduler() async {
        let calendarEvents: [String] = fetchCalendarEvents()
        let network: Networking = .init()

        let result: Result<SchedulerModel, NetworkingError> = await network.performRequest(endpoint: API.getScheduler(schedulerSchema: .init(user_id: User.shared.id, calendar: calendarEvents)))
        
        switch result {
        case .success(let success):
            withAnimation {
                self.scheduler = success
            }
            print("successfully obtained schedule: \(success)")
        case .failure(let failure):
            print("Failure obtaining schedules: \(failure)")
        }
        
    }
    
    func getAppleHealthTips() async {
        healthKitManager.printActivitySummaries()
        healthKitManager.printWorkouts()
        healthKitManager.printSleepData()
        healthKitManager.printWaterIntake()
        healthKitManager.areAllValuesTrue { appleHealthKitResponse in
            if appleHealthKitResponse.apple_health_cards.isEmpty {
                withAnimation {
                    cards = getTestCards()
                }
            } else {
                for appleHealthKitCard in appleHealthKitResponse.apple_health_cards {
                    withAnimation {
                        cards.append(.init(title: appleHealthKitCard.title, description: appleHealthKitCard.description, advantadgeTheUserWillGain: appleHealthKitCard.advantadgeTheUserWillGain, levelOfImportance: appleHealthKitCard.levelOfImportance))
                    }
                }
            }
            
            saveCardsAndDate()
        
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}



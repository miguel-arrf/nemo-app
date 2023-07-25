//
//  Calendar.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 21/07/2023.
//

import Foundation
import EventKit

func fetchCalendarEvents() -> [String] {
    let eventStore = EKEventStore()
    var timeBlocks: [String] = []

    switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            fetch()
        case .denied:
            print("Access denied")
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: { (granted: Bool, NSError) -> Void in
            if granted {
                fetch()
            } else {
                print("Access denied")
            }
        })
        default:
            print("Unknown access")
    }

    func fetch() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate!, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        for event in events {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US") // specify locale to english
            dateFormatter.dateFormat = "EEEE h:mm a" // EEEE for Full Weekday Name
            let startEvent = dateFormatter.string(from: event.startDate)
            let endEvent = dateFormatter.string(from: event.endDate)
            let block = "\(startEvent) until \(endEvent.split(separator: " ").dropFirst().joined(separator: " "))"
            timeBlocks.append(block)
        }
    }
    

    return timeBlocks
}

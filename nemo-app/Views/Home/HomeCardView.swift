//
//  HomeCardView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 20/07/2023.
//

import SwiftUI

enum LevelOfImportance: String, Codable{
    case light, moderate, severe
}

extension LevelOfImportance {
    func getSFSymbol() -> String {
        switch self {
        case .light:
            return "exclamationmark"
        case .moderate:
            return "exclamationmark.2"
        case .severe:
            return "exclamationmark.3"
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .light:
            return "Here's a tip and trick."
        case .moderate:
            return "Maybe try this!"
        case .severe:
            return "Major Improvement opportunity"
        }
    }
    
}

struct AppleHealthKit: Codable, Hashable {
    var title: String
    var description: String
    var advantadgeTheUserWillGain: String
    var levelOfImportance: LevelOfImportance
    
    init(title: String, description: String, advantadgeTheUserWillGain: String, levelOfImportance: String) {
        self.title = title
        self.description = description
        self.advantadgeTheUserWillGain = advantadgeTheUserWillGain
        
        var levelOfImp: LevelOfImportance = .light
        
        if levelOfImportance.contains("light") {
            levelOfImp = .light
        }
        
        if levelOfImportance.contains("ever") {
            levelOfImp = .severe
        }
        
        if levelOfImportance.contains("oderate") {
            levelOfImp = .moderate
        }
        
        self.levelOfImportance = levelOfImp
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title + description + advantadgeTheUserWillGain)
    }
    
    private enum CodingKeys: String, CodingKey {
        case title, description, advantadgeTheUserWillGain, levelOfImportance
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        description = try values.decode(String.self, forKey: .description)
        advantadgeTheUserWillGain = try values.decode(String.self, forKey: .advantadgeTheUserWillGain)
        levelOfImportance = try values.decode(LevelOfImportance.self, forKey: .levelOfImportance)
    }
    
}

enum AppleHealthKitCardType {
    case sleep, water, physicalActivity, stand
}

extension AppleHealthKit {
    func getAppleHealthKitCardType() -> AppleHealthKitCardType {
        if title.contains("Sleep") {
            return .sleep
        } else if title.contains("Water") {
            return .water
        } else if title.contains("Physical Activity") {
            return .physicalActivity
        } else {
            return .stand
        }
    }
    
    func getTitleColor() -> Color {
        switch getAppleHealthKitCardType() {
        case .physicalActivity:
            return Color(red: 0.09, green: 0.09, blue: 0.09)
        case .sleep:
            return Color(red: 0.22, green: 0.22, blue: 0.22)
        case .stand:
            return Color(red: 0.26, green: 0.09, blue: 0.34)
        case .water:
            return Color(red: 0.15, green: 0.36, blue: 0.35)
        }
    }
    
    func getBackgroundColor() -> Color {
        switch getAppleHealthKitCardType() {
        case .physicalActivity:
            return Color(red: 0.92, green: 0.98, blue: 0.96)
        case .sleep:
            return Color(red: 0.98, green: 1, blue: 0.93)
        case .stand:
            return Color(red: 0.98, green: 0.91, blue: 0.99)
        case .water:
            return Color(red: 0.93, green: 1, blue: 1)
            
        }
    }
    
    func getDescriptionColor() -> Color {
        switch getAppleHealthKitCardType() {
        case .physicalActivity:
            return Color(red: 0.47, green: 0.47, blue: 0.47)
        case .sleep:
            return Color(red: 0.36, green: 0.36, blue: 0.36)
        case .stand:
            return Color(red: 0.49, green: 0.45, blue: 0.49)
        case .water:
            return Color(red: 0.33, green: 0.65, blue: 0.78)
        }
    }
    
    func getCapsuleLevelColor() -> Color {
        switch getAppleHealthKitCardType() {
        case .physicalActivity:
            return Color(red: 0.38, green: 0.83, blue: 0.61)
        case .sleep:
            return Color(red: 0.99, green: 1, blue: 0.30)
        case .stand:
            return Color(red: 0.80, green: 0.35, blue: 0.95)
        case .water:
            return Color(red: 0.37, green: 0.76, blue: 0.95)
        }
    }
    
    func getLevelTextColor() -> Color {
        switch getAppleHealthKitCardType() {
        case .physicalActivity:
            return Color(red: 0.13, green: 0.30, blue: 0.17)
        case .sleep:
            return Color(red: 0.44, green: 0.45, blue: 0.15)
        case .stand:
            return Color(red: 0.26, green: 0.09, blue: 0.34)
        case .water:
            return Color(red: 0.15, green: 0.35, blue: 0.38)
        }
    }
}

struct HomeCardView: View {
    @EnvironmentObject var overlayViewModel: OverlayViewModel

    
    var card: AppleHealthKit
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text(card.title)
                    .fontWeight(.bold)
                    .foregroundColor(card.getTitleColor())
                    .bold()
                
                Spacer()
                
                Text(Image(systemName: card.levelOfImportance.getSFSymbol()))
                    .fontWeight(.black)
                    .foregroundColor(card.getLevelTextColor())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .bold()
                    .background(
                        Capsule()
                            .foregroundColor(card.getCapsuleLevelColor())
                    )
            }
            
            Text(card.description)
                .fontWeight(.bold)
                .foregroundColor(card.getDescriptionColor())
                .lineLimit(3)
                .contentTransition(.opacity)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("More \(Image(systemName: "plus"))")
                .fontWeight(.black)
                .foregroundColor(card.getLevelTextColor())
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .bold()
                .background(
                    Capsule()
                        .foregroundColor(card.getCapsuleLevelColor())
                )
                .onTapGesture {
                    withAnimation(.spring()) {
//                        expanded.toggle()
                        overlayViewModel.showing = true
                        overlayViewModel.overlayView = AnyView(HealthKitCardPopupView(card: card) {
                            overlayViewModel.showing = false
                        })
                    }
                }
            
//            if expanded {
//                Text(card.advantadgeTheUserWillGain)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .fontWeight(.semibold)
//                    .foregroundColor(card.getTitleColor())
//                    .foregroundColor(card.getLevelTextColor())
//                    .padding()
//                    .bold()
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .foregroundColor(card.getCapsuleLevelColor())
//                    )
//                    .fixedSize(horizontal: false, vertical: true)
//                    .transition(.opacity)
//            }
          
        }
       .clipped()
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(card.getBackgroundColor())
        }
 
    }
}


struct CustomSheetModifier<Teste: View>: ViewModifier {
    @Binding var isShowing: Bool
    @ViewBuilder var otherContent: () -> Teste
    var yOffset: CGFloat = UIScreen.screenHeight
    var onClose: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(content: {
                if isShowing {
                    Color.black
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                isShowing = false
                                onClose()
                            }
                        }
                }
            })
            .overlay(alignment: .bottom, content: {
                if isShowing {
                    otherContent()
                        .transition(.asymmetric(insertion: .offset(y: yOffset), removal: .offset(y: yOffset)))
//                        .transition(.asymmetric(insertion: .push(from: .bottom).combined(with: .movingParts.blur), removal: .push(from: .top).combined(with: .movingParts.blur)))
//                        .transition(.move(edge: .bottom))
                }
            })
           
    }
}


struct HomeCardView_Previews: PreviewProvider {
    static var previews: some View {
        let cards: [AppleHealthKit] = getTestCards()
        
        ScrollView(.vertical) {
            VStack {
                ForEach(cards, id: \.self) { card in
                    HomeCardView(card: card)
                        .padding()
                }
            }
        }
     
    }
}


let test_json: String = """
[
  {
    "title": "Improve Sleep Schedule",
    "description": "Your sleep schedule seems to be quite inconsistent with different sleeping and wake up times. Aim to make this more consistent.",
    "advantadgeTheUserWillGain": "Regular and consistent sleep schedule will improve overall sleep quality, health, mood, improve immunity and reduce stress.",
    "levelOfImportance": "moderate"
  },
  {
    "title": "Increase Water Intake",
    "description": "Your latest water record shows a very low water intake. Water is essential for good health. Try to consume at least 2 liters of water per day.",
    "advantadgeTheUserWillGain": "Proper hydration helps maintain bodily functions, improves skin health, aids digestion and prevents fatigue.",
    "levelOfImportance": "severe"
  },
  {
    "title": "Increase Physical Activity",
    "description": "Your active energy burned data and exercise time suggests low physical activity. It's important to incorporate regular exercise into your routine.",
    "advantadgeTheUserWillGain": "Regular physical activity boosts health, improves mood, enhances quality of life, and aids in weight management.",
    "levelOfImportance": "severe"
  },
  {
    "title": "Stand More Often",
    "description": "Your Stand Hours data indicates prolonged periods of inactivity. Consider using reminders to stand up and move around every hour.",
    "advantadgeTheUserWillGain": "Regular movement can improve circulation, burn calories and decrease health risks associated with prolonged sitting.",
    "levelOfImportance": "light"
  }
]
"""

func getTestCards() -> [AppleHealthKit] {
    let jsonData = test_json.data(using: .utf8)!
    do {
      let decoder = JSONDecoder()
      let tableData = try decoder.decode([AppleHealthKit].self, from: jsonData)
        return tableData
    }
    catch {
      print (error)
    }
    
    return []
}

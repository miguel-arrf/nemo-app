//
//  OnboardingExplanationView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 19/07/2023.
//

import SwiftUI

struct OnboardingExplanation_BackgroundItemView: View {
    var card: Card
    
    var body: some View {
        HStack() {
            Text(card.type)
                .font(.body)
                .fontWeight(.bold)
                .lineSpacing(22)
                .foregroundColor(.white)
            
            Spacer()
            Text(card.value)
                .font(Font.custom("SF Pro", size: 15))
                .lineSpacing(20)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                .background(.blue)
                .cornerRadius(40)
        }
        .padding(12)
        .background(Color(red: 1, green: 1, blue: 1).opacity(0.26))
        .cornerRadius(12)
    }
}

struct Card: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: UUID = .init()
    var type: String
    var value: String
    
    init(_ type: String, _ value: String) {
        self.type = type
        self.value = value
    }
}

struct OnboardingExplanationView: View {
    var onGotItButton: () -> Void = {}

    var animationDelay: Double = 2.0
    static var items: Int =  10
    
    /// Variables used for animations:
    @State private var bottomTextAndButtonSectionOffset: Double = 0
    @State private var mockupInfoOffset: Double = 0
    
    @State private var scrollDisabled: Bool = true
    @State private var showingCard: [Bool] = .init(repeating: false, count: items)
    private var cardsText: [Card] = [
        .init("Name", "V"), .init("Work place", "Sword"), .init("Age", "I don't really know"),
        .init("Random", "Random"),.init("Random", "Random"),.init("Random", "Random"), .init("Random", "Random"), .init("Random", "Random"), .init("Random", "Random"), .init("Random", "Random")
    ]
    
    init(animationDelay: Double = 0.0, onGotItButton: @escaping () -> Void = {}) {
        self.animationDelay = animationDelay
        self.onGotItButton = onGotItButton
    }
    
    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.45, green: 0.65, blue: 1), Color(red: 0, green: 0.48, blue: 1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 60)
                    
                    
                    Group {
                        ForEach(cardsText, id: \.id) { card in
                            let index = cardsText.firstIndex(of: card)
                            if showingCard[index!] {
                                OnboardingExplanation_BackgroundItemView(card: card)
                                    .padding(.horizontal)
                                    .transition(.scale)
                            }
                          
                        }
                       
                    }
                    
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 300)
                    
                  
                }
            }
            .scrollDisabled(scrollDisabled)
            
            VStack {
                Spacer()
                VariableBlurView()
                    .frame(height: 360)
                    .allowsHitTesting(false)
                    .rotationEffect(.degrees(180))
                    .offset(y: bottomTextAndButtonSectionOffset)
            }
            .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 18) {
                Spacer()
                
                HStack {
                    Text("Dory is yours.")
                        .font(.title2)
                        .fontWeight(.bold)
                      .foregroundColor(Color(red: 0.05, green: 0.13, blue: 0.22))
                      
                    Spacer()
                }
                
                HStack {
                    Text("With the help of an onboarding process, you will gain access to a customised personal assistant, tailored for your needs and personality.")
                      .font(Font.custom("SF Pro", size: 20))
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .foregroundColor(Color(red: 0.05, green: 0.13, blue: 0.22))
                    Spacer()
                }
                
              HStack(spacing: 4) {
                Text("Got It")
                  .font(Font.custom("SF Pro", size: 17))
                  .lineSpacing(22)
                  .foregroundColor(.white)
              }
              .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
              .frame(maxWidth: .infinity)
              .background(Color(red: 0, green: 0.20, blue: 0.42))
              .cornerRadius(12)
              .onTapGesture {
                  onGotItButton()
                  withAnimation {
                      withAnimation(.spring().delay(0.4)) {
                          bottomTextAndButtonSectionOffset = 300
                      }
                  }
                  
                  toggleCards(to: false)
              }
            
                
            }
            .offset(y: bottomTextAndButtonSectionOffset)
            .padding(.horizontal)
            .padding(.horizontal)

        }
        .onAppear {
            toggleCards(to: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 + animationDelay, execute: {
                scrollDisabled = false
            })

        }
    }
    
    func toggleCards(to: Bool) {
        for (index, _) in showingCard.enumerated() {
            DispatchQueue.main.async {
                withAnimation(.spring().delay(Double(index)/10.0 + animationDelay)) {
                    showingCard[index] = to
                }
            }
        }
    }
    
}

struct OnboardingExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingExplanationView()
    }
}

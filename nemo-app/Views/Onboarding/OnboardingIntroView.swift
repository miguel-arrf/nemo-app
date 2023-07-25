//
//  OnboardingIntroView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 19/07/2023.
//

import SwiftUI

struct OnboardingIntroView: View {
    
    var onStartButtonClick: () -> Void = {}
    
    /// Circle offsets:
    @State private var firstCircleOffset: Double = 0
    @State private var secondCircleOffset: Double = 0
    @State private var thirdCircleOffset: Double = 0
    @State private var fourthCircleOffset: Double = 0
    
    /// Text and content offsets:
    @State private var buttonAndTitleOffset: Double = 0

    
    var body: some View {
        ZStack {
            // Gradient background:
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.45, green: 0.65, blue: 1), location: 0.00),
                    Gradient.Stop(color: .white, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
            .ignoresSafeArea()
            
            // Ellipses:
            ZStack {
                Ellipse()
                   .foregroundColor(.clear)
                   .frame(width: 268, height: 268)
                   .overlay(
                     Ellipse()
                       .inset(by: 0.50)
                       .stroke(.white, lineWidth: 0.50)
                   )
                   .offset(x: -0.46, y: -314 - firstCircleOffset)
                   .opacity(firstCircleOffset != .zero ? 0 : 1)
                
                 Ellipse()
                   .foregroundColor(.clear)
                   .frame(width: 418.08, height: 418.08)
                   .overlay(
                     Ellipse()
                       .inset(by: 0.78)
                       .stroke(.white, lineWidth: 0.78)
                   )
                   .offset(x: -0.26, y: -295.96 - secondCircleOffset)
                   .opacity(secondCircleOffset != .zero ? 0 : 1)

                 Circle()
                   .foregroundColor(.clear)
                   .frame(width: 500)
                   .overlay(
                     Ellipse()
                       .inset(by: 0.84)
                       .stroke(.white, lineWidth: 0.84)
                   )
                   .offset(x: -0, y: -260.54 - thirdCircleOffset)
                   .opacity(thirdCircleOffset != .zero ? 0 : 1)

                 Ellipse()
                   .foregroundColor(.clear)
                   .frame(width: 634.09, height: 634.09)
                   .overlay(
                     Ellipse()
                       .inset(by: 1.18)
                       .stroke(.white, lineWidth: 1.18)
                   )
                   .offset(x: 0, y: -220.96 - fourthCircleOffset)
                   .opacity(fourthCircleOffset != .zero ? 0 : 1)

            }
            .offset(y: -100)
            
            VStack {
                Spacer()
                
                Text("Welcome to the start of your health revolution.")
                    .multilineTextAlignment(.leading)
                    .font(.title)
                    .foregroundColor(Color(red: 0.05, green: 0.13, blue: 0.22))
                    .frame(width: 327, alignment: .leading)
                
                HStack(spacing: 4) {
                    Text("Start")
                        .font(Font.custom("SF Pro", size: 17))
                        .lineSpacing(22)
                        .foregroundColor(.white)
                }
                .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                .frame(width: 327, height: 50)
                .background(Color(red: 0, green: 0.20, blue: 0.42))
                .cornerRadius(12)
                .onTapGesture {
                    onStartButtonClick()
                    
                    withAnimation(.spring().delay(0)) {
                        firstCircleOffset = 200
                    }
                    
                    withAnimation(.spring().delay(0.2)) {
                        secondCircleOffset = 200
                    }
                    
                    withAnimation(.spring().delay(0.4)) {
                        thirdCircleOffset = 200
                    }
                    
                    withAnimation(.spring().delay(0.6)) {
                        fourthCircleOffset = 200
                    }
                    
                    withAnimation(.spring().delay(0.4)) {
                        buttonAndTitleOffset = 200
                    }
                    
                }
            }
            .offset(y: buttonAndTitleOffset)
            
        }
      
    }
}

struct OnboardingIntroView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingIntroView()
    }
}

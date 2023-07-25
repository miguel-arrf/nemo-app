//
//  OnboardingView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 19/07/2023.
//

import SwiftUI

enum OnboardingStep {
    case intro, explanation, chat
}

struct OnboardingView: View {
    
    @State private var onboardingStep: OnboardingStep = .intro
    @State var onContinuePressed: () -> Void = {}
    
    var body: some View {
        ZStack {
            
            if onboardingStep == .chat {
                OnboardingChatView {
                    onContinuePressed()
                }
                    .transition(.opacity.animation(.default.delay(0.5)))
            }
            
            if onboardingStep == .explanation {
                OnboardingExplanationView(animationDelay: 1.0) {
                    onboardingStep = .chat
                }
                    .transition(.opacity.animation(.default.delay(0.6)))
            }
            
            if onboardingStep == .intro {
                OnboardingIntroView {
                        onboardingStep = .explanation
                }
                .transition(.opacity.animation(.default.delay(0.6)))
            }
            
            
        }
        .animation(.default, value: onboardingStep)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

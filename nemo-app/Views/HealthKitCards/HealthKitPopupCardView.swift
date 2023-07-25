//
//  HealthKitPopupCardView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 21/07/2023.
//

import Foundation
import SwiftUI

struct HealthKitCardPopupView: View {
    var card: AppleHealthKit
    
    var onDismiss: () -> Void = {}
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text(card.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(card.getTitleColor())
                
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
            
            Divider()
            
            Text(card.advantadgeTheUserWillGain)
                .foregroundColor(card.getDescriptionColor())
            
            Button {
                withAnimation {
                    onDismiss()
                }
            } label: {
                Text("Got it")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(card.getLevelTextColor())
            
        }
        .padding(.horizontal)
        .padding()
        .padding(.top, 6)
        .padding(.bottom)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundColor(.white)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.gray.opacity(0.1), lineWidth: 2)
        }
        .padding(.horizontal)
        
        .ignoresSafeArea()
        
    }
}

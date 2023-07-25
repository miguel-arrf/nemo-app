//
//  PlanCardView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 22/07/2023.
//

import SwiftUI



struct PlanCardView: View {
    var plan: PlanInnerModel
    @State private var playingPlan: Bool = false
    var body: some View {
        VStack {
            ViewThatFits {
                HStack {
                    Text(plan.planName)
                        .bold()
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("\(plan.exercisesNames.count) exercises \(Image(systemName: "figure.run"))")
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1), in: Capsule())

                    
                    Text("\(plan.estimatedDuration) \(Image(systemName: "hourglass"))")
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1), in: Capsule())
                }
                
                VStack {
                    Text(plan.planName)
                        .bold()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    HStack {
                        Text("\(plan.exercisesNames.count) exercises \(Image(systemName: "figure.run"))")
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1), in: Capsule())

                        
                        Text("\(plan.estimatedDuration) \(Image(systemName: "hourglass"))")
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1), in: Capsule())
                        
                        Spacer()
                    }
                }
            }
                
            Text(plan.description)
                .foregroundColor(.black.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Button(action: {
                    playingPlan = true
                }, label: {
                    Text("Play \(Image(systemName: "play.fill"))")
                })
                .controlSize(.mini)
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                .tint(.black)
                Spacer()
            }
        }
      
        .padding()
        .background(.white)
        .cornerRadius(12)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.50)
            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
        )
        .sheet(isPresented: $playingPlan, content: {
            PlanExecutorView(plan: .init(plan: plan))
        })
    }
}

struct PlanCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.96)
            VStack {
                PlanCardView(plan: .init(planName: "The Jellysifh Jumpstart Dive", exercisedNames: ["Teste", "Shoulder Rolls", "Knee Extension", "Ankle Pumps"], estimatedDuration: 20, description: "A combination of shoulder, knee, and ankle exercises to improve mobility and flexibility.", id: .init()))
                
                PlanCardView(plan: .init(planName: "Dolphin Dive", exercisedNames: ["Shoulder Rolls", "Knee Extension", "Ankle Pumps"], estimatedDuration: 20, description: "A combination of shoulder, knee, and ankle exercises to improve mobility and flexibility.", id: .init()))
                
                PlanCardView(plan: .init(planName: "Dolphin Dive", exercisedNames: ["Shoulder Rolls", "Knee Extension", "Ankle Pumps"], estimatedDuration: 20, description: "A combination of shoulder, knee, and ankle exercises to improve mobility and flexibility.", id: .init()))
            }
            .padding()
        }
    }
}

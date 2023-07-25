//
//  PlanBuilderView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 22/07/2023.
//

import SwiftUI

struct PlanBuilderCardView: View {
    @Binding var showingTextField: Bool
    
    var plan: PlanChatModel
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 14) {
                
                /*
                 .background(Color(red: 1, green: 1, blue: 1).opacity(0.20))
                 .cornerRadius(12.80)
                 */
                VStack {
                    HStack {
                        Spacer()
                        
                        Text(Image(systemName: "laurel.leading"))
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                        
                        Text(plan.planPreview.planName)
                            .multilineTextAlignment(.center)
                            .bold()
                            .foregroundColor(.white)
                            .font(.title3)
                        
                        
                        Text(Image(systemName: "laurel.trailing"))
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                    }
                    .padding()
                    .padding(.top, 6)
                    
                    HStack {
                        Spacer()
                        
                        Text("\(plan.planPreview.exercisesNames.count) exercises \(Image(systemName: "figure.run"))")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2), in: Capsule())
                        
                        
                        Text("\(plan.planPreview.estimatedDuration) \(Image(systemName: "hourglass"))")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2), in: Capsule())
                        
                        Spacer()
                    }
                    .foregroundColor(.white.opacity(1.0))
                    
                    
                    Text(plan.planPreview.description)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(red: 1, green: 1, blue: 1).opacity(0.20))
                        .cornerRadius(12.80)
                        .padding()
                }
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.92, green: 0.41, blue: 0.73), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.21, green: 0.22, blue: 0.62), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 1.18),
                        endPoint: UnitPoint(x: 0.5, y: 0)
                    )
                )
                .cornerRadius(27)
                .overlay(
                    RoundedRectangle(cornerRadius: 27)
                        .inset(by: 0.7)
                        .stroke(Color(red: 0.37, green: 0.64, blue: 0.9).opacity(0.2), lineWidth: 1.4)
                )
                
                VStack {
                    
                    
                    ForEach(plan.planPreview.exercisesNames, id: \.self) { exercise in
                        HStack(spacing: 6) {
                            Text("\(Image(systemName: "figure.dance")) | ")
                                .bold()
                                .lineSpacing(14.08)
                                .foregroundColor(.black)
                            
                            Text("\(exercise)")
                                .bold()
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding()
                        .frame(width: 330, height: 59)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .inset(by: 0.50)
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                        )
                    }
                    
                    
                    Spacer()
                }
               
                Rectangle()
                    .frame(height: showingTextField ? 380 : 300)
                    .foregroundColor(.clear)
            }
            
        }
    }
}

struct PlanBuilderView: View {
    @State private var message: String = ""
    @State private var showingTextfield: Bool = false
    @State private var plan: PlanChatModel?
    
    @State private var loading: Bool = true
    @State private var buttonsDisabled: Bool = false
    
    var debugging: Bool = false
    var onDismiss: (PlanChatModel?) -> Void = { _ in }
    
    var body: some View {
        VStack() {
            
            Text("Plan Builder")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title2)
                .bold()
                .padding(EdgeInsets(top: 30, leading: 28, bottom: 0, trailing: 12))
            
            
            Spacer()
            
            if let plan = plan {
                VStack {
                    PlanBuilderCardView(showingTextField: $showingTextfield, plan: plan)
                        .padding(EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 28))
                    Spacer()
                }
            }
            
        }
        .background {
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()
        }
//        .overlay(alignment: .bottom, content: {
//            VStack {
//                Spacer()
//                VariableBlurView()
//                    .frame(height: 300)
//                    .allowsHitTesting(false)
//                    .rotationEffect(.degrees(180))
//            }
//            .ignoresSafeArea()
//        })
        .overlay(alignment: .bottom, content: {
            VStack(spacing: 16){
                if let plan = plan {
                    Text(String(describing: plan.assistantMessage))
                        .padding()
                        .frame(width: 330, alignment: .leading)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .inset(by: 0.50)
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                        )
                        .padding(EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 28))
                        .overlay(alignment: .topTrailing, content: {
                            Button(action: {
                                withAnimation(.spring()) {
                                    if !loading {
                                        showingTextfield.toggle()
                                    }
                                }
                            }, label: {
                                Label("", systemImage: "message.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .labelsHidden()
                                    .labelStyle(.iconOnly)
                                    .frame(width: 60, height: 60)
                                    .background(Circle().foregroundColor(.black))
                            })
                            .offset(y: -100)
                            .offset(x: -20)
                            
                        })
                    
                    if let buttons = plan.interface.button {
                        
                        ScrollView(.horizontal) {
                            HStack {
                                Rectangle().foregroundColor(.clear).frame(width: 28, height: 0)
                                ForEach(buttons, id: \.self) { button in
                                    Button(action: {
                                        sendMessage(message: button)
                                    }, label: {
                                        Text(button)
                                            .bold()
                                            .padding(6)
                                    })
                                    .disabled(buttonsDisabled)
                                    .buttonBorderShape(.roundedRectangle)
                                    .buttonStyle(.borderedProminent)
                                    .tint(.black)
                                }
                            }
                            .offset(x: -4)
                        }
                    }
                    
                    // TODO: Sliders and toggles are disabled for now...
//                    if let sliders = plan.interface.slider {
//                        Text("slider")
//                    }
//                    if let toggles = plan.interface.toggle {
//                        Text("toggle")
//                    }
                }
                
                if showingTextfield {
                    HStack(spacing: 0) {
                        TextField("", text: $message, prompt: Text("Message").foregroundColor(.white.opacity(0.5)))
                            .foregroundColor(.white)
                            .font(Font.custom("SF Pro", size: 16).weight(.bold))
                        
                        Spacer()
                        
                        Text(Image(systemName: "paperplane.fill"))
                            .fontWeight(.bold)
                            .lineSpacing(22)
                            .foregroundColor(.white)
                            .onTapGesture {
                                if !message.isEmpty {
                                    sendMessage(message: message)
                                    message.removeAll()
                                }
                            }
                    }
                    .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                    .frame(width: 330, height: 56)
                    .background(.black)
                    .cornerRadius(13)
                    .transition(.scale.combined(with: .opacity).combined(with: .offset(y: 60)))
                }
                
                HStack(spacing: 0) {
                    Spacer()
                   Text("Save Plan \(Image(systemName: "square.and.arrow.down"))")
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                .frame(width: 330, height: 56)
                .background(.black)
                .cornerRadius(13)
                .transition(.scale.combined(with: .opacity).combined(with: .offset(y: 60)))
                .onTapGesture(perform: {
                    onDismiss(plan)
                })
               
            }
            .padding(.top, 24)
            .padding(.bottom, 30)
            .background(
                Color.white
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                    )
            )
           
        })
        .redacted(reason: loading ? .placeholder : .privacy)
        .ignoresSafeArea(.container, edges: .all)
        .onAppear {
            Task {
                await getAutomaticPlan(start: true)
            }
        }
    }
    
    /*
     VStack {
     Spacer()
     VariableBlurView()
     .frame(height: 140)
     .allowsHitTesting(false)
     .rotationEffect(.degrees(180))
     }
     .ignoresSafeArea()
     */
    
    func sendMessage(message: String) {
        Task {
            withAnimation {
                buttonsDisabled = true
            }
            
            print("PlanBuilder: \(message)")
            await getAutomaticPlan(message: "User pressed the button with the label: '\(message)'", start: false)
        }
    }
    
    func getAutomaticPlan(message: String = "", start: Bool) async {
        if start {
            let plan: PlanChatModel =  .init(planPreview: .init(planName: "The Aquatic Adventure", exercisesNames: ["Shoulder Rols", "Knee Extension", "Arm Raises", "Hip Flexion", "Squats"], estimatedDuration: 40, description: "A balanced workout plan targeting your upper and lower body. Perfect for beginners and intermediate users"), assistantMessage: "Here's a preview of your plan, 'The Aquatic Adventure'. Would you like to modify it?", interface: .init(button: ["Change Exercises", "Change Duration", "Change Difficulty"], toggle: nil, slider: nil))
            
            withAnimation {
                self.plan = plan
            }
        }
        
        if !debugging {
            
            let network: Networking = await .init()
            let result: Result<PlanChatModel, NetworkingError> = await network.performRequest(endpoint: API.addPlanByChatting(planChatSchema: .init(user_id: User.shared.id, message: message, start: start)))
            print("Result is: \(result)")
            switch result {
            case .success(let onboardingAnswer):
                print("success: \(onboardingAnswer)")
                withAnimation {
                    buttonsDisabled = false
                    self.plan = onboardingAnswer
                    self.loading = false
                }
            case .failure(let failure):
                print("Failure: \(failure) <-> \(failure.localizedDescription)")
            }
        } else {
            self.loading = false
        }
        
        
    }
    
}

struct PlanBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("")
        }
        .sheet(isPresented: .constant(true), content: {
            PlanBuilderView(debugging: true)
        })
    }
}

//
//  OnboardingChatView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 20/07/2023.
//

import SwiftUI

struct Chat: Identifiable, Equatable {
    var id: UUID = .init()
    var sent: Bool
    var message: String
}

struct OnboardingCardView: View {
    var chat: Chat
    var body: some View {
        HStack {
            if chat.sent {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(chat.message)
                    .font(.body)
                    .fontDesign(.serif)
                    .foregroundColor(.white.opacity(chat.sent ? 1 : 0.5))
                    .frame(alignment: .leading)

            }
            .padding(10)
            .background(.ultraThinMaterial.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
            .padding(.top)
            .frame(maxWidth: 260, alignment: chat.sent ? .trailing : .leading)
           
            if !chat.sent {
                Spacer()
            }
        }
    }
}

struct OnboardingChatView: View {

    @State var messages: [Chat] = []
    @State var message: String = ""
    @State var completed: Bool = false
    @State var onContinuePressed: () -> Void = {}
    
    var body: some View {
        ZStack {
//            Color(red: 0, green: 0.48, blue: 1)
//                .ignoresSafeArea()
            
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.07, green: 0.04, blue: 0.78), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.02, green: 0.01, blue: 0.22), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
              
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(messages, id: \.id) { message in
                            OnboardingCardView(chat: message)
                                .id(message.id)
                                .tag(message.id)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .scale(scale: 0.5)))
                        }
                        
                        Rectangle()
                            .id("last_rectangle")
                            .tag("last_rectangle")
                            .foregroundColor(.clear)
                            .frame(width: 1, height: 200)
                    }
                    .onChange(of: messages, perform: { newMessages in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                withAnimation {
                                    scrollProxy.scrollTo("last_rectangle")
                                }
                        })
                    })
                }
               
            }
            .animation(.spring(), value: messages)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .top, content: {
                VStack {
                    VariableBlurView()
                        .frame(height: 80)
                        .allowsHitTesting(false)
                    Spacer()
                }
                .ignoresSafeArea()
            })
            .overlay(alignment: .bottom, content: {
                VStack {
                    Spacer()
                    VariableBlurView()
                        .frame(height: completed ? 180 : 140)
                        .allowsHitTesting(false)
                        .rotationEffect(.degrees(180))
                }
                .ignoresSafeArea()
            })
            .overlay(alignment: .bottom, content: {
                VStack(spacing: 0, content:  {
                  
                    HStack {
                     
                        
                        TextField(text: $message, prompt: Text("Message").foregroundColor(.white.opacity(0.6)), label: {
                            Text("Onboarding message")
                                .foregroundColor(.white)
                        })
                        .foregroundColor(.white)
                        .textFieldStyle(OnboardingChatViewStyle())
                        
                        Text(Image(systemName: "paperplane.fill"))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .onTapGesture {
                                sendMessage(messageToSend: message)
                                
                                withAnimation {
                                    messages.append(.init(sent: true, message: message))
                                }
                                withAnimation {
                                    message = ""
                                }
                                
                            }
                    }
                    .onboardingChatViewTextfieldWithIcon()
                    .padding(.bottom)
                    
                    if completed {
                        
                        Button(action: {
                            onContinuePressed()
                        }, label: {
                            Text("Continue")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            
                        })
                        .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.55, green: 0.51, blue: 0.7))
                        .cornerRadius(12)
                        .padding(.bottom)
                        .transition(.scale.combined(with: .opacity).combined(with: .offset(y: 60)))
        
                    }
                })
                .padding(.horizontal)
                .padding(.horizontal)

            })
            .animation(.spring(), value: completed)
//            .frame(width: 327)
         
            
            
        }
        .onAppear {
        sendMessage()
        }
    }
    
    func sendMessage(messageToSend: String = "") {
        struct ResetUserModel: Codable {
            var message: String
        }
        
        
        Task {
            let network: Networking = await .init()

            let resetUserResult: Result<ResetUserModel, NetworkingError> = await network.performRequest(endpoint: API.reset(resetSchema: .init(user_id: User.shared.id, tables: ["messages", "info"])))
            
            switch resetUserResult {
            case .success(_):
                print("Reseted messages and info sucessfully")
            case .failure(_):
                print("Failured reseting messages and info tables...")
            }
            
            let result: Result<OnboardingModel, NetworkingError> = await network.performRequest(endpoint: API.onboarding(onboardingEndpointSchema: .init(user_id: User.shared.id, message: messageToSend)))
            
            switch result {
            case .success(let onboardingAnswer):
                withAnimation {
                    messages.append(.init(sent: false, message: onboardingAnswer.message ))
                }
                
                if !completed {
                    if onboardingAnswer.overallOnboardingDone {
                        withAnimation {
                            completed = true
                        }
                    }
                }
                
                print("success: \(onboardingAnswer.message), \(onboardingAnswer.overallOnboardingDone)")
            case .failure(let failure):
                print("Failure: \(failure) <-> \(failure.localizedDescription)")
            }
        }
        
    }
    
}

struct OnboardingChatView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingChatView(messages: [.init(sent: true, message: "I'm adelaide"), .init(sent: true, message: "I'm adelaide I'm adelaide I'm adelaide I'm adelaide I'm adelaide I'm adelaide I'm adelaide I'm adelaide I'm adelaide I'm adelaide I'm adelaide I'm adelaide I'm adelaide ")])
    }
}


struct OnboardingChatView_TextfieldWithIcon_Style: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.trailing, 20)
            .background(
                .white.opacity(0.2)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.black.opacity(0.05))
            )
            .overlay(content:  {
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.50)
                    .stroke(
                        Color(red: 1, green: 1, blue: 1).opacity(0.06), lineWidth: 0.50
                    )
            })
    }
    
}

extension View {
    func onboardingChatViewTextfieldWithIcon() -> some View {
        modifier(OnboardingChatView_TextfieldWithIcon_Style())
    }
}


struct OnboardingChatViewStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(.plain)
            .padding(.vertical, 4)
            .padding(.trailing, 14)
            .padding(.leading, 14)
            .cornerRadius(12)
    }
}

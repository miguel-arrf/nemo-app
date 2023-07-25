//
//  ChatView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 21/07/2023.
//

import SwiftUI

struct ChatView: View {
    
    @State var messages: [Chat] = .init()
    @State private var message: String = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()
            
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    ForEach(messages, id: \.id) { message in
                        
                        ChatCardView(chat: message)
                            .padding()
                    }
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 200)
                }
            }
            
            VStack {
                Spacer()
                VariableBlurView()
                    .frame(height: 140)
                    .allowsHitTesting(false)
                    .rotationEffect(.degrees(180))
            }
            .ignoresSafeArea()

            
        }
        .overlay(alignment: .bottom, content: {
            HStack(spacing: 0) {
                TextField("", text: $message, prompt: Text("Message").foregroundColor(.white.opacity(0.5)))
                .foregroundColor(.white)
                .font(Font.custom("SF Pro", size: 16).weight(.bold))
                .onSubmit {
                    if !message.isEmpty {
                        messages.append(.init(sent: true, message: message ))
                        sendMessage(messageToSend: message)
                        message.removeAll()
                    }
                }
                
                Spacer()
                
              Text(Image(systemName: "paperplane.fill"))
                    .fontWeight(.bold)
                .lineSpacing(22)
                .foregroundColor(.white)
                .onTapGesture {
                    if !message.isEmpty {
                        messages.append(.init(sent: true, message: message ))
                        sendMessage(messageToSend: message)
                        message.removeAll()
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
            .frame(width: 330, height: 56)
            .background(.black)
            .cornerRadius(13)
            .padding(.bottom)
            .padding(.bottom)
        })
    }
    
    func sendMessage(messageToSend: String = "") {
        Task {
            let network: Networking = await .init()
            let result: Result<ChatModel, NetworkingError> = await network.performRequest(endpoint: API.getChat(onboardingChatSchema: .init(user_id: User.shared.id, message: messageToSend)))
            print("Result is: \(result)")
            switch result {
            case .success(let onboardingAnswer):
                withAnimation {
                    messages.append(.init(sent: false, message: onboardingAnswer.message ))
                }

                print("success: \(onboardingAnswer.message)")
            case .failure(let failure):
                print("Failure: \(failure) <-> \(failure.localizedDescription)")
            }
        }
        
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(messages: [
            .init(sent: true, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: false, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: true, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: false, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: true, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: false, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: true, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: false, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: true, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: false, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: true, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: false, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: true, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: false, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: true, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: false, message: "This is a test message super cool This is a test message super cool!"),
            .init(sent: true, message: "This is a test message super cool This is a test message super cool!"),
        ])
    }
}

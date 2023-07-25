//
//  ChatCardView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 21/07/2023.
//

import SwiftUI

struct ChatCardView: View {
    var chat: Chat
    var body: some View {
        HStack {
            if chat.sent {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                if !chat.sent {
                    HStack {
                        
                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.34, green: 0.80, blue: 0.95), Color(red: 0.18, green: 0.50, blue: 0.93)]), startPoint: .top, endPoint: .bottom))
                                

                            Circle()
                                .stroke(.gray.opacity(0.2), lineWidth: 2)
                        }
                        .frame(width: 14)
                             
                           
                          
                        
                           Text("Dory")
                            .fontWeight(.bold)
                            .font(.caption)
                             .lineSpacing(14.08)
                             .foregroundColor(.black)
                    }
                }
                

                Text(chat.message)
                  .foregroundColor(.black)
                  .opacity(0.50)
                  .frame(alignment: .leading)
                
            }
            .frame(maxWidth: 200, alignment: chat.sent ? .trailing : .leading)

            .padding(10)
            .background(.white)
            .cornerRadius(12)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.50)
                .stroke(
                  Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.50), lineWidth: 0.50
                )
            )
   
            
            
            if !chat.sent {
                Spacer()
            }
        }
      
    }
}

struct ChatCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatCardView(chat: .init(sent: true, message: "This is a test message super cool This is a test message super cool!"))
            ChatCardView(chat: .init(sent: false, message: "This is a test message super cool! This is a test message super cool"))
            ChatCardView(chat: .init(sent: true, message: "This is a test message super cool!"))
        }
    }
}

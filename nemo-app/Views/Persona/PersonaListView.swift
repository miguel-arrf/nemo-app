//
//  PersonaListView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 23/07/2023.
//

import SwiftUI

struct PersonaGenerateModel: Codable {
    var summary: String
    var dropout_risk: Int
}

struct GetInfoModel: Codable, Hashable {
    var info: [GetInfoInnerModel]
    
    struct GetInfoInnerModel: Codable, Hashable {
        var agent: String
        var created_at: String
        var id: String
        var info: String
        var tag: String
    }
}

struct PersonaCardView: View {
    
    var tintColor: Color
    var persona: PersonaGenerateModel

    init(persona: PersonaGenerateModel) {
        self.persona = persona
        
        if persona.dropout_risk >= 70 {
            tintColor = .red
        } else if persona.dropout_risk < 70 && persona.dropout_risk >= 40 {
            tintColor = .yellow
        } else {
            tintColor = .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(persona.summary)
            HStack(alignment: .center) {
                Text("Dropout Risk:")
                    .fontWeight(.black)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.8))
                
                ProgressView(value: Float(persona.dropout_risk), total: 100)
                    .progressViewStyle(.linear)
                    .tint(tintColor)
            }
            .padding()
            .background(Color.gray.opacity(0.1), in: Capsule())
        }
        .padding()
        .background {
            Color.white
        }
        .cornerRadius(10)
    }
}


func extractDateTimeInfo(from string: String) -> (Int, Int, Int, Int)? {
    // Create a DateFormatter and set its format/settings
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ" // format string matches the incoming string
    formatter.locale = Locale(identifier: "en_US_POSIX") // Using "en_US_POSIX" is a best practice to ensure correct date parsing
    
    // Parse the string into a Date
    if let date = formatter.date(from: string) {
        // Create a Calendar component and extract the required fields
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
        
        // Return the fields
        return (components.month!, components.day!, components.hour!, components.minute!)
    } else {
        // If the string couldn't be parsed
        return nil
    }
}

struct InfoCardView: View {
    var info: GetInfoModel.GetInfoInnerModel
    @State var pressed: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Agent: \(info.agent)")
                    .bold()
                
                Spacer()

                if let (month, day, hour, minute) = extractDateTimeInfo(from: info.created_at   ) {
                   Text("\(day)/\(month) \(hour):\(minute) \(Image(systemName: "calendar.badge.clock"))")
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.gray.opacity(0.2), in: Capsule())
                }
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Saved information:")
                    .bold()
                
                Text(info.info)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            HStack {
                Text(info.tag)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.2), in: Capsule())
                Spacer()
            }
            
        
            
        }
        .padding()
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .padding()

    }
}

struct PersonaListView: View {
    @State var infos: [GetInfoModel.GetInfoInnerModel] = .init()
    @State var persona: PersonaGenerateModel?
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 14) {
                    if let persona = persona {
                        PersonaCardView(persona: persona)
                            .padding()
                    }
                    
                    if !infos.isEmpty {
                        if persona != nil {
                            Divider()
                        }
                        
                        HStack {
                            Text("Info:")
                                .bold()
                                .font(.title2)
                                .padding()
                                
                            Spacer()
                        }
                            
                        
                        ForEach(infos, id: \.self) { info in
                            InfoCardView(info: info)
                                .padding(.horizontal)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                }
                .animation(.spring(), value: infos)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                Task {
                    await obtainPersona()
                }
                
                Task {
                    await obtainInfo()
                }
            }
            
            VStack {
                VariableBlurView()
                    .frame(height: 60)
                    .allowsHitTesting(false)
                Spacer()
            }
            .ignoresSafeArea()
            
        }
        .navigationTitle("Persona")
       
    }
    
    func obtainInfo() async {
        let network: Networking = await .init()
        
        let result: Result<GetInfoModel, NetworkingError> = await network.performRequest(endpoint: API.getInfo(user_id: User.shared.id))
        switch result {
        case .success(let info):
            withAnimation {
                self.infos = info.info
            }
            
        case .failure(let failure):
            print("Failure obtaining info: \(failure) <-> \(failure.localizedDescription)")
        }
    }
    
    func obtainPersona() async {
        let network: Networking = await .init()
        
        let result: Result<PersonaGenerateModel, NetworkingError> = await network.performRequest(endpoint: API.generatePersona(user_id: User.shared.id))
        switch result {
        case .success(let generatedPersona):
            withAnimation {
                self.persona = generatedPersona
            }
            
        case .failure(let failure):
            print("Failure obtaining persona: \(failure) <-> \(failure.localizedDescription)")
        }
    }
    
}

//struct PersonaListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonaListView()
//    }
//}


struct PersonaCardView_Previews: PreviewProvider {
    static var previews: some View {
        PersonaCardView(persona: .init(summary: "teste teste teste testete tet atjapotjhaptogahtopahtpathapot apwothapoet apethapiegt apehtapoet", dropout_risk: 23))
    }
}

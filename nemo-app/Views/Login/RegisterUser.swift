//
//  RegisterUser.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 22/07/2023.
//

import SwiftUI

struct RegisterUser: View {
    
    @State private var userName: String = ""
    @State private var userID: String = ""
    @State private var domain: String = ""
    @State private var port: Int = 5001
    @State private var hasPort: Bool = false

    var onSuccess: (Bool) -> Void = {_ in}
    
    @State private var success: Bool?
    
    init(onSuccess: @escaping (Bool) -> Void = {_ in}) {
        self.onSuccess = onSuccess
        let defaults = UserDefaults.standard
        
        let userName = defaults.object(forKey:"userName") as? String
        let userID = defaults.object(forKey:"userID") as? String
        let domain = defaults.object(forKey:"domain") as? String
        let port = defaults.object(forKey:"port") as? Int
        let hasPort = defaults.bool(forKey: "hasPort")
        print("hasPort: ", hasPort)
        if let userName = userName {
            self._userName = .init(initialValue: userName)
        }
        
        if let userID = userID {
            self._userID = .init(initialValue: userID)
        }
        
        if let domain = domain {
            self._domain = .init(initialValue: domain)
        }
        
        if let port = port {
            self._port = .init(initialValue: port)
        }
        
        self._hasPort = .init(initialValue: hasPort)
    }
    
    func save(userName: String, userID: String) {
        let defaults = UserDefaults.standard
        defaults.set(userName, forKey: "userName")
        defaults.set(userID, forKey: "userID")
    }
    
    func saveDomainAndPort(domain: String, port: Int) {
        let defaults = UserDefaults.standard
        defaults.set(domain, forKey: "domain")
        defaults.set(port, forKey: "port")
    }
    
    func saveHasPort(hasPort: Bool) {
        print("saving has port: \(hasPort)")
        let defaults = UserDefaults.standard
        defaults.set(hasPort, forKey: "hasPort")
    }
    
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("UserName", text: $userName)
                    TextField("Domain", text: $domain)

                    TextField("Port", value: $port, format: .number)
                    
                    Toggle("Has Port", isOn: $hasPort)

                    if !userID.isEmpty {
                        Text("User ID: \(userID)")
                    }
                    
                    Button("Register", action: {
                        Task {
                            await registerUser()
                        }
                    })
                    
                    if let success = success {
                        if !success {
                            Text("There was an error")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Enter")
        }
        .onChange(of: hasPort, perform: { newValue in
            saveHasPort(hasPort: newValue)
        })
    }
    
    struct AddUserModel: Codable {
        var message: String
        var user_id: String
        var onboarding_status: Bool
    }
    
    func registerUser() async {
        let network: Networking = await .init()
        
       
            saveDomainAndPort(domain: domain, port: Int(port))
            saveHasPort(hasPort: hasPort)
        
        print("logging in for username: \(userName)")
        let result: Result<AddUserModel, NetworkingError> = await network.performRequest(endpoint: API.addUser(username: userName))
            print("Result is: \(result)")
            switch result {
            case .success(let addedUser):
                print("success: \(addedUser)")
             
                    save(userName: userName, userID: addedUser.user_id)
                    success = true
                User.shared.id = addedUser.user_id
                    onSuccess(addedUser.onboarding_status)

             
//                if addedUser.message.contains("added") {
//                    success = true
//                    onSuccess()
//                } else {
//
//                }
            case .failure(let failure):
                print("Failure: \(failure) <-> \(failure.localizedDescription)")
                success = false
            }
        }
}

struct RegisterUser_Previews: PreviewProvider {
    static var previews: some View {
        RegisterUser()
    }
}

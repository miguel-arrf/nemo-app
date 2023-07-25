//
//  PlanListView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 21/07/2023.
//

import SwiftUI

struct LastAutomaticPlan: Identifiable, Equatable, Codable {
    var plan: PlanInnerModel?
    var hour: Date?
    var id: UUID = .init()
    var forUserID: String
}

struct PlanListView: View {
    @State var automaticPlan: LastAutomaticPlan
    @State var creatingPlan: Bool = false
    @State var savedPlans: [PlanInnerModel] = []
    
    init() {
        
        /// Handles savedPlans
        if let data = UserDefaults.standard.data(forKey: "savedPlans") {
            do {
                let savedPlans = try JSONDecoder().decode([PlanInnerModel].self, from: data)
                self._savedPlans = .init(initialValue: savedPlans)
            } catch {
                print("There was an error decoding the savedPlans")
                self._savedPlans = .init(initialValue: .init())
            }
        } else {
            print("There was an error getting savedPlans from UserDefaults")
            self._savedPlans = .init(initialValue: .init())
        }
        
        /// Handls lastAutomaticPlan
        if let data = UserDefaults.standard.data(forKey: "lastAutomaticPlan") {
            do {
                let savedTasks = try JSONDecoder().decode(LastAutomaticPlan.self, from: data)
                
                if savedTasks.forUserID != User.shared.id {
                    print("The saved plan was for a different User, we will reinit it!")
                    self._automaticPlan = .init(initialValue: .init(forUserID: User.shared.id))
                    savePlans()
                } else {
                    self._automaticPlan = .init(initialValue: savedTasks)
                }
            } catch {
                print("There was an error decoding the lastAutomaticPlan")
                self._automaticPlan = .init(initialValue: .init(forUserID: User.shared.id))
            }
        } else {
            print("There was an error getting the lastAutomaticPlan from UserDefaults")
            self._automaticPlan = .init(initialValue: .init(forUserID: User.shared.id))
        }
    }
    
    
    func saveLastAutomaticPlan() {
        do {
            let data = try JSONEncoder().encode(automaticPlan)
            UserDefaults.standard.set(data, forKey: "lastAutomaticPlan")
        } catch {
            print("Unable to save lastAutomaticPlan in UserDefaults")
        }
    }
    
    func savePlans() {
        do {
            let data = try JSONEncoder().encode(savedPlans)
            UserDefaults.standard.set(data, forKey: "savedPlans")
        } catch {
            print("Unable to save savedPlans in UserDefaults")
        }
    }
    
    
    var body: some View {
    
            ZStack {
                Color(red: 0.96, green: 0.96, blue: 0.96)
                    .ignoresSafeArea()
                
                ScrollView(.vertical){
                    VStack(alignment: .leading, spacing: 14) {
                        //                    Text("Plan Builder")
                        //                        .fontWeight(.bold)
                        //                        .font(.system(size: 24))
                        //                      .foregroundColor(Color(red: 0.04, green: 0.04, blue: 0.04))
                        //                      .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack {
                            if let plan = automaticPlan.plan {
                                
                                VStack {
                                    Text("Custom plan")
                                        .bold()
                                        .font(.title3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    PlanCardView(plan: plan)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .transition(.scale.combined(with: .opacity).combined(with: .offset(y: 40)))
                                
                            }
                        }
                        .animation(.spring(), value: automaticPlan.plan)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        if !savedPlans.isEmpty {
                            Divider()
                            
                            Text("Created plans")
                                .bold()
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        ForEach(savedPlans, id: \.self) { plan in
                            PlanCardView(plan: plan)
                        }
                        
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 140)
                        
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
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
            .animation(.spring(), value: automaticPlan)
            .navigationTitle("Plans")
            .overlay(alignment: .bottom, content: {
                HStack(spacing: 0) {
                    
                    Spacer()
                    
                    Button(action: {
                        creatingPlan = true
                    }, label: {
                        Text("Create new Plan \(Image(systemName: "plus"))")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    })
                    
                    Spacer()
                    
                }
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                .frame(width: 330, height: 56)
                .background(.black)
                .cornerRadius(13)
                .offset(y: -30)
            })
 
        .onAppear {
            Task {
                if let _ = automaticPlan.plan, let date = automaticPlan.hour {
                    // If we have a plan, we might not need to update it.
                    
                    // If more than 20 minutes have passed, then let's update it:
                    
                    let currentDate = Date()
                    let calendar = Calendar.current
                    
                    let components = calendar.dateComponents([.minute], from: date, to: currentDate)
                    
                    if let minutes = components.minute, minutes >= 30 {
                        print("More than 30 minutes have passed")
                        await getAutomaticPlan()
                    } else {
                        print("Less than 30 minutes have passed, we won't update the automaticPlan")
                    }
                    
                    
                } else {
                    await getAutomaticPlan()
                }
            }
        }
        .sheet(isPresented: $creatingPlan, content: {
            PlanBuilderView { planChatModel in
                if let planChatModel = planChatModel {
                    let plan = planChatModel.planPreview
                    let innerPlanModel: PlanInnerModel = .init(planName: plan.planName, exercisedNames: plan.exercisesNames, estimatedDuration: plan.estimatedDuration, description: plan.description, id: .init())
                    savedPlans.append(innerPlanModel)
                    savePlans()
                    
                    Task {
                        await savePlansInDB(plan: innerPlanModel)
                    }
                    
                }
                
                creatingPlan = false
            }
        })
        
    }
    
    func savePlansInDB(plan: PlanInnerModel) async {
        let network: Networking = await .init()
        let result: Result<AddPlansModel, NetworkingError> = await network.performRequest(endpoint: API.addPlan(addPlansSchema: .init(plans: plan, user_id: User.shared.id)))
        
        switch result {
        case .success(let success):
            print("success adding plan in DB")
        case .failure(let failure):
            print("failure adding plan in DB: \(failure)")
        }
    }
    
    func getAutomaticPlan() async {
        let network: Networking = await .init()
        let result: Result<PlanModels, NetworkingError> = await network.performRequest(endpoint: API.getGeneratedPlan(user_id: User.shared.id))
        print("Result is: \(result)")
        switch result {
        case .success(let generatedPlan):
            print("success: \(generatedPlan)")
            withAnimation {
                if !generatedPlan.plans.isEmpty {
                    automaticPlan = .init(plan: generatedPlan.plans[0], hour: .now, forUserID: User.shared.id)
                    saveLastAutomaticPlan()
                }
            }
        case .failure(let failure):
            print("Failure: \(failure) <-> \(failure.localizedDescription)")
        }
    }
    //
    
    
}

struct PlanListView_Previews: PreviewProvider {
    static var previews: some View {
        PlanListView()
    }
}

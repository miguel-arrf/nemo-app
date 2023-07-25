//
//  PlanExecutorView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 21/07/2023.
//

import SwiftUI
import AVFoundation
import Combine
import Speech
import AVFAudio

class TextToSpeechManager: NSObject, AVSpeechSynthesizerDelegate {
    
    private let synthesizer = AVSpeechSynthesizer()
    var completions: [AVSpeechUtterance: () -> Void] = .init()
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(string: String, completion: @escaping () -> Void) {
        let utterance = AVSpeechUtterance(string: string)
        // Use English language
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.7 // Set rate to maximum for super fast speech
        completions[utterance] = completion
        synthesizer.speak(utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("completions: \(completions)")
        var toRemove: [AVSpeechUtterance] = .init()
        for completion in completions.filter({$0.key == utterance}) {
            completion.value()
            toRemove.append(completion.key)
        }
        
        toRemove.forEach({ speechUtterance in
            completions.removeValue(forKey: speechUtterance)
        })
    }
}

class AudioInputMonitor: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    let objectWillChange = PassthroughSubject<Void, Never>()
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))!
    private var timer = Timer()
    
    @Published var lastRecognizedText: String = ""
    @Published var isSpeaking: Bool = false {
        didSet { objectWillChange.send() }
    }
    
    override init() {
        super.init()
        speechRecognizer.delegate = self
    }
    
    func startMonitoring() {
        // check if audioEngine is already running
          if audioEngine.isRunning {
            print("Engine is already running")
            return
          }
        
        isSpeaking = true
        let request = SFSpeechAudioBufferRecognitionRequest()
        
        recognitionTask = speechRecognizer.recognitionTask(with: request) { [unowned self] (result, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)");
                startMonitoring()
                return }
            if let result = result {
                isSpeaking = true
                let bestString = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.lastRecognizedText = bestString
                    self.objectWillChange.send()
                    print("text: \(self.lastRecognizedText)")
                }
                self.restartTimer()
            }
            if result?.isFinal ?? false {
                print("-1here")
                self.stopMonitoring()
                self.startMonitoring()
            }
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        print("installing node in audio engine!")
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        do { try audioEngine.start() }
        catch { print("There was a problem starting the audio engine.") }
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            self?.isSpeaking = false
            
            print("no longer speaking")
        }
        
    }
    
    func stopMonitoring() {
        print("stoping")
        timer.invalidate()
        isSpeaking = false
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        print("removing node in audio engine")
    }
    
    func restartTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            self?.isSpeaking = false
        }
    }
}


struct RoleChat {
    var role: String
    var text: String
}

struct PlanExecutorView: View {
    @Environment(\.dismiss) var dismiss

    var textToSpeechManager: TextToSpeechManager = .init()
    @ObservedObject var speechToTextManager: AudioInputMonitor = .init()
    var plan: PlanModel
    
    @State private var showingTextfield: Bool = false
    @State private var chats: [RoleChat] = .init()
    @State private var message: String = ""
    
    @State var isFirstRequest: Bool = false
    @State private var isExecutionFinished: Bool = false
    
    @State private var instructionMessage: String?
    
    var body: some View {
        ZStack {
            Color(red: 0.33, green: 0.73, blue: 0.37)
                .saturation(speechToTextManager.isSpeaking ? 1 : 0)
                .animation(.spring(), value: speechToTextManager.isSpeaking)
                .ignoresSafeArea()
        }
        .overlay(alignment: .top, content: {
            VStack(alignment: .leading, content:  {
                
                Text("text: \(speechToTextManager.lastRecognizedText)")
                
                Text("Executing")
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                
                Text(plan.plan.planName)
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let instructionMessage = instructionMessage {
                    Text(instructionMessage)
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white.opacity(0.2)))
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
                
            })
            .animation(.spring(), value: instructionMessage)
            .padding(.horizontal, 40)
            .padding(.top, 40)
          
        })
        
        .overlay(alignment: .bottom, content: {
            /// Navigation bottom buttons
            VStack(spacing: 20){
                
                Spacer()
                
                HStack {
                    if showingTextfield {
                        TextField("Message", text: $message, prompt: Text("Message").foregroundColor(.white.opacity(0.5)))
                            .padding()
                            .background(Color.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 20))
                            .textFieldStyle(OnboardingChatViewStyle())
                            .transition(.scale.combined(with: .opacity).combined(with: .offset(y: 40)))
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    if isExecutionFinished {
                        Button(action: {
                            self.dismiss()
                        }, label: {
                            Text("Finish")
                                .foregroundColor(.white.opacity(0.5))
                        })
                        .padding()
                        .background(Color.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 20))
                        .textFieldStyle(OnboardingChatViewStyle())
                        .transition(.scale.combined(with: .opacity).combined(with: .offset(y: 40)))
                        .padding(.horizontal, 40)
                    }
                }
                
            
                HStack {
                    
                    /// Textfield button
                    Button(action: {
                        withAnimation(.spring()) {
                            showingTextfield.toggle()
                        }
                    }, label: {
                        Label("", systemImage: "message.fill")
                            .font(.title2)
                            .labelsHidden()
                            .labelStyle(.iconOnly)
                            .frame(width: 60, height: 60)
                            .background(Circle().foregroundColor(.white.opacity(0.2)))
                    })
                    .tint(.white)
                    
                    Spacer()
                    
                    /// Listening Ifno
                    if speechToTextManager.isSpeaking {
                        Label("", systemImage: "waveform")
                            .font(.title2)
                            .labelsHidden()
                            .labelStyle(.iconOnly)
                            .frame(width: 60, height: 60)
                            .background(Circle().foregroundColor(.white.opacity(0.2)))
                            .foregroundColor(.white)
                            .transition(.scale)
                    }
                    
                    
                    Spacer()
                    
                    /// Go to next step button
                    Button(action: {}, label: {
                        Label("", systemImage: "chevron.right")
                            .font(.title2)
                            .labelsHidden()
                            .labelStyle(.iconOnly)
                            .frame(width: 60, height: 60)

                            .background(Circle().foregroundColor(.white.opacity(0.2)))
                    })
                    .tint(.white)
                
                }
                .animation(.spring(), value: speechToTextManager.isSpeaking)
                .animation(.spring(), value: showingTextfield)
                .padding(.horizontal, 40)
                
              
                
            }
            .animation(.spring(), value: showingTextfield)

        })
        .onChange(of: speechToTextManager.isSpeaking, perform: { isSpeaking in
            print("isSpeaking: \(isSpeaking)")
            if !isSpeaking {
                if !speechToTextManager.lastRecognizedText.isEmpty {
                    // The user was speaking, but now is not, let's send what he said to the  backend
                    print("isSpeaking changed and we are going to send the following message: \(speechToTextManager.lastRecognizedText)")
                    chats.append(.init(role: "user", text: speechToTextManager.lastRecognizedText))
                    speechToTextManager.lastRecognizedText.removeAll()
                    Task {
                        await requestNextStepForPlanExecution()
                    }
                }
               
            }
        })
        .onAppear {
            Task {
                await requestNextStepForPlanExecution()
            }
        }
        
    }
    
    func requestNextStepForPlanExecution() async {
        let network: Networking = .init()
        
        var pairs: [[String]] = .init()
        chats.forEach({ chat in
            pairs.append([chat.role, chat.text])
        })
        
        let result: Result<PlanExecutionModel, NetworkingError> = await network.performRequest(endpoint: API.planExecutor(planExecutorSchema: .init(user_id: User.shared.id, messages: pairs, userPlan: plan)))
        //print("Result is: \(result)")
        switch result {
        case .success(let planExecutionModel):
            print("result is success")
            self.instructionMessage = planExecutionModel.messageToReadToUser
            self.speechToTextManager.stopMonitoring()
            message.append(planExecutionModel.messageToReadToUser)
            
            textToSpeechManager.speak(string: planExecutionModel.messageToReadToUser, completion: { [self] in
                print("we've just read the message: \(planExecutionModel.messageToReadToUser) to the user, so we will now start monitoring!")
                if !self.isFirstRequest {
                    self.isFirstRequest = true
                }
                self.speechToTextManager.startMonitoring()
            })
            withAnimation {
                self.isExecutionFinished = planExecutionModel.isExecutionFinished
            }
        case .failure(let failure):
            print("Failure: \(failure) <-> \(failure.localizedDescription)")
        }
    }
    
}

//struct PlanExecutorView_Previews: PreviewProvider {
//    static var plan: PlanModel = .init(planName: "The Sea Turtle Plan", exercisesNames: ["Balance Exercises", "Squats", "Plank"], estimatedDuration: 40, description: "his plan focuses on improving balance, leg strength, and core stability", id: .init())
//
//    static var previews: some View {
//        PlanExecutorView(plan: plan)
//    }
//}

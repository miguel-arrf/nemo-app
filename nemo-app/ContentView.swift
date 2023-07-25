//
//  ContentView.swift
//  nemo-app
//
//  Created by Miguel Ferreira on 19/07/2023.
//

import SwiftUI

public extension UIFont {

    /// Returns a font object that is the same as the receiver but which has the specified weight and symbolic traits
    func with(weight: Weight, symbolicTraits: UIFontDescriptor.SymbolicTraits) -> UIFont {

        var mergedsymbolicTraits = fontDescriptor.symbolicTraits
        mergedsymbolicTraits.formUnion(symbolicTraits)

        var traits = fontDescriptor.fontAttributes[.traits] as? [String: Any] ?? [:]
        traits[kCTFontWeightTrait as String] = weight
        traits[kCTFontSymbolicTrait as String] = mergedsymbolicTraits.rawValue

        var fontAttributes: [UIFontDescriptor.AttributeName: Any] = [:]
        fontAttributes[.family] = familyName
        fontAttributes[.traits] = traits

        return UIFont(descriptor: UIFontDescriptor(fontAttributes: fontAttributes), size: pointSize)
    }
}

struct ContentView: View {
    @StateObject var overlayViewModel = OverlayViewModel()

    @State var selection = 0
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes =
               [.font: UIFont(descriptor:
                       UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
                .withDesign(.rounded)!, size: 30).with(weight: .black, symbolicTraits: .traitBold)]
    }

    var body: some View {
            TabView(selection: $selection) {
                
                NavigationStack {
                    HomeView()
                        .environmentObject(overlayViewModel)
                        .navigationTitle("Tips & Tricks")
                }
                .tabItem {
                    Label(title: {
                        Text("Home")
                    }, icon: {
                        Image("icons8-coral-30")
                            .renderingMode(.template)
                    })
                }
                .tag(0)
                
                NavigationStack {
                    PlanListView()
                }
                    .tabItem {
                        Label("Plans", systemImage: "figure.run.square.stack.fill")
                    }
                    .tag(1)
//                PlanExecutorView()
//                    .tabItem {
//                        Label("Train", systemImage: "figure.strengthtraining.functional")
//                    }
                
                ChatView()
                    .tabItem {
                        Label(title: {
                            Text("Chat")
                        }, icon: {
                            Image("icons8-shell-30")
                                .renderingMode(.template)
                        })
                    }
                    .tag(2)
                
                PersonaListView()
                    .tabItem {
                        Label("Persona", systemImage: "fish.fill")
                    }
                    .tag(3)
                
            }
        
        .modifier(CustomSheetModifier(isShowing: $overlayViewModel.showing, otherContent: {
            overlayViewModel.overlayView
        }, yOffset: 500, onClose: {
            print("closing here 1")
        }))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

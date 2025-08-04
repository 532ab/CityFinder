//Abhimanyu Chaddha
// achaddha@iu.edu
// Evan Lucas
// ewlucas@iu.edu
//  CityFinder
// June 20th, 2025
//  Created by Lucas, Evan Walker on 6/15/25.
//

import SwiftUI
import SceneKit



struct TriviaView: View {
    @StateObject private var cityFinder: CityFinderModel
    @State private var questionsList = [Quiz(question: "New York City is home to the country's largest zoo, which features more than 4,000 animals. What is the name of the zoo?", options: ["Central Park Zoo", "Bronx Zoo", "Prospect Park Zoo", "The Buffalo Zoo"], answer: "Bronx Zoo"),
                                        Quiz(question: "What building was called the 'eighth world wonder' when it was built in 1931?", options: ["Viacom Building", "Worldwide Plaza", "Empire State Building", "TimeWarner Building"], answer: "Empire State Building"),
                                        Quiz(question: "What famous statue was shipped from France in 350 pieces and assembled in New York?", options: ["Civic Fame", "Statue of Liberty", "Statue of Atlas", "Eiffel Tower"], answer: "Statue of Liberty"),
                                        Quiz(question: "What train station in Manhattan, built in 1913, often has art exhibits in a wing called Vanderbilt Hall?", options: ["Penn Station", "Harlem Station", "World Trade Center PATH Station", "Grand Central Station"], answer: "Grand Central Station"),
                                        Quiz(question: "What museum in Manhattan, which features 45 permanent exhibition halls, also publishes 10 magazine issues every year?", options: ["The Metropolitan Museum of Art", "Guggenheim Museum", "The Frick Collection", "American Museum of Natural History"], answer: "American Museum of Natural History")]
    
    init(cityFinderModel: CityFinderModel) {
        _cityFinder = .init(wrappedValue: cityFinderModel)
    }
    
    struct Quiz: Codable {
        var question: String
        var options: [String]
        var answer: String
    }
    
    struct BackgroundSceneView: UIViewRepresentable
    {
        func makeUIView(context: Context) -> SCNView
        {
            let sceneView = SCNView()
            let scene = SCNScene()
            for _ in 0..<500 {
                let dot = SCNSphere(radius: 0.05)
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.cyan
                dot.materials = [material]
                let node = SCNNode(geometry: dot)
                node.position = SCNVector3(
                    Float.random(in: -10...10),
                    Float.random(in: -10...10),
                    Float.random(in: -5...5)
                )
                scene.rootNode.addChildNode(node)
                let fadeOut = SCNAction.fadeOpacity(to: 0.2, duration: Double.random(in: 0.5...1))
                let fadeIn = SCNAction.fadeOpacity(to: 1.0, duration: Double.random(in: 0.5...1))
                node.runAction(.repeatForever(.sequence([fadeOut, fadeIn])))
            }
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(0, 0, 20)
            scene.rootNode.addChildNode(cameraNode)
            sceneView.scene = scene
            sceneView.backgroundColor = .black
            sceneView.allowsCameraControl = false
            sceneView.isUserInteractionEnabled = false
            return sceneView
        }
        func updateUIView(_ uiView: SCNView, context: Context) {}
    }
    var body: some View {
        
        ZStack(alignment: .topTrailing)
        {
            BackgroundSceneView()
                .ignoresSafeArea()
            VStack(spacing: 16) {
                
                Text("City Trivia!")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .bold()
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 103.0)
                
                if !cityFinder.triviaActive {
                    Text("There is no trivia for this city :(")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .bold()
                        .foregroundColor(.white.opacity(0.8))
                        .padding([.leading, .bottom, .trailing], 103.0)
                } else {
                    @State var city = cityFinder.cityTrivia[cityFinder.currentCity]
                    List {
                        ForEach(0...city.triviaList.count-1, id: \.self) { i in
                            Section(header: Text(city.triviaList[i].question)) {
                                Text(city.triviaList[i].answer)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TriviaView(cityFinderModel: CityFinderModel())
}

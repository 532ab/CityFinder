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

struct HistoryView: View
{
    @ObservedObject var cityFinder: CityFinderModel
    var searchHistory: [CityFinderModel.SearchHistory]
    {
            cityFinder.searchHistory
    }
        
    var dateIndexes: [Int]
    {
            cityFinder.getDateIndexes()
    }
    @Binding var selectedTab: Int
    
    init(cityFinderModel: CityFinderModel, selectedTab: Binding<Int>)
    {
        self.cityFinder = cityFinderModel
        self._selectedTab = selectedTab
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
    
    var body: some View
    {
            NavigationView
            {
                ZStack(alignment: .topTrailing)
                {
                    BackgroundSceneView()
                        .ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("Search History")
                        .font(.largeTitle).bold()
                        .foregroundColor(.blue.opacity(0.6))
                    
                    historyList
                        .listStyle(.plain)
                        .padding(.horizontal)
                }
                .onAppear {
                    cityFinder.updateHistory()
                }
            }
        }
    }
    
    private var historyList: some View {
        List {
            if dateIndexes.count > 1 {
                ForEach(1..<dateIndexes.count, id: \.self) { sectionIndex in
                    Section(header: Text(searchHistory[dateIndexes[sectionIndex - 1]].date, format: .dateTime.day().month().year())){
                        ForEach(dateIndexes[sectionIndex - 1]..<dateIndexes[sectionIndex], id: \.self) { index in
                            Button(action: {
                                cityFinder.selectedSearch = searchHistory[index].search
                                selectedTab = 0
                            }) {
                                Text(searchHistory[index].search)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            
            if let lastIndex = dateIndexes.last, lastIndex < searchHistory.count {
                Section(header: Text(searchHistory[lastIndex].date, format: .dateTime.day().month().year())) {
                    ForEach(lastIndex..<searchHistory.count, id: \.self) { index in
                        Button(action:
                        {
                            cityFinder.selectedSearch = searchHistory[index].search
                            selectedTab = 0
                        }) {
                            Text(searchHistory[index].search)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}


#Preview
{
    HistoryView(cityFinderModel: CityFinderModel(), selectedTab: .constant(1))
}

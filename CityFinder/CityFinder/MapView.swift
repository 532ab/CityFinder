//Abhimanyu Chaddha
// achaddha@iu.edu
// Evan Lucas
// ewlucas@iu.edu
//  CityFinder
// June 20th, 2025
//  Created by Lucas, Evan Walker on 6/15/25.
//

import SwiftUI
import MapKit
import CoreLocation
import SceneKit

struct CityAnnotation: Identifiable
{
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var shouldUpdateRegion = true
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.1653, longitude: -86.5264),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let loc = locations.last
        {
            DispatchQueue.main.async
            {
                if self.shouldUpdateRegion
                {
                    self.region.center = loc.coordinate
                }
                self.userLocation = loc
            }
        }
    }
}

struct BackgroundSceneView: UIViewRepresentable
{
    func makeUIView(context: Context) -> SCNView
    {
        let sceneView = SCNView()
        let scene = SCNScene()
        for _ in 0..<300 {
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


struct MapView: View
{
    @StateObject private var locationManager = LocationManager()
    @StateObject private var cityFinder: CityFinderModel
    @State private var searchText = ""
    @State private var distance = 0
    @State private var annotations: [CityAnnotation] = []
    @State private var isSearchActive = false
    
    init(cityFinderModel: CityFinderModel, _ searchText: String = "")
    {
        _cityFinder = .init(wrappedValue: cityFinderModel)
        _searchText = State(initialValue: searchText)
    }
    
    var body: some View
    {
        ZStack(alignment: .topTrailing)
        {
            BackgroundSceneView()
                .ignoresSafeArea()
            
            ScrollView
            {
                VStack(spacing: 16) {
                    Text("CityFinder")
                        .font(.largeTitle).bold()
                        .foregroundColor(.blue.opacity(0.6))
                    HStack {
                        TextField("Search for a city", text: $searchText)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        
                        Button {
                            runSearch()
                        }
                        label: {
                            Image(systemName: "magnifyingglass")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2)
                    
                    ZStack {
                        Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: annotations) {
                            MapMarker(coordinate: $0.coordinate)
                        }
                        .frame(height: 300)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Distance:")
                            .foregroundColor(.blue.opacity(0.6))
                        Spacer()
                        Text("\(distance) mi")
                            .foregroundColor(.blue.opacity(0.6))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear
        {
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            {
                runSearch()
            }
        }
        .onChange(of: cityFinder.selectedSearch)
        { newSearch in
            if let search = newSearch
            {
                searchText = search
                runSearch()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                {
                    cityFinder.selectedSearch = nil
                }
            }
        }

    }
    
    private func runSearch() {
        locationManager.shouldUpdateRegion = false
        
        cityFinder.findCity(searchText) { coordinate in
            DispatchQueue.main.async {
                if let coordinate {
                    annotations = [CityAnnotation(coordinate: coordinate)]
                    locationManager.region =
                    MKCoordinateRegion(
                        center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
                        )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 1.0))
                            {
                              locationManager.region = MKCoordinateRegion(
                                            center: coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            )
                                }
                            }
                    
                    if let userLocation = locationManager.userLocation {
                        let cityLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        let distanceInMeters = userLocation.distance(from: cityLocation)
                        let distanceInMiles = distanceInMeters / 1609.34
                        distance = Int(distanceInMiles)
                    } else {
                        distance = 0
                    }
                } else {
                    annotations.removeAll()
                    distance = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
                {
                    locationManager.shouldUpdateRegion = true
                }
            }
        }
    }


}
#Preview
{
    MapView(cityFinderModel: CityFinderModel())
}

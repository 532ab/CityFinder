//Abhimanyu Chaddha
// achaddha@iu.edu
// Evan Lucas
// ewlucas@iu.edu
//  CityFinder
// June 20th, 2025
//  Created by Abhimanyu Chaddha on 6/14/25.
//

import SwiftUI
import MapKit

struct ContentView: View
{
    @StateObject private var cityFinderModel = CityFinderModel()
    @State private var selectedTab = 0
    
    var body: some View
    {
            TabView(selection: $selectedTab)
        {
            MapView(cityFinderModel: cityFinderModel)
                            .tabItem {
                                Label("Map", systemImage: "map")
                            }
                            .tag(0)

                HistoryView(cityFinderModel: cityFinderModel, selectedTab: $selectedTab)
                    .tabItem
                   {
                        Label("History", systemImage: "list.dash")
                    }
                    .tag(1)

                TriviaView(cityFinderModel: cityFinderModel)
                    .tabItem {
                        Label("Trivia", systemImage: "gamecontroller")
                    }
                    .tag(2)
                    .badge(cityFinderModel.triviaActive ? "!" : nil)
            }
        }
}
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

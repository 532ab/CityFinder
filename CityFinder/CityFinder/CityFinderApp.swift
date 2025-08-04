//Abhimanyu Chaddha
// achaddha@iu.edu
// Evan Lucas
// ewlucas@iu.edu
//  CityFinder
// June 20th, 2025
//  Created by Abhimanyu Chaddha on 6/14/25.
//

import SwiftUI

@main
struct CityFinderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//Abhimanyu Chaddha
// achaddha@iu.edu
// Evan Lucas
// ewlucas@iu.edu
//  CityFinder
// June 20th, 2025 
//  Created by Abhimanyu Chaddha on 6/17/25.
//

import Foundation
import CoreLocation

class CityFinderModel: ObservableObject
{
    
    struct SearchHistory: Codable {
        let search: String
        let date: Date
    }
    
    struct Trivia: Codable {
        let question: String
        let answer: String
    }
    
    struct City: Codable {
        let name: String
        let triviaList: [Trivia]
    }
    
    var searchHistory: [SearchHistory]
    var triviaActive = false
    var currentCity = 0
    @Published var cityCoordinate: CLLocationCoordinate2D?
    @Published var selectedSearch: String? = nil
    var cityTrivia = [City(name: "New York", triviaList: [Trivia(question: "New York City is home to the country's largest zoo, which features more than 4,000 animals. What is the name of the zoo?", answer: "Bronx Zoo"),
                                            Trivia(question: "What building was called the 'eighth world wonder' when it was built in 1931?", answer: "Empire State Building"),
                                            Trivia(question: "What famous statue was shipped from France in 350 pieces and assembled in New York?", answer: "Statue of Liberty"),
                                            Trivia(question: "What train station in Manhattan, built in 1913, often has art exhibits in a wing called Vanderbilt Hall?", answer: "Grand Central Station"),
                                            Trivia(question: "What museum in Manhattan, which features 45 permanent exhibition halls, also publishes 10 magazine issues every year?", answer: "American Museum of Natural History")])]
        
    
    init() {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("history.plist")
            let data = try Data(contentsOf: fileURL)
            let updatedHistory = try PropertyListDecoder().decode([SearchHistory].self, from: data)
            self.searchHistory = updatedHistory
            print(updatedHistory)
        } catch {
            print(error)
            self.searchHistory = [SearchHistory(search: "", date: Date())]
        }
    }
    
    func checkCity(search: String) {
        triviaActive = false
        var i = 0
        for name in cityTrivia {
            if name.name == search {
                triviaActive = true
                currentCity = i
            }
            i += 1
        }
        
    }
    
    
    
    func updateHistory() {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("history.plist")
            let data = try Data(contentsOf: fileURL)
            let updatedHistory = try PropertyListDecoder().decode([SearchHistory].self, from: data)
            self.searchHistory = updatedHistory
        } catch {
            print(error)
        }
    }
    
    func getDateIndexes() -> [Int] {
        var i = 0
        var output = [0]
        print("search history count: " + String(searchHistory.count))
        for search in 1...searchHistory.count-1 {
            if !Calendar.current.isDate(searchHistory[i].date, inSameDayAs: searchHistory[search].date) {
                output.append(search)
            }
            i += 1
        }
        return output
    }
    func addSearch(_ search: String)
    {
        guard !search.isEmpty else { return }
        let newEntry = SearchHistory(search: search, date: Date())
        searchHistory.append(newEntry)
        updateHistory()
    }
    
    func findCity(_ search: String, completion: @escaping (CLLocationCoordinate2D?) -> Void)
    {
        checkCity(search: search)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(search) { placemarks, error in
            DispatchQueue.main.async {
                if let coordinate = placemarks?.first?.location?.coordinate, error == nil
                {
                    self.cityCoordinate = coordinate
                    completion(coordinate)

                    if self.searchHistory.last?.search != search
                    {
                        let newSearch = SearchHistory(search: search, date: Date())
                        self.searchHistory.append(newSearch)

                        do {
                            let fileURL = try FileManager.default
                                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                                .appendingPathComponent("history.plist")
                            let data = try PropertyListEncoder().encode(self.searchHistory)
                            try data.write(to: fileURL)
                        } catch {
                            print(error)
                        }
                    }

                } else {
                    completion(nil)
                }
            }
        }
    }
}

//
//  Uala_Challange_iOSTests.swift
//  Uala-Challange-iOSTests
//
//  Created by Jeremias on 29/12/2024.
//

import Foundation
import XCTest
import Combine
@testable import Uala_Challange_iOS

@MainActor
final class PerformanceTests: XCTestCase {
    
    var sut: Filter!
    
    let citiesMock: [City] = [City.dummy(name: "Okinawa"),
                              City.dummy(name: "London"),
                              City.dummy(name: "Buenos Aires"),
                              City.dummy(name: "Guadalajara"),
                              City.dummy(name: "Paris"),
                              City.dummy(name: "Lona-Cases"),
                              City.dummy(name: "Long Lake"),
                              City.dummy(name: "Lontzen"),
                              City.dummy(name: "Little River"),
                              City.dummy(name: "Lizzard River"),
                              City.dummy(name: "Luabo Ceppino"),
                              City.dummy(name: "Łódź"),
                              City.dummy(name: "O Barco de Vadeorras"),
                              City.dummy(name: "O'Connel"),
                              City.dummy(country: "JP", name:"OI"),
                              City.dummy(name: "Opaheke"),
                              City.dummy(country: "TR", name:"Oyali")]
    
    override func setUp() {
        super.setUp()
        sut = Filter()
        sut.setupInitialData(citiesMock)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_filtering_performance() {
        
        func generateRandomName(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map { _ in letters.randomElement() ?? "a" })
        }

        //Since isn't viable to keep around 5,10,or20mb of data to emulate the input for the filter
        //lets create by code a similar amount of pseudo-random data.
        
        ///Mockup data
        var cities = [City]()
        for _ in 0..<500000 {
            if Int.random(in: 0...10) == 3 {
                cities.append(City.dummy(name: "lond"+generateRandomName(length: 3)))
            }
            cities.append(City.dummy(name: generateRandomName(length: 7)))
        }
        sut.setupInitialData(cities)
        
        
        ///Expected data
        let expectedCities = cities.removeDuplicates().sortedByNameAndCountry()
        let expectedCitiesDcit = ["l": expectedCities.filter { $0.name.lowercased().hasPrefix("l") },
                          "lo": expectedCities.filter { $0.name.lowercased().hasPrefix("lo") },
                          "lon": expectedCities.filter { $0.name.lowercased().hasPrefix("lon") },
                          "lond": expectedCities.filter { $0.name.lowercased().hasPrefix("lond") },
                          "b": expectedCities.filter { $0.name.lowercased().hasPrefix("b") },
                          "j": expectedCities.filter { $0.name.lowercased().hasPrefix("j") }
        ]

        measure {
            _ = searchWithPrefix(expectationString: #function,
                             prefixExpectedResults: expectedCitiesDcit )
            { prefix, cities in
                XCTAssertEqual(cities.count, expectedCitiesDcit[prefix]?.count)
            }
        }
    }
    
    func test_filter_updates_correctly() {
        //Results cases
        let l: [City] = [City.dummy(name: "Little River"),
                         City.dummy(name: "Lizzard River"),
                         City.dummy(name: "Lona-Cases"),
                         City.dummy(name: "London"),
                         City.dummy(name: "Long Lake"),
                         City.dummy(name: "Lontzen"),
                         City.dummy(name: "Luabo Ceppino")]
        
        let lon: [City] = [City.dummy(name: "Lona-Cases"),
                           City.dummy(name: "London"),
                           City.dummy(name: "Long Lake"),
                           City.dummy(name: "Lontzen")]
        
        let o: [City] = [City.dummy(name: "O Barco de Vadeorras"),
                         City.dummy(name: "O'Connel"),
                         City.dummy(country: "JP", name:"OI"),
                         City.dummy(name: "Okinawa"),
                         City.dummy(name: "Opaheke"),
                         City.dummy(country: "TR", name:"Oyali"),]
        
        let oSpace: [City] = [City.dummy(name: "O Barco de Vadeorras")]
        
        let Ł: [City] = [City.dummy(name: "Łódź")]
        
        let validInputResults: [String: [City]] = [""   : citiesMock.sortedByNameAndCountry(),
                                                   "L"  : l,
                                                   "Lon": lon,
                                                   "O"  : o,
                                                   "o " : oSpace,
                                                   "Ł"  : Ł]
        
        let expectation = searchWithPrefix(expectationString: #function,
                                           prefixExpectedResults: validInputResults)
        { text , cities in
            XCTAssertEqual(validInputResults[text], cities)
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_filter_invalid_input_correct_output() {
        
        let invalidInputResults: [String: [City]] = ["zzKZZKKK": [],
                                                     "$1" : [],
                                                     " "  : [],
                                                     "🚓" : []]
        
        let expectation = searchWithPrefix(expectationString: #function,
                                           prefixExpectedResults: invalidInputResults)
        { text , cities in
            XCTAssertEqual(invalidInputResults[text], cities)
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_filter_invalid_input_invalid_output() {
        
        let invalidInputResults: [String: [City]] = ["zzKZZKKK": citiesMock,
                                                     "$1" : [City.dummy(), City.dummy()],
                                                     " "  : [City.dummy()],
                                                     "🚓" : [City.dummy(country:"🚓", name:"🚓")]]
        
        let expectation = searchWithPrefix(expectationString: #function,
                                           prefixExpectedResults: invalidInputResults)
        { text , cities in
            XCTAssertNotEqual(invalidInputResults[text], cities)
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_filter_results_has_prefix() {
        
        let prefixExpectedResults = ["": citiesMock.sortedByNameAndCountry()]
        
        let expectation = searchWithPrefix(expectationString: #function,
                                           prefixExpectedResults: prefixExpectedResults)
        { prefix, cities in
            XCTAssert(cities.allSatisfy {
                $0.name.lowercased().hasPrefix(prefix.lowercased())
            })
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_filter_results_are_sorted()  {
        
        let prefixExpectedResults = ["": citiesMock]
        
        let expectation = searchWithPrefix(expectationString: #function,
                                           prefixExpectedResults: prefixExpectedResults)
        { prefix, cities in
            XCTAssertEqual(cities, self.citiesMock.sortedByNameAndCountry())
        }
        wait(for: [expectation], timeout: 20.0)
    }

    
    func searchWithPrefix(expectationString: String,
                          prefixExpectedResults: [String: [City]],
                          closure: ((String, [City]) -> Void)? = nil) -> XCTestExpectation {

        let expectation = XCTestExpectation(description: expectationString)
        let expectedEmissions = prefixExpectedResults.keys.count
        var emissionsCount = 0
        var currentText = ""

        var cancellables = Set<AnyCancellable>()
        
        sut.filteredCities
            .dropFirst()
            .sink { cities in
                if emissionsCount > expectedEmissions {
                    return
                }
                closure?(currentText, cities)
                
                emissionsCount += 1
               
                //Once all the values were traversed correctly, fulfill the expectation
                if emissionsCount == expectedEmissions {
                    expectation.fulfill()
                }
            }.store(in: &cancellables)
        
        prefixExpectedResults.keys.forEach {
            currentText = $0
            sut.searchText = $0
        }
        
        return expectation
    }
}

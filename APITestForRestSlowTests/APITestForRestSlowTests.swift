//
//  APITestForRestSlowTests.swift
//  APITestForRestSlowTests
//
//  Created by yeoh on 21/09/2022.
//

import XCTest
@testable import APITestForRest

class APITestForRestSlowTests: XCTestCase {
    
    var sut: URLSession!
    
    override func setUpWithError() throws {
        sut = URLSession(configuration: .default)
        
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMaskAPIStatusCode() {
        let url = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json")
        let promise = expectation(description: "Status code: 200")
        
        sut.dataTask(with: url!) { data, response, error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            }
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("status code: \(statusCode)")
                }
            }
        }.resume()
        wait(for: [promise], timeout: 5)
    }
    
    func testMaskAPICompletes() {
        let url = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json")
        let promise = expectation(description: "Completion handler invoked")
        var responseError: Error?
        var statusCode: Int?
        
        sut.dataTask(with: url!) { data, response, error in
            responseError = error
            statusCode = (response as? HTTPURLResponse)?.statusCode
            promise.fulfill()
        }.resume()
        wait(for: [promise], timeout: 5)
        
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }

}

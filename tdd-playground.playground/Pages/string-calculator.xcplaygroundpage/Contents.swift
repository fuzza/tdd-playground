//: [Previous](@previous)

import XCTest
import Foundation
import UIKit

enum StringCalculatorError: Error {
  case negativeInput
  case invalidInput
}

class StringCalculator  {
  var delimeters: Set<Character> = [",", "\n"]
  
  func add(_ numbers: String) throws -> Int {
    var value = numbers
    
    if numbers.isEmpty {
      return 0
    }
    
    if(value.hasPrefix("//")) {
      let delimeterIndex = numbers.index(numbers.startIndex, offsetBy: 2)
      let delimeter = numbers[delimeterIndex]
      delimeters.insert(delimeter)
      
      let prefixEnd = value.characters.index(of: "\n")!
      let valueStart = value.index(prefixEnd, offsetBy: 1)
      value = value.substring(with: valueStart..<value.endIndex)
    }
    
    return try parseNumbers(value, delimeter: delimeters)
  }
  
  fileprivate func parseNumbers(_ numbers: String, delimeter: Set<Character>) throws -> Int {
    return try numbers.characters
      .split { delimeters.contains($0) }
      .map(String.init)
      .map(mapNumber)
      .reduce(0, +)
  }
  
  private func mapNumber(_ number: String) throws -> Int {
    guard let parsed = Int(number) else {
      throw StringCalculatorError.invalidInput
    }
    guard parsed > 0 else {
      throw StringCalculatorError.negativeInput
    }
    return parsed
  }
}

class StringClaculatorTest: XCTestCase {
  var calculator: StringCalculator!
  
  override func setUp() {
    super.setUp()
    calculator = StringCalculator()
  }

  func test_add_emptyString_returnsDefault() {
    XCTAssertEqual(0, try! calculator.add(""))
  }
  
  func test_add_numbers_returnsSum() {
    XCTAssertEqual(1, try! calculator.add("1"))
    XCTAssertEqual(2, try! calculator.add("2"))
    XCTAssertEqual(3, try! calculator.add("1,2"))
    XCTAssertEqual(4, try! calculator.add("1,3"))
    XCTAssertEqual(15, try! calculator.add("1,2,3,4,5"))
  }
  
  func test_add_newlineAsDelimeter_returnsSum() {
    XCTAssertEqual(3, try! calculator.add("1\n2"))
  }
  
  func test_add_combinedDelimeters_returnsSum() {
    XCTAssertEqual(6, try! calculator.add("1\n2,3"))
  }
  
  func test_add_customDelimeter_returnsSum() {
    XCTAssertEqual(3, try! calculator.add("//;\n1;2"))
    XCTAssertEqual(10, try! calculator.add("//;\n1;2,3\n4"))
  }
  
  func test_add_lessThanZero_throws() {
    XCTAssertThrowsError(try calculator.add("-1")) { e in
      XCTAssertEqual(e as? StringCalculatorError, .negativeInput)
    }
  }
  
  func test_add_nonParsableInput_throws() {
    XCTAssertThrowsError(try calculator.add("a")) { e in
      XCTAssertEqual(e as? StringCalculatorError, .invalidInput)
    }
  }
}

StringClaculatorTest.defaultTestSuite().run()


//: [Next](@next)

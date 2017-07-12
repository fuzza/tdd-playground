//: Playground - noun: a place where people can play

import XCTest
import Foundation
import UIKit

// MARK: Money

class Money {
  fileprivate let amount: Int
  let currency: String
  
  init(_ amount: Int, currency: String) {
    self.amount = amount
    self.currency = currency
  }
  
  func times(_ multiplier: Int) -> Money {
    fatalError("Override in subclass")
  }
  
  static func dollar(_ amount: Int) -> Money {
    return Dollar(amount, currency: "USD")
  }
  
  static func franc(_ amount: Int) -> Money {
    return Franc(amount, currency: "CHF")
  }
}

extension Money: Equatable {
  static func == (lhs: Money, rhs: Money) -> Bool {
    return lhs.amount == rhs.amount
    && type(of: lhs) == type(of: rhs)
  }
}

extension Money: CustomDebugStringConvertible {
  var debugDescription: String {
    return "\(amount) " + currency
  }
}


// MARK: Dollar

class Dollar: Money {
  override func times(_ multiplier: Int) -> Money {
    return Dollar(amount * multiplier, currency: currency)
  }
}

// MARK: Franc

class Franc: Money {
  override func times(_ multiplier: Int) -> Money {
    return Franc(amount * multiplier, currency: currency)
  }
}

// MARK: Tests

class CurrencyTest: XCTestCase {
  func testMultiplication() {
    let five: Money = Money.dollar(5)
  
    XCTAssertEqual(five.times(2), Money.dollar(10))
    XCTAssertEqual(five.times(3), Money.dollar(15))
  }
  
  func testEquality() {
    XCTAssertEqual(Money.dollar(5), Money.dollar(5))
    XCTAssertNotEqual(Money.dollar(5), Money.dollar(6))
    XCTAssertEqual(Money.franc(5), Money.franc(5))
    XCTAssertNotEqual(Money.franc(5), Money.franc(6))
    XCTAssertNotEqual(Money.dollar(5), Money.franc(5))
    XCTAssertNotEqual(Money.dollar(5), Money.franc(6))
  }
  
  func testFrancMultiplication() {
    let five = Money.franc(5)
    XCTAssertEqual(five.times(2), Money.franc(10))
    XCTAssertEqual(five.times(3), Money.franc(15))
  }
  
  func testCurrency() {
    XCTAssertEqual("USD", Money.dollar(1).currency)
    XCTAssertEqual("CHF", Money.franc(1).currency)
  }
  
  func testDifferentClassesEquality() {
    
  }
}

CurrencyTest.defaultTestSuite().run()
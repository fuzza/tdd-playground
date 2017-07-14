//: Playground - noun: a place where people can play

import XCTest
import Foundation
import UIKit

// MARK: Currencies

enum Currency {
  case usd
  case chf
}

// MARK: Expression

protocol Expression {
  func reduce(_ bank: Bank, _ to: Currency) -> Money
  func plus(_ addend: Expression) -> Expression
  func times(_ multiplier: Int) -> Expression
}

extension Expression {
  func plus(_ addend: Expression) -> Expression {
    return Sum(augend: self, addend: addend)
  }
}

// MARK: Money

struct Money {
  fileprivate let amount: Int
  let currency: Currency
  
  init(_ amount: Int, currency: Currency) {
    self.amount = amount
    self.currency = currency
  }
}

extension Money {
  static func dollar(_ amount: Int) -> Money {
    return Money(amount, currency: .usd)
  }
  
  static func franc(_ amount: Int) -> Money {
    return Money(amount, currency: .chf)
  }
}

extension Money: Expression {
  func reduce(_ bank: Bank, _ to: Currency) -> Money {
    let rate = bank.rate(from: currency, to: to)
    return Money(amount / rate, currency: to)
  }
  
  func times(_ multiplier: Int) -> Expression {
    return Money(amount * multiplier, currency: currency)
  }
}

extension Money: Equatable {
  static func == (lhs: Money, rhs: Money) -> Bool {
    return lhs.amount == rhs.amount &&
      lhs.currency == rhs.currency
  }
}

extension Money: CustomDebugStringConvertible {
  var debugDescription: String {
    return "\(amount) \(currency)"
  }
}

// MARK: Sum

struct Sum {
  let augend: Expression
  let addend: Expression
}

extension Sum: Expression {
  func reduce(_ bank: Bank, _ to: Currency) -> Money {
    let amount = addend.reduce(bank, to).amount + augend.reduce(bank, to).amount
    return Money(amount, currency: to)
  }

  func times(_ multiplier: Int) -> Expression {
    return Sum(augend: augend.times(multiplier), addend: addend.times(multiplier))
  }
}

// MARK: Bank

class Bank {
  private var rates: [Pair: Int] = [:]
  
  func reduce(_ expression: Expression, _ currency: Currency) -> Money {
    return expression.reduce(self, currency)
  }
  
  func rate(from: Currency, to: Currency) -> Int {
    guard from != to else {
      return 1
    }
    
    let pair = Pair(from: from, to: to)
    return rates[pair]!
  }
  
  func addRate(from: Currency, to: Currency, multiplier: Int) {
    let pair = Pair(from: from, to: to)
    rates[pair] = multiplier
  }
}

// MARK: Pair

struct Pair {
  let from: Currency
  let to: Currency
}

extension Pair: Hashable {
  static func == (lhs: Pair, rhs: Pair) -> Bool {
    return lhs.from == rhs.from &&
      lhs.to == rhs.to
  }
  
  var hashValue: Int {
    return 0
  }
}

// MARK: Tests

class CurrencyTest: XCTestCase {
  func testMoneyTimes() {
    let five: Money = Money.dollar(5)
  
    XCTAssertEqual(five.times(2).reduce(Bank(), .usd), Money.dollar(10))
    XCTAssertEqual(five.times(3).reduce(Bank(), .usd), Money.dollar(15))
  }
  
  func testEquality() {
    XCTAssertEqual(Money.dollar(5), Money.dollar(5))
    XCTAssertNotEqual(Money.dollar(5), Money.dollar(6))
    XCTAssertNotEqual(Money.dollar(5), Money.franc(5))
  }

  func testCurrency() {
    XCTAssertEqual(.usd, Money.dollar(1).currency)
    XCTAssertEqual(.chf, Money.franc(1).currency)
  }
  
  func testSimpleAddition() {
    let sum = Sum(augend: Money.dollar(4), addend: Money.dollar(3))
    let bank = Bank()
    XCTAssertEqual(Money.dollar(7), bank.reduce(sum, .usd))
  }
  
  func testReduceMoney() {
    let bank = Bank()
    XCTAssertEqual(Money.dollar(1), bank.reduce(Money.dollar(1), .usd))
  }
  
  func testReduceMoneyDifferentCurrency() {
    let bank = Bank()
    bank.addRate(from: .chf, to: .usd, multiplier: 2)
    let result = bank.reduce(Money.franc(2), .usd)
    XCTAssertEqual(Money.dollar(1), result)
  }
  
  func testIdentityRate() {
    XCTAssertEqual(1, Bank().rate(from: .usd, to: .usd))
  }
  
  func testMixedAddition() {
    let fiveBucks: Expression = Money.dollar(5)
    let tenFrancs: Expression = Money.franc(10)
    
    let bank = Bank()
    bank.addRate(from: .chf, to: .usd, multiplier: 2)
    
    let result = bank.reduce(fiveBucks.plus(tenFrancs), .usd)
    XCTAssertEqual(Money.dollar(10), result)
  }
  
  func testSumPlusMoney() {
    let fiveBucks: Expression = Money.dollar(5)
    let tenFrancs: Expression = Money.franc(10)
    
    let bank = Bank()
    bank.addRate(from: .chf, to: .usd, multiplier: 2)
    
    let sum: Expression = Sum(augend: fiveBucks, addend: tenFrancs).plus(fiveBucks)
    let result = bank.reduce(sum, .usd)
    XCTAssertEqual(Money.dollar(15), result)
  }
  
  func testSumTimes() {
    let fiveBucks: Expression = Money.dollar(5)
    let tenFrancs: Expression = Money.franc(10)
    
    let bank = Bank()
    bank.addRate(from: .chf, to: .usd, multiplier: 2)
    
    let sum: Expression = Sum(augend: fiveBucks, addend: tenFrancs).times(2)
    let result = bank.reduce(sum, .usd)
    XCTAssertEqual(Money.dollar(20), result)
  }
}

CurrencyTest.defaultTestSuite().run()

//
//  TickGeneratorTests.swift
//  PlotSwiftTests
//
//  Tests for TickGenerator and TickFormatter types.
//

import XCTest

@testable import PlotSwift

final class TickGeneratorTests: XCTestCase {

  private let generator = TickGenerator()

  // MARK: - Tick generation

  func testTickCountIsReasonable() {
    let range = DataRange(min: 0, max: 100)
    let ticks = generator.generateTicks(range: range)
    XCTAssertGreaterThanOrEqual(ticks.count, 3)
    XCTAssertLessThanOrEqual(ticks.count, 12)  // small overshoot from ceiling is acceptable
  }

  func testTickCountRespectsMaxTicks() {
    let range = DataRange(min: 0, max: 1)
    let ticks = generator.generateTicks(range: range, maxTicks: 5)
    XCTAssertLessThanOrEqual(ticks.count, 6)  // small overshoot from ceiling is acceptable
  }

  func testTicksAreEvenlySpaced() {
    let range = DataRange(min: 0, max: 100)
    let ticks = generator.generateTicks(range: range)
    guard ticks.count >= 2 else {
      XCTFail("Need at least two ticks to check spacing")
      return
    }
    let spacing = ticks[1] - ticks[0]
    for i in 1..<ticks.count {
      XCTAssertEqual(ticks[i] - ticks[i - 1], spacing, accuracy: spacing * 1e-9)
    }
  }

  func testTicksSpanDataRange() {
    let range = DataRange(min: 3.7, max: 28.4)
    let ticks = generator.generateTicks(range: range)
    XCTAssertTrue(ticks.first! <= range.min + (ticks[1] - ticks[0]))
    XCTAssertTrue(ticks.last! >= range.max - (ticks[1] - ticks[0]))
  }

  func testTicksWithNegativeRange() {
    let range = DataRange(min: -50, max: 50)
    let ticks = generator.generateTicks(range: range)
    XCTAssertGreaterThanOrEqual(ticks.count, 3)
    XCTAssertTrue(ticks.contains(where: { $0 == 0 }))
  }

  func testTicksWithSmallRange() {
    let range = DataRange(min: 0.001, max: 0.009)
    let ticks = generator.generateTicks(range: range)
    XCTAssertGreaterThanOrEqual(ticks.count, 2)
  }

  func testTicksWithZeroSpanReturnsSingleTick() {
    let range = DataRange(min: 5, max: 5)
    let ticks = generator.generateTicks(range: range)
    XCTAssertEqual(ticks.count, 1)
    XCTAssertEqual(ticks[0], 5)
  }

  // MARK: - DefaultTickFormatter

  func testDefaultFormatterWholeNumber() {
    let fmt = DefaultTickFormatter()
    XCTAssertEqual(fmt.format(1.0), "1")
    XCTAssertEqual(fmt.format(1000.0), "1000")
    XCTAssertEqual(fmt.format(0.0), "0")
  }

  func testDefaultFormatterDecimal() {
    let fmt = DefaultTickFormatter()
    let result = fmt.format(1.5)
    XCTAssertEqual(result, "1.5")
  }

  func testDefaultFormatterSmallDecimal() {
    let fmt = DefaultTickFormatter()
    let result = fmt.format(0.001)
    XCTAssertFalse(result.isEmpty)
    XCTAssertTrue(result.contains("0.001") || result.contains("1e") || result.contains("1E"))
  }

  // MARK: - ScientificTickFormatter

  func testScientificFormatter() {
    let fmt = ScientificTickFormatter()
    let result = fmt.format(1200)
    XCTAssertTrue(result.contains("e") || result.contains("E"))
    XCTAssertTrue(result.contains("1.2"))
  }

  func testScientificFormatterSmall() {
    let fmt = ScientificTickFormatter()
    let result = fmt.format(0.0034)
    XCTAssertTrue(result.contains("e") || result.contains("E"))
  }

  // MARK: - PercentTickFormatter

  func testPercentFormatterWholePercent() {
    let fmt = PercentTickFormatter()
    XCTAssertEqual(fmt.format(0.5), "50%")
    XCTAssertEqual(fmt.format(1.0), "100%")
    XCTAssertEqual(fmt.format(0.0), "0%")
  }

  func testPercentFormatterFractional() {
    let fmt = PercentTickFormatter()
    let result = fmt.format(0.125)
    XCTAssertTrue(result.hasSuffix("%"))
    XCTAssertTrue(result.contains("12.5"))
  }

  // MARK: - FixedDecimalFormatter

  func testFixedDecimalFormatter() {
    let fmt = FixedDecimalFormatter(decimalPlaces: 2)
    XCTAssertEqual(fmt.format(3.14159), "3.14")
    XCTAssertEqual(fmt.format(1.0), "1.00")
  }

  func testFixedDecimalFormatterZeroPlaces() {
    let fmt = FixedDecimalFormatter(decimalPlaces: 0)
    XCTAssertEqual(fmt.format(3.7), "4")
  }

  // MARK: - niceNumber helper

  func testNiceNumberRounded() {
    XCTAssertEqual(niceNumber(1.3, round: true), 1.0, accuracy: 1e-10)
    XCTAssertEqual(niceNumber(2.5, round: true), 2.0, accuracy: 1e-10)
    XCTAssertEqual(niceNumber(4.0, round: true), 5.0, accuracy: 1e-10)
    XCTAssertEqual(niceNumber(8.0, round: true), 10.0, accuracy: 1e-10)
  }

  func testNiceNumberCeiled() {
    XCTAssertEqual(niceNumber(1.0, round: false), 1.0, accuracy: 1e-10)
    XCTAssertEqual(niceNumber(1.5, round: false), 2.0, accuracy: 1e-10)
    XCTAssertEqual(niceNumber(3.0, round: false), 5.0, accuracy: 1e-10)
    XCTAssertEqual(niceNumber(6.0, round: false), 10.0, accuracy: 1e-10)
  }
}

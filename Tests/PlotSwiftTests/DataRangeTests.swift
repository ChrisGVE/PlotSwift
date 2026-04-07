//
//  DataRangeTests.swift
//  PlotSwiftTests
//
//  Tests for DataRange and AxisLimits
//

import XCTest

@testable import PlotSwift

final class DataRangeTests: XCTestCase {

  // MARK: - DataRange.from

  func testFromEmptyArray() {
    XCTAssertNil(DataRange.from([]))
  }

  func testFromSingleValue() {
    let r = DataRange.from([3.0])!
    XCTAssertEqual(r.min, 2.0)
    XCTAssertEqual(r.max, 4.0)
  }

  func testFromAllSameValues() {
    let r = DataRange.from([5.0, 5.0, 5.0])!
    XCTAssertEqual(r.min, 4.0)
    XCTAssertEqual(r.max, 6.0)
  }

  func testFromNormalArray() {
    let r = DataRange.from([1.0, 3.0, 2.0])!
    XCTAssertEqual(r.min, 1.0)
    XCTAssertEqual(r.max, 3.0)
  }

  func testFromFiltersNaN() {
    let r = DataRange.from([Double.nan, 2.0, Double.nan, 4.0])!
    XCTAssertEqual(r.min, 2.0)
    XCTAssertEqual(r.max, 4.0)
  }

  func testFromFiltersInfinity() {
    let r = DataRange.from([Double.infinity, 1.0, -Double.infinity, 5.0])!
    XCTAssertEqual(r.min, 1.0)
    XCTAssertEqual(r.max, 5.0)
  }

  func testFromAllNaN() {
    XCTAssertNil(DataRange.from([Double.nan, Double.nan]))
  }

  func testFromNegativeValues() {
    let r = DataRange.from([-5.0, -1.0, -3.0])!
    XCTAssertEqual(r.min, -5.0)
    XCTAssertEqual(r.max, -1.0)
  }

  func testFromZeroCrossing() {
    let r = DataRange.from([-2.0, 0.0, 3.0])!
    XCTAssertEqual(r.min, -2.0)
    XCTAssertEqual(r.max, 3.0)
  }

  // MARK: - Computed properties

  func testSpan() {
    let r = DataRange(min: 2.0, max: 7.0)
    XCTAssertEqual(r.span, 5.0)
  }

  func testCenter() {
    let r = DataRange(min: 0.0, max: 10.0)
    XCTAssertEqual(r.center, 5.0)
  }

  func testIsEmpty() {
    XCTAssertTrue(DataRange(min: 3.0, max: 3.0).isEmpty)
    XCTAssertFalse(DataRange(min: 1.0, max: 2.0).isEmpty)
  }

  // MARK: - contains

  func testContains() {
    let r = DataRange(min: 0.0, max: 10.0)
    XCTAssertTrue(r.contains(5.0))
    XCTAssertTrue(r.contains(0.0))
    XCTAssertTrue(r.contains(10.0))
    XCTAssertFalse(r.contains(-0.1))
    XCTAssertFalse(r.contains(10.1))
  }

  // MARK: - expanded

  func testExpandedSymmetric() {
    let r = DataRange(min: 0.0, max: 10.0)
    let expanded = r.expanded(by: 0.1)
    XCTAssertEqual(expanded.min, -1.0, accuracy: 1e-10)
    XCTAssertEqual(expanded.max, 11.0, accuracy: 1e-10)
  }

  func testExpandedZeroPadding() {
    let r = DataRange(min: 2.0, max: 8.0)
    let expanded = r.expanded(by: 0.0)
    XCTAssertEqual(expanded.min, 2.0)
    XCTAssertEqual(expanded.max, 8.0)
  }

  func testExpandedNegativeRange() {
    let r = DataRange(min: -10.0, max: -2.0)
    let expanded = r.expanded(by: 0.25)
    XCTAssertEqual(expanded.min, -12.0, accuracy: 1e-10)
    XCTAssertEqual(expanded.max, 0.0, accuracy: 1e-10)
  }

  // MARK: - union

  func testUnionNonOverlapping() {
    let a = DataRange(min: 1.0, max: 3.0)
    let b = DataRange(min: 5.0, max: 8.0)
    let u = a.union(with: b)
    XCTAssertEqual(u.min, 1.0)
    XCTAssertEqual(u.max, 8.0)
  }

  func testUnionOverlapping() {
    let a = DataRange(min: 0.0, max: 5.0)
    let b = DataRange(min: 3.0, max: 9.0)
    let u = a.union(with: b)
    XCTAssertEqual(u.min, 0.0)
    XCTAssertEqual(u.max, 9.0)
  }

  func testUnionIdentical() {
    let a = DataRange(min: 2.0, max: 4.0)
    XCTAssertEqual(a.union(with: a), a)
  }

  // MARK: - niceExpanded

  func testNiceExpandedTypical() {
    // 0.17 – 0.83 should expand to 0 – 1 with 0.2 spacing
    let r = DataRange(min: 0.17, max: 0.83)
    let (nice, spacing) = r.niceExpanded(targetTicks: 5)
    XCTAssertEqual(spacing, 0.2, accuracy: 1e-10)
    XCTAssertEqual(nice.min, 0.0, accuracy: 1e-10)
    XCTAssertEqual(nice.max, 1.0, accuracy: 1e-10)
  }

  func testNiceExpandedWholeNumbers() {
    let r = DataRange(min: 3.0, max: 23.0)
    let (nice, spacing) = r.niceExpanded(targetTicks: 5)
    // rawStep = 4, rounds to 5; floor(3/5)*5=0, ceil(23/5)*5=25
    XCTAssertEqual(spacing, 5.0)
    XCTAssertEqual(nice.min, 0.0)
    XCTAssertEqual(nice.max, 25.0)
  }

  func testNiceExpandedNegativeRange() {
    let r = DataRange(min: -7.0, max: -1.0)
    let (nice, spacing) = r.niceExpanded(targetTicks: 3)
    // rawStep = 2, nice = 2; floor(-7/2)*2=-8, ceil(-1/2)*2=0
    XCTAssertEqual(spacing, 2.0)
    XCTAssertEqual(nice.min, -8.0)
    XCTAssertEqual(nice.max, 0.0)
  }

  func testNiceExpandedZeroCrossing() {
    let r = DataRange(min: -3.5, max: 4.5)
    let (nice, spacing) = r.niceExpanded(targetTicks: 4)
    // rawStep = 2, nice = 2; floor(-3.5/2)*2=-4, ceil(4.5/2)*2=6
    XCTAssertEqual(spacing, 2.0)
    XCTAssertEqual(nice.min, -4.0)
    XCTAssertEqual(nice.max, 6.0)
  }

  func testNiceExpandedLargeNumbers() {
    let r = DataRange(min: 1_000.0, max: 9_000.0)
    let (nice, spacing) = r.niceExpanded(targetTicks: 4)
    // rawStep = 2000, nice = 2000; floor(1000/2000)*2000=0, ceil(9000/2000)*2000=10000
    XCTAssertEqual(spacing, 2_000.0)
    XCTAssertEqual(nice.min, 0.0)
    XCTAssertEqual(nice.max, 10_000.0)
  }

  func testNiceExpandedSmallNumbers() {
    let r = DataRange(min: 0.003, max: 0.007)
    let (_, spacing) = r.niceExpanded(targetTicks: 4)
    // rawStep ≈ 0.001, rounds to 0.001
    XCTAssertEqual(spacing, 0.001, accuracy: 1e-12)
  }

  // MARK: - AxisLimits

  func testAxisLimitsWithPadding() {
    let limits = AxisLimits(
      xRange: DataRange(min: 0.0, max: 10.0),
      yRange: DataRange(min: 0.0, max: 5.0)
    ).withPadding(0.1)
    XCTAssertEqual(limits.xRange.min, -1.0, accuracy: 1e-10)
    XCTAssertEqual(limits.xRange.max, 11.0, accuracy: 1e-10)
    XCTAssertEqual(limits.yRange.min, -0.5, accuracy: 1e-10)
    XCTAssertEqual(limits.yRange.max, 5.5, accuracy: 1e-10)
  }

  func testAxisLimitsNiceExpanded() {
    let limits = AxisLimits(
      xRange: DataRange(min: 0.17, max: 0.83),
      yRange: DataRange(min: 3.0, max: 23.0)
    ).niceExpanded(targetTicks: 5)
    XCTAssertEqual(limits.xRange.min, 0.0, accuracy: 1e-10)
    XCTAssertEqual(limits.xRange.max, 1.0, accuracy: 1e-10)
    XCTAssertEqual(limits.yRange.min, 0.0)
    XCTAssertEqual(limits.yRange.max, 25.0)
  }
}

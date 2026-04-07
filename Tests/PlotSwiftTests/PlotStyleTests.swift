//
//  PlotStyleTests.swift
//  PlotSwiftTests
//
//  Tests for PlotStyle global style configuration.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import PlotSwift

final class PlotStyleTests: XCTestCase {

  // Reset global state before every test so tests are independent.
  override func setUp() {
    super.setUp()
    PlotStyle.current = PlotStyle()
  }

  // MARK: - Default values

  func testDefaultFigureSize() {
    let style = PlotStyle()
    XCTAssertEqual(style.figureSize.0, 800)
    XCTAssertEqual(style.figureSize.1, 600)
  }

  func testDefaultColors() {
    let style = PlotStyle()
    XCTAssertEqual(style.backgroundColor, .white)
    XCTAssertEqual(style.gridColor, .lightGray)
    XCTAssertEqual(style.axesColor, .black)
  }

  func testDefaultTypography() {
    let style = PlotStyle()
    XCTAssertEqual(style.fontFamily, "sans-serif")
    XCTAssertEqual(style.titleFontSize, 16)
    XCTAssertEqual(style.labelFontSize, 12)
    XCTAssertEqual(style.tickFontSize, 10)
  }

  func testDefaultLineAndMarker() {
    let style = PlotStyle()
    XCTAssertEqual(style.lineWidth, 1.5)
    XCTAssertEqual(style.markerSize, 6)
  }

  func testDefaultGridOff() {
    XCTAssertFalse(PlotStyle().gridVisible)
  }

  func testDefaultGridLineStyle() {
    XCTAssertEqual(PlotStyle().gridLineStyle, .solid)
    XCTAssertEqual(PlotStyle().gridLineWidth, 0.5)
  }

  func testDefaultAxes() {
    let style = PlotStyle()
    XCTAssertEqual(style.axesLineWidth, 1.0)
  }

  func testDefaultPalette() {
    XCTAssertEqual(PlotStyle().palette.name, "tab10")
  }

  // MARK: - Mutability

  func testMutatingFigureSize() {
    var style = PlotStyle()
    style.figureSize = (1200, 900)
    XCTAssertEqual(style.figureSize.0, 1200)
    XCTAssertEqual(style.figureSize.1, 900)
  }

  func testMutatingLineWidth() {
    var style = PlotStyle()
    style.lineWidth = 3.0
    XCTAssertEqual(style.lineWidth, 3.0)
  }

  // MARK: - Global state

  func testDefaultCurrentMatchesDefault() {
    XCTAssertEqual(PlotStyle.current.lineWidth, PlotStyle.default.lineWidth)
    XCTAssertEqual(PlotStyle.current.backgroundColor, PlotStyle.default.backgroundColor)
  }

  func testSetStyleUpdatesCurrentGlobal() {
    setStyle(.darkgrid)
    XCTAssertTrue(PlotStyle.current.gridVisible)
    XCTAssertNotEqual(PlotStyle.current.backgroundColor, .white)
  }

  func testCurrentIsIndependentOfDefault() {
    PlotStyle.current.lineWidth = 5.0
    XCTAssertEqual(PlotStyle.default.lineWidth, 1.5,
      "Mutating current must not change default")
  }

  // MARK: - Predefined themes

  func testDarkgridTheme() {
    let theme = PlotStyle.darkgrid
    XCTAssertTrue(theme.gridVisible)
    XCTAssertEqual(theme.gridColor, Color(red: 1, green: 1, blue: 1))
    XCTAssertNotEqual(theme.backgroundColor, .white)
  }

  func testWhitegridTheme() {
    let theme = PlotStyle.whitegrid
    XCTAssertTrue(theme.gridVisible)
    XCTAssertEqual(theme.backgroundColor, .white)
  }

  func testDarkTheme() {
    let theme = PlotStyle.dark
    XCTAssertFalse(theme.gridVisible)
    XCTAssertNotEqual(theme.backgroundColor, .white)
  }

  func testWhiteTheme() {
    let theme = PlotStyle.white
    XCTAssertFalse(theme.gridVisible)
    XCTAssertEqual(theme.backgroundColor, .white)
  }

  func testTicksTheme() {
    let theme = PlotStyle.ticks
    XCTAssertFalse(theme.gridVisible)
    XCTAssertEqual(theme.backgroundColor, .white)
    XCTAssertGreaterThan(theme.axesLineWidth, PlotStyle.default.axesLineWidth)
  }

  // MARK: - setStyle convenience function

  func testSetStyleConvenienceFunction() {
    setStyle(.whitegrid)
    XCTAssertTrue(PlotStyle.current.gridVisible)
    XCTAssertEqual(PlotStyle.current.backgroundColor, .white)
  }

  func testSetStyleRoundTrip() {
    setStyle(.darkgrid)
    setStyle(PlotStyle.default)
    XCTAssertFalse(PlotStyle.current.gridVisible)
    XCTAssertEqual(PlotStyle.current.lineWidth, 1.5)
  }
}

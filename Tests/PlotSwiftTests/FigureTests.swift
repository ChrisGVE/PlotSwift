//
//  FigureTests.swift
//  PlotSwift
//
//  Tests for Figure and the subplots() convenience function.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import XCTest

@testable import PlotSwift

final class FigureTests: XCTestCase {

  // MARK: - Figure creation

  func testDefaultFigureSize() {
    let fig = Figure()
    XCTAssertEqual(fig.size.width, 800)
    XCTAssertEqual(fig.size.height, 600)
  }

  func testCustomFigureSize() {
    let fig = Figure(width: 1280, height: 720)
    XCTAssertEqual(fig.size.width, 1280)
    XCTAssertEqual(fig.size.height, 720)
  }

  func testDefaultBackgroundColor() {
    XCTAssertEqual(Figure().backgroundColor, .white)
  }

  func testCustomBackgroundColor() {
    let fig = Figure()
    fig.backgroundColor = .black
    XCTAssertEqual(fig.backgroundColor, .black)
  }

  func testInitialAxesListIsEmpty() {
    XCTAssertTrue(Figure().axesList.isEmpty)
  }

  // MARK: - addAxes

  func testAddAxesReturnsAxes() {
    let fig = Figure()
    let ax = fig.addAxes()
    XCTAssertNotNil(ax)
  }

  func testAddAxesAppendsToAxesList() {
    let fig = Figure()
    fig.addAxes()
    XCTAssertEqual(fig.axesList.count, 1)
  }

  func testAddMultipleAxes() {
    let fig = Figure()
    let a1 = fig.addAxes()
    let a2 = fig.addAxes()
    XCTAssertEqual(fig.axesList.count, 2)
    XCTAssertTrue(fig.axesList[0] === a1)
    XCTAssertTrue(fig.axesList[1] === a2)
  }

  func testAddAxesDefaultBoundsWithinFigure() {
    let fig = Figure(width: 800, height: 600)
    let ax = fig.addAxes()
    let bounds = ax.plotArea.bounds
    // Default-margin bounds must lie strictly inside the figure.
    XCTAssertGreaterThan(bounds.minX, 0)
    XCTAssertGreaterThan(bounds.minY, 0)
    XCTAssertLessThan(Double(bounds.maxX), 800)
    XCTAssertLessThan(Double(bounds.maxY), 600)
  }

  func testAddAxesCustomRect() {
    let fig = Figure(width: 800, height: 600)
    let custom = CGRect(x: 10, y: 20, width: 400, height: 300)
    let ax = fig.addAxes(rect: custom)
    XCTAssertEqual(ax.plotArea.bounds, custom)
  }

  // MARK: - addSubplot

  func testAddSubplotSingleCell() {
    let fig = Figure(width: 800, height: 600)
    let ax = fig.addSubplot(rows: 1, cols: 1, index: 1)
    XCTAssertNotNil(ax)
    XCTAssertEqual(fig.axesList.count, 1)
  }

  func testAddSubplotFillsGrid() {
    let fig = Figure(width: 800, height: 600)
    for i in 1...4 {
      fig.addSubplot(rows: 2, cols: 2, index: i)
    }
    XCTAssertEqual(fig.axesList.count, 4)
  }

  func testAddSubplotPositionsAreDistinct() {
    let fig = Figure(width: 800, height: 600)
    let ax1 = fig.addSubplot(rows: 1, cols: 2, index: 1)
    let ax2 = fig.addSubplot(rows: 1, cols: 2, index: 2)
    // Columns must not overlap.
    XCTAssertNotEqual(ax1.plotArea.bounds.origin.x, ax2.plotArea.bounds.origin.x)
  }

  func testAddSubplotRowPositionsAreDistinct() {
    let fig = Figure(width: 800, height: 600)
    let ax1 = fig.addSubplot(rows: 2, cols: 1, index: 1)
    let ax2 = fig.addSubplot(rows: 2, cols: 1, index: 2)
    XCTAssertNotEqual(ax1.plotArea.bounds.origin.y, ax2.plotArea.bounds.origin.y)
  }

  func testAddSubplotBoundsWithinFigure() {
    let fig = Figure(width: 800, height: 600)
    for i in 1...4 {
      let ax = fig.addSubplot(rows: 2, cols: 2, index: i)
      let b = ax.plotArea.bounds
      XCTAssertGreaterThanOrEqual(Double(b.minX), 0)
      XCTAssertGreaterThanOrEqual(Double(b.minY), 0)
      XCTAssertLessThanOrEqual(Double(b.maxX), 800)
      XCTAssertLessThanOrEqual(Double(b.maxY), 600)
    }
  }

  // MARK: - Export

  func testRenderToPNGProducesData() {
    let fig = Figure()
    fig.addAxes()
    let data = fig.renderToPNG()
    XCTAssertNotNil(data)
    XCTAssertGreaterThan(data?.count ?? 0, 0)
  }

  func testRenderToPNGWithScale() {
    let fig = Figure(width: 400, height: 300)
    let data1x = fig.renderToPNG(scale: 1.0)
    let data2x = fig.renderToPNG(scale: 2.0)
    XCTAssertNotNil(data1x)
    XCTAssertNotNil(data2x)
    // 2× render must be larger than 1× render.
    XCTAssertGreaterThan(data2x?.count ?? 0, data1x?.count ?? 0)
  }

  func testRenderToPDFProducesData() {
    let fig = Figure()
    fig.addAxes()
    let data = fig.renderToPDF()
    XCTAssertNotNil(data)
    XCTAssertGreaterThan(data?.count ?? 0, 0)
  }

  func testRenderToSVGProducesNonEmptyString() {
    let fig = Figure()
    fig.addAxes()
    let svg = fig.renderToSVG()
    XCTAssertFalse(svg.isEmpty)
    XCTAssertTrue(svg.contains("<svg"))
  }

  func testRenderToSVGContainsFigureDimensions() {
    let fig = Figure(width: 1024, height: 768)
    let svg = fig.renderToSVG()
    XCTAssertTrue(svg.contains("1024"))
    XCTAssertTrue(svg.contains("768"))
  }

  func testRenderWithNoAxesStillProducesOutput() {
    let fig = Figure()
    XCTAssertNotNil(fig.renderToPNG())
    XCTAssertNotNil(fig.renderToPDF())
    XCTAssertFalse(fig.renderToSVG().isEmpty)
  }

  // MARK: - subplots convenience

  func testSubplotsSingleReturnsOneFigureOneAxes() {
    let (fig, grid) = subplots()
    XCTAssertEqual(fig.axesList.count, 1)
    XCTAssertEqual(grid.count, 1)
    XCTAssertEqual(grid[0].count, 1)
  }

  func testSubplotsGridShape() {
    let (fig, grid) = subplots(rows: 2, cols: 3)
    XCTAssertEqual(fig.axesList.count, 6)
    XCTAssertEqual(grid.count, 2)
    XCTAssertEqual(grid[0].count, 3)
    XCTAssertEqual(grid[1].count, 3)
  }

  func testSubplotsFigsize() {
    let (fig, _) = subplots(figsize: (1200, 900))
    XCTAssertEqual(fig.size.width, 1200)
    XCTAssertEqual(fig.size.height, 900)
  }

  func testSubplotsGridAxesMatchFigureAxesList() {
    let (fig, grid) = subplots(rows: 2, cols: 2)
    let flatGrid = grid.flatMap { $0 }
    XCTAssertEqual(flatGrid.count, fig.axesList.count)
    for (gridAx, listAx) in zip(flatGrid, fig.axesList) {
      XCTAssertTrue(gridAx === listAx)
    }
  }

  func testSubplotsAllAxesHaveDistinctBounds() {
    let (_, grid) = subplots(rows: 2, cols: 2, figsize: (800, 600))
    let flat = grid.flatMap { $0 }
    let origins = flat.map { $0.plotArea.bounds.origin }
    let unique = Set(origins.map { "\($0.x),\($0.y)" })
    XCTAssertEqual(unique.count, flat.count)
  }
}

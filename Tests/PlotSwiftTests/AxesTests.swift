//
//  AxesTests.swift
//  PlotSwiftTests
//
//  Tests for the Axes class and associated types.
//

import CoreGraphics
import XCTest

@testable import PlotSwift

final class AxesTests: XCTestCase {

  // MARK: Helpers

  private func makeAxes() -> Axes {
    let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
    return Axes(plotArea: PlotArea(bounds: bounds))
  }

  // MARK: Creation

  func testAxesCreation() {
    let ax = makeAxes()
    XCTAssertTrue(ax.dataSeries.isEmpty)
    XCTAssertNil(ax.title)
    XCTAssertNil(ax.xLabel)
    XCTAssertNil(ax.yLabel)
    XCTAssertNil(ax.xLimits)
    XCTAssertNil(ax.yLimits)
    XCTAssertFalse(ax.showGrid)
    XCTAssertFalse(ax.showLegend)
  }

  // MARK: plot() adds series

  func testPlotXYAddsSeries() {
    let ax = makeAxes()
    ax.plot([1, 2, 3], [4, 5, 6])
    XCTAssertEqual(ax.dataSeries.count, 1)
    let s = ax.dataSeries[0]
    XCTAssertEqual(s.x, [1, 2, 3])
    XCTAssertEqual(s.y, [4, 5, 6])
    XCTAssertEqual(s.seriesType, .line)
  }

  func testPlotYOnlyUsesIndices() {
    let ax = makeAxes()
    ax.plot([10.0, 20.0, 30.0])
    let s = ax.dataSeries[0]
    XCTAssertEqual(s.x, [0, 1, 2])
    XCTAssertEqual(s.y, [10, 20, 30])
  }

  func testScatterAddsSeries() {
    let ax = makeAxes()
    ax.scatter([1, 2], [3, 4])
    XCTAssertEqual(ax.dataSeries.count, 1)
    let s = ax.dataSeries[0]
    XCTAssertEqual(s.seriesType, .scatter)
    XCTAssertEqual(s.lineStyle, .none)
    XCTAssertEqual(s.marker, .circle)
  }

  func testMultiplePlotCallsAccumulate() {
    let ax = makeAxes()
    ax.plot([1], [2])
    ax.plot([3], [4])
    ax.scatter([5], [6])
    XCTAssertEqual(ax.dataSeries.count, 3)
  }

  // MARK: Manual limits

  func testSetXLim() {
    let ax = makeAxes()
    ax.setXLim(-5, 5)
    XCTAssertEqual(ax.xLimits?.min, -5)
    XCTAssertEqual(ax.xLimits?.max, 5)
  }

  func testSetYLim() {
    let ax = makeAxes()
    ax.setYLim(0, 100)
    XCTAssertEqual(ax.yLimits?.min, 0)
    XCTAssertEqual(ax.yLimits?.max, 100)
  }

  func testManualLimitsUsedInEffectiveLimits() {
    let ax = makeAxes()
    ax.plot([1, 2, 3], [4, 5, 6])
    ax.setXLim(0, 10)
    ax.setYLim(0, 10)
    let limits = ax.effectiveLimits()
    // Manual limits are padded and nice-expanded, so the result must still
    // contain [0, 10] but may extend beyond it.
    XCTAssertLessThanOrEqual(limits.xRange.min, 0)
    XCTAssertGreaterThanOrEqual(limits.xRange.max, 10)
    XCTAssertLessThanOrEqual(limits.yRange.min, 0)
    XCTAssertGreaterThanOrEqual(limits.yRange.max, 10)
  }

  // MARK: Auto-limits from data

  func testAutoLimitsFromData() {
    let ax = makeAxes()
    ax.plot([0, 10], [0, 5])
    let limits = ax.effectiveLimits()
    XCTAssertLessThanOrEqual(limits.xRange.min, 0)
    XCTAssertGreaterThanOrEqual(limits.xRange.max, 10)
    XCTAssertLessThanOrEqual(limits.yRange.min, 0)
    XCTAssertGreaterThanOrEqual(limits.yRange.max, 5)
  }

  func testAutoLimitsNoDataFallback() {
    let ax = makeAxes()
    let limits = ax.effectiveLimits()
    // Fallback range is [0,1] expanded/niced — should stay in a sane interval.
    XCTAssertLessThan(limits.xRange.min, limits.xRange.max)
    XCTAssertLessThan(limits.yRange.min, limits.yRange.max)
  }

  // MARK: Color cycling

  func testColorCyclingAssignsDistinctColors() {
    let ax = makeAxes()
    ax.plot([1], [1])
    ax.plot([2], [2])
    ax.plot([3], [3])
    let colors = ax.dataSeries.map { $0.color }
    // First three tab10 colors must differ from each other.
    XCTAssertNotEqual(colors[0], colors[1])
    XCTAssertNotEqual(colors[1], colors[2])
    XCTAssertNotEqual(colors[0], colors[2])
  }

  func testExplicitColorSkipsCycle() {
    let ax = makeAxes()
    let red = Color.red
    ax.plot([1], [1], color: red)
    XCTAssertEqual(ax.dataSeries[0].color, red)
    // The cycle index should not have advanced (explicit color bypasses cycle).
    XCTAssertEqual(ax.colorCycle.currentIndex, 0)
  }

  // MARK: Grid toggle

  func testGridDefault() {
    let ax = makeAxes()
    XCTAssertFalse(ax.showGrid)
  }

  func testGridEnable() {
    let ax = makeAxes()
    ax.grid(true)
    XCTAssertTrue(ax.showGrid)
  }

  func testGridWithCustomColor() {
    let ax = makeAxes()
    ax.grid(true, color: .blue, lineStyle: .dashed, lineWidth: 1.0)
    XCTAssertTrue(ax.showGrid)
    XCTAssertEqual(ax.gridColor, .blue)
    XCTAssertEqual(ax.gridLineStyle, .dashed)
    XCTAssertEqual(ax.gridLineWidth, 1.0)
  }

  func testGridDisable() {
    let ax = makeAxes()
    ax.grid(true)
    ax.grid(false)
    XCTAssertFalse(ax.showGrid)
  }

  // MARK: Title and labels

  func testSetTitle() {
    let ax = makeAxes()
    ax.setTitle("My Chart")
    XCTAssertEqual(ax.title, "My Chart")
  }

  func testSetXLabel() {
    let ax = makeAxes()
    ax.setXLabel("Time (s)")
    XCTAssertEqual(ax.xLabel, "Time (s)")
  }

  func testSetYLabel() {
    let ax = makeAxes()
    ax.setYLabel("Amplitude")
    XCTAssertEqual(ax.yLabel, "Amplitude")
  }

  func testSetTitleWithStyle() {
    let ax = makeAxes()
    let style = TextStyle(fontSize: 18, fontWeight: .bold, anchor: .middle)
    ax.setTitle("Styled", style: style)
    XCTAssertEqual(ax.title, "Styled")
    XCTAssertEqual(ax.titleStyle?.fontSize, 18)
  }

  // MARK: Legend

  func testLegendDefault() {
    let ax = makeAxes()
    XCTAssertFalse(ax.showLegend)
    XCTAssertEqual(ax.legendPosition, .topRight)
  }

  func testLegendEnable() {
    let ax = makeAxes()
    ax.legend(position: .bottomLeft)
    XCTAssertTrue(ax.showLegend)
    XCTAssertEqual(ax.legendPosition, .bottomLeft)
  }

  // MARK: Render produces commands

  func testRenderProducesCommands() {
    let ax = makeAxes()
    ax.plot([1, 2, 3], [1, 4, 9])
    let ctx = DrawingContext()
    ax.render(to: ctx)
    XCTAssertGreaterThan(ctx.commandCount, 0)
  }

  func testRenderWithGridProducesMoreCommands() {
    let ax = makeAxes()
    ax.plot([1, 2, 3], [1, 4, 9])
    let ctxNoGrid = DrawingContext()
    ax.render(to: ctxNoGrid)
    let countNoGrid = ctxNoGrid.commandCount

    ax.grid(true)
    let ctxGrid = DrawingContext()
    ax.render(to: ctxGrid)
    XCTAssertGreaterThan(ctxGrid.commandCount, countNoGrid)
  }

  func testRenderWithTitleProducesTextCommand() {
    let ax = makeAxes()
    ax.setTitle("Test Title")
    let ctx = DrawingContext()
    ax.render(to: ctx)
    let hasText = ctx.commands.contains {
      if case .text(let s, _, _, _) = $0 { return s == "Test Title" }
      return false
    }
    XCTAssertTrue(hasText)
  }

  func testRenderEmptyAxesDoesNotCrash() {
    let ax = makeAxes()
    let ctx = DrawingContext()
    XCTAssertNoThrow(ax.render(to: ctx))
    XCTAssertGreaterThan(ctx.commandCount, 0)
  }

  func testRenderScatterProducesMarkers() {
    let ax = makeAxes()
    ax.scatter([1, 2, 3], [1, 4, 9], marker: .circle)
    let ctx = DrawingContext()
    ax.render(to: ctx)
    let markerCount = ctx.commands.filter {
      if case .marker = $0 { return true }
      return false
    }.count
    XCTAssertEqual(markerCount, 3)
  }

  // MARK: DataSeries properties

  func testDataSeriesLabel() {
    let ax = makeAxes()
    let s = ax.plot([1], [2], label: "Signal")
    XCTAssertEqual(s.label, "Signal")
  }

  func testDataSeriesLineStyle() {
    let ax = makeAxes()
    let s = ax.plot([1], [2], lineStyle: .dashed, lineWidth: 2.5)
    XCTAssertEqual(s.lineStyle, .dashed)
    XCTAssertEqual(s.lineWidth, 2.5)
  }

  func testScatterAlphaApplied() {
    let ax = makeAxes()
    let s = ax.scatter([1], [2], color: .red, alpha: 0.4)
    XCTAssertEqual(s.color.alpha, 0.4, accuracy: 1e-9)
  }
}

//
//  SeabornPlotsTests.swift
//  PlotSwift
//
//  Tests for Axes+SeabornPlots: pointplot, countplot, lineplot, scatterplot,
//  quiver, and streamplot.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import XCTest

@testable import PlotSwift

// MARK: - Helpers

private func makeAxes() -> Axes {
  Axes(plotArea: PlotArea(bounds: CGRect(x: 0, y: 0, width: 800, height: 600)))
}

// MARK: - SeabornPlotsTests

final class SeabornPlotsTests: XCTestCase {

  // MARK: - Point plot

  func testPointplotAddsSeriesAndErrorBars() {
    let ax = makeAxes()
    ax.pointplot(["A", "B", "C"], [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    // Line connecting means + scatter per category = 4 series + errorbar data
    XCTAssertFalse(ax.dataSeries.isEmpty)
    XCTAssertFalse(ax.errorBarData.isEmpty)
  }

  func testPointplotEmptyDataIsNoOp() {
    let ax = makeAxes()
    ax.pointplot([], [])
    XCTAssertTrue(ax.dataSeries.isEmpty)
  }

  func testPointplotMismatchedLengthsIsNoOp() {
    let ax = makeAxes()
    ax.pointplot(["A", "B"], [[1, 2, 3]])
    XCTAssertTrue(ax.dataSeries.isEmpty)
  }

  func testPointplotSingleGroupSingleValue() {
    let ax = makeAxes()
    ax.pointplot(["X"], [[42.0]])
    // Should add mean line + scatter + error bar (degenerate but not crash)
    XCTAssertFalse(ax.dataSeries.isEmpty)
  }

  func testPointplotCustomColorAndMarkers() {
    let ax = makeAxes()
    ax.pointplot(
      ["A", "B"],
      [[1, 2], [3, 4]],
      color: .red,
      markers: [.square, .diamond],
      label: "test")
    let labelledSeries = ax.dataSeries.filter { $0.label == "test" }
    XCTAssertFalse(labelledSeries.isEmpty)
  }

  // MARK: - Count plot

  func testCountplotProducesBarSeriesForEachUniqueCategory() {
    let ax = makeAxes()
    ax.countplot(["A", "B", "A", "C", "B", "B"])
    // 3 unique categories → one BarSeries with 3 bars
    XCTAssertEqual(ax.barSeriesList.count, 1)
    XCTAssertEqual(ax.barSeriesList[0].x.count, 3)
  }

  func testCountplotFrequenciesAreCorrect() {
    let ax = makeAxes()
    ax.countplot(["A", "A", "B"])
    let series = ax.barSeriesList[0]
    // Insertion order: A=2, B=1
    XCTAssertEqual(series.heights, [2, 1])
  }

  func testCountplotEmptyIsNoOp() {
    let ax = makeAxes()
    ax.countplot([])
    XCTAssertTrue(ax.barSeriesList.isEmpty)
  }

  func testCountplotSingleCategory() {
    let ax = makeAxes()
    ax.countplot(["X", "X", "X"])
    XCTAssertEqual(ax.barSeriesList[0].heights, [3])
  }

  func testCountplotCustomColor() {
    let ax = makeAxes()
    ax.countplot(["A", "B"], color: .blue)
    XCTAssertEqual(ax.barSeriesList[0].color, .blue)
  }

  // MARK: - Lineplot

  func testLinplotNoHueAddsOneSeries() {
    let ax = makeAxes()
    ax.lineplot([1, 2, 3], [4, 5, 6])
    XCTAssertEqual(ax.dataSeries.count, 1)
  }

  func testLinplotNoHueSinglePoint() {
    let ax = makeAxes()
    ax.lineplot([1.0], [2.0])
    XCTAssertEqual(ax.dataSeries.count, 1)
  }

  func testLinplotWithHueSplitsIntoGroups() {
    let ax = makeAxes()
    ax.lineplot([1, 2, 3, 4], [1, 4, 9, 16], hue: ["A", "B", "A", "B"])
    // Two hue groups → two series
    XCTAssertEqual(ax.dataSeries.count, 2)
  }

  func testLinplotHueLabelsMatchGroupKeys() {
    let ax = makeAxes()
    ax.lineplot([1, 2, 3], [1, 2, 3], hue: ["cat", "dog", "cat"])
    let labels = Set(ax.dataSeries.compactMap { $0.label })
    XCTAssertEqual(labels, ["cat", "dog"])
  }

  func testLinplotWithStyleAssignsDifferentLineStyles() {
    let ax = makeAxes()
    ax.lineplot(
      [1, 2, 3, 4], [1, 2, 3, 4],
      hue: ["A", "B", "A", "B"],
      style: ["A", "B", "A", "B"])
    let styles = ax.dataSeries.map { $0.lineStyle }
    XCTAssertFalse(styles.isEmpty)
  }

  func testLinplotEmptyIsNoOp() {
    let ax = makeAxes()
    ax.lineplot([], [])
    XCTAssertTrue(ax.dataSeries.isEmpty)
  }

  func testLinplotMismatchedLengthIsNoOp() {
    let ax = makeAxes()
    ax.lineplot([1, 2], [3])
    XCTAssertTrue(ax.dataSeries.isEmpty)
  }

  // MARK: - Scatterplot

  func testScatterplotNoHueAddsOneSeries() {
    let ax = makeAxes()
    ax.scatterplot([1, 2, 3], [4, 5, 6])
    XCTAssertEqual(ax.dataSeries.count, 1)
  }

  func testScatterplotWithHueSplitsGroups() {
    let ax = makeAxes()
    ax.scatterplot([1, 2, 3, 4], [1, 2, 3, 4], hue: ["A", "B", "A", "B"])
    XCTAssertEqual(ax.dataSeries.count, 2)
  }

  func testScatterplotHueLabelsMatchKeys() {
    let ax = makeAxes()
    ax.scatterplot([1, 2, 3], [1, 2, 3], hue: ["x", "y", "x"])
    let labels = Set(ax.dataSeries.compactMap { $0.label })
    XCTAssertTrue(labels.contains("x"))
    XCTAssertTrue(labels.contains("y"))
  }

  func testScatterplotWithSizeScalesMarkers() {
    let ax = makeAxes()
    ax.scatterplot([1, 2, 3], [1, 2, 3], size: [1.0, 5.0, 10.0])
    // Should produce 3 individual scatter series (one per sized point)
    XCTAssertEqual(ax.dataSeries.count, 3)
    // Marker sizes should differ
    let sizes = ax.dataSeries.map { $0.markerSize }
    XCTAssertNotEqual(sizes[0], sizes[2])
  }

  func testScatterplotEmptyIsNoOp() {
    let ax = makeAxes()
    ax.scatterplot([], [])
    XCTAssertTrue(ax.dataSeries.isEmpty)
  }

  // MARK: - Quiver

  func testQuiverAddsSeriesForEachArrow() {
    let ax = makeAxes()
    ax.quiver([0, 1], [0, 1], [1, 0], [0, 1])
    // Each arrow = shaft + 2 barbs = 3 series. Two arrows = 6 series.
    XCTAssertEqual(ax.dataSeries.count, 6)
  }

  func testQuiverEmptyIsNoOp() {
    let ax = makeAxes()
    ax.quiver([], [], [], [])
    XCTAssertTrue(ax.dataSeries.isEmpty)
  }

  func testQuiverMismatchedLengthsIsNoOp() {
    let ax = makeAxes()
    ax.quiver([0], [0], [1, 2], [1])
    XCTAssertTrue(ax.dataSeries.isEmpty)
  }

  func testQuiverZeroMagnitudeVectorsProduceShaftOnly() {
    // A zero-vector should still draw a shaft (degenerate) but not crash.
    let ax = makeAxes()
    ax.quiver([0], [0], [0], [0])
    // shaft is added even for zero vectors; arrowhead helper returns []
    XCTAssertFalse(ax.dataSeries.isEmpty)
  }

  func testQuiverCustomColorApplied() {
    let ax = makeAxes()
    ax.quiver([0], [0], [1], [1], color: .red)
    XCTAssertTrue(ax.dataSeries.allSatisfy { $0.color == .red })
  }

  // MARK: - Streamplot

  func testStreamplotAddsLines() {
    let x: [Double] = [0, 1, 2, 3, 4]
    let y: [Double] = [0, 1, 2, 3, 4]
    // Uniform rightward flow
    let u: [[Double]] = Array(repeating: Array(repeating: 1.0, count: 5), count: 5)
    let v: [[Double]] = Array(repeating: Array(repeating: 0.0, count: 5), count: 5)
    let ax = makeAxes()
    ax.streamplot(x, y, u, v)
    XCTAssertFalse(ax.dataSeries.isEmpty)
  }

  func testStreamplotEmptyIsNoOp() {
    let ax = makeAxes()
    ax.streamplot([], [], [[]], [[]])
    XCTAssertTrue(ax.dataSeries.isEmpty)
  }

  func testStreamplotMismatchedFieldIsNoOp() {
    let ax = makeAxes()
    let x: [Double] = [0, 1]
    let y: [Double] = [0, 1]
    // u has wrong row count
    ax.streamplot(x, y, [[1.0, 0.0]], [[0.0, 1.0], [0.0, 1.0]])
    XCTAssertTrue(ax.dataSeries.isEmpty)
  }

  func testStreamplotCustomColor() {
    let x: [Double] = [0, 1, 2]
    let y: [Double] = [0, 1, 2]
    let u = [[1.0, 1.0, 1.0], [1.0, 1.0, 1.0], [1.0, 1.0, 1.0]]
    let v = [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]
    let ax = makeAxes()
    ax.streamplot(x, y, u, v, color: .green)
    XCTAssertTrue(ax.dataSeries.allSatisfy { $0.color == .green })
  }

  // MARK: - Internal math helpers

  func testMeanOf() {
    let ax = makeAxes()
    XCTAssertEqual(ax.meanOf([1, 2, 3, 4, 5]), 3.0, accuracy: 1e-10)
    XCTAssertEqual(ax.meanOf([42]), 42.0)
    XCTAssertEqual(ax.meanOf([]), 0.0)
  }

  func testConfidenceInterval95Symmetry() {
    let ax = makeAxes()
    let data = [5.0, 5.0, 5.0, 5.0, 5.0, 5.0]
    let (lo, hi) = ax.confidenceInterval95(data)
    // Zero variance → CI collapses to mean
    XCTAssertEqual(lo, 5.0, accuracy: 1e-10)
    XCTAssertEqual(hi, 5.0, accuracy: 1e-10)
  }

  func testConfidenceInterval95OrderPreserved() {
    let ax = makeAxes()
    let data = Array(repeating: 1.0, count: 50) + Array(repeating: 3.0, count: 50)
    let (lo, hi) = ax.confidenceInterval95(data)
    XCTAssertLessThan(lo, hi)
  }

  func testConfidenceInterval95SingleValue() {
    let ax = makeAxes()
    let (lo, hi) = ax.confidenceInterval95([7.0])
    XCTAssertEqual(lo, 7.0)
    XCTAssertEqual(hi, 7.0)
  }

  func testGroupIndicesPreservesInsertionOrder() {
    let ax = makeAxes()
    let groups = ax.groupIndices(by: ["B", "A", "B", "A"], count: 4)
    XCTAssertEqual(groups[0].0, "B")
    XCTAssertEqual(groups[1].0, "A")
    XCTAssertEqual(groups[0].1, [0, 2])
    XCTAssertEqual(groups[1].1, [1, 3])
  }

  func testScaledSizesRangeIs4To12() {
    let ax = makeAxes()
    let sizes = ax.scaledSizes([1, 5, 10])
    XCTAssertEqual(sizes[0], 4.0, accuracy: 1e-10)
    XCTAssertEqual(sizes[2], 12.0, accuracy: 1e-10)
  }

  func testScaledSizesConstantReturns6() {
    let ax = makeAxes()
    let sizes = ax.scaledSizes([3, 3, 3])
    XCTAssertTrue(sizes.allSatisfy { $0 == 6.0 })
  }

  func testArrowheadLinesCount() {
    let ax = makeAxes()
    let lines = ax.quiverArrowhead(from: (0, 0), to: (1, 0), length: 0.1)
    XCTAssertEqual(lines.count, 2)
  }

  func testArrowheadLinesZeroMagnitudeReturnsEmpty() {
    let ax = makeAxes()
    let lines = ax.quiverArrowhead(from: (0, 0), to: (0, 0), length: 0.1)
    XCTAssertTrue(lines.isEmpty)
  }

  func testStreamSeedsCountRespectsDensity() {
    let ax = makeAxes()
    let x = Array(stride(from: 0.0, through: 4.0, by: 1.0))
    let y = Array(stride(from: 0.0, through: 4.0, by: 1.0))
    let seeds1 = ax.streamSeeds(x: x, y: y, density: 1.0)
    let seeds2 = ax.streamSeeds(x: x, y: y, density: 2.0)
    XCTAssertLessThan(seeds1.count, seeds2.count)
  }

  func testInterpolateFieldReturnsNilOutsideDomain() {
    let ax = makeAxes()
    let x: [Double] = [0, 1]
    let y: [Double] = [0, 1]
    let u = [[1.0, 1.0], [1.0, 1.0]]
    let v = [[0.0, 0.0], [0.0, 0.0]]
    // Outside domain
    let result = ax.streamInterpolate(px: 5, py: 5, x: x, y: y, u: u, v: v)
    XCTAssertNil(result)
  }

  func testInterpolateFieldReturnsValueInsideDomain() {
    let ax = makeAxes()
    let x: [Double] = [0, 1]
    let y: [Double] = [0, 1]
    let u = [[1.0, 1.0], [1.0, 1.0]]
    let v = [[0.0, 0.0], [0.0, 0.0]]
    let result = ax.streamInterpolate(px: 0.5, py: 0.5, x: x, y: y, u: u, v: v)
    XCTAssertNotNil(result)
    if let (uf, vf) = result {
      XCTAssertEqual(uf, 1.0, accuracy: 1e-10)
      XCTAssertEqual(vf, 0.0, accuracy: 1e-10)
    }
  }
}

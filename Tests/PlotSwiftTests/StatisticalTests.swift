//
//  StatisticalTests.swift
//  PlotSwiftTests
//
//  Tests for Axes+Statistical: boxplot, violinplot, kdeplot, ecdfplot, heatmap.
//

import CoreGraphics
import XCTest

@testable import PlotSwift

// MARK: - Helpers

private func makeAxes() -> Axes {
  let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
  return Axes(plotArea: PlotArea(bounds: bounds))
}

// MARK: - Statistical math helpers

final class StatisticalMathTests: XCTestCase {

  private var axes: Axes!

  override func setUp() {
    super.setUp()
    axes = makeAxes()
  }

  // MARK: percentile

  func testPercentile_singleElement() {
    XCTAssertEqual(axes.percentile([5.0], 0.5), 5.0)
  }

  func testPercentile_median_evenCount() {
    // [1, 2, 3, 4] median at p=0.5 → index 1.5 → lerp(2, 3, 0.5) = 2.5
    let result = axes.percentile([1, 2, 3, 4], 0.5)
    XCTAssertEqual(result, 2.5, accuracy: 1e-10)
  }

  func testPercentile_q1_q3() {
    let sorted = [1.0, 2, 3, 4, 5, 6, 7, 8]
    let q1 = axes.percentile(sorted, 0.25)
    let q3 = axes.percentile(sorted, 0.75)
    XCTAssertEqual(q1, 2.75, accuracy: 1e-10)
    XCTAssertEqual(q3, 6.25, accuracy: 1e-10)
  }

  // MARK: quartiles

  func testQuartiles_symmetricData() {
    let (q1, med, q3) = axes.quartiles([1, 2, 3, 4, 5])
    XCTAssertEqual(med, 3.0, accuracy: 1e-10)
    XCTAssertLessThan(q1, med)
    XCTAssertGreaterThan(q3, med)
  }

  func testQuartiles_emptyArray() {
    let (q1, med, q3) = axes.quartiles([])
    XCTAssertEqual(q1, 0)
    XCTAssertEqual(med, 0)
    XCTAssertEqual(q3, 0)
  }

  // MARK: silvermanBandwidth

  func testSilvermanBandwidth_singlePoint() {
    XCTAssertEqual(axes.silvermanBandwidth([3.0]), 1.0)
  }

  func testSilvermanBandwidth_positiveForNormalData() {
    let data = stride(from: -3.0, through: 3.0, by: 0.1).map { $0 }
    let h = axes.silvermanBandwidth(data)
    XCTAssertGreaterThan(h, 0)
  }

  func testSilvermanBandwidth_decreasesWithMoreData() {
    let small = [1.0, 2, 3, 4, 5]
    let large = stride(from: 1.0, through: 5.0, by: 0.1).map { $0 }
    let hSmall = axes.silvermanBandwidth(small)
    let hLarge = axes.silvermanBandwidth(large)
    XCTAssertGreaterThan(hSmall, hLarge)
  }

  // MARK: gaussianKDE

  func testGaussianKDE_returnsCorrectCount() {
    let (xs, ys) = axes.gaussianKDE(data: [1, 2, 3], bandwidth: 0.5, steps: 50)
    XCTAssertEqual(xs.count, 50)
    XCTAssertEqual(ys.count, 50)
  }

  func testGaussianKDE_densitiesNonNegative() {
    let data = [1.0, 2, 2, 3, 4]
    let (_, ys) = axes.gaussianKDE(data: data, bandwidth: 0.5, steps: 100)
    XCTAssertTrue(ys.allSatisfy { $0 >= 0 })
  }

  func testGaussianKDE_peaksNearMean() {
    // Symmetric data: peak should be near the mean.
    let data = [-1.0, 0, 0, 0, 1]
    let (xs, ys) = axes.gaussianKDE(data: data, bandwidth: 0.5, steps: 200)
    let maxIdx = ys.indices.max(by: { ys[$0] < ys[$1] })!
    XCTAssertEqual(xs[maxIdx], 0, accuracy: 0.2)
  }

  func testGaussianKDE_emptyDataReturnsEmpty() {
    let (xs, ys) = axes.gaussianKDE(data: [], bandwidth: 0.5, steps: 50)
    XCTAssertTrue(xs.isEmpty)
    XCTAssertTrue(ys.isEmpty)
  }

  // MARK: linspace

  func testLinspace_count() {
    let result = axes.linspace(from: 0, to: 1, count: 11)
    XCTAssertEqual(result.count, 11)
  }

  func testLinspace_endpoints() {
    let result = axes.linspace(from: 2, to: 8, count: 7)
    XCTAssertEqual(result.first!, 2.0, accuracy: 1e-12)
    XCTAssertEqual(result.last!, 8.0, accuracy: 1e-12)
  }

  func testLinspace_singleElement() {
    let result = axes.linspace(from: 3, to: 7, count: 1)
    XCTAssertEqual(result, [3.0])
  }

  func testLinspace_emptyForZeroCount() {
    let result = axes.linspace(from: 0, to: 1, count: 0)
    XCTAssertTrue(result.isEmpty)
  }
}

// MARK: - Box plot

final class BoxplotTests: XCTestCase {

  private var axes: Axes!

  override func setUp() {
    super.setUp()
    axes = makeAxes()
  }

  func testBoxplot_addsBarSeriesForEachGroup() {
    let data = [[1.0, 2, 3, 4, 5], [10.0, 20, 30, 40, 50]]
    axes.boxplot(data)
    // Each group adds 2 bar series (IQR box + median bar).
    XCTAssertEqual(axes.barSeriesList.count, 4)
  }

  func testBoxplot_defaultPositions() {
    axes.boxplot([[1.0, 2, 3], [4.0, 5, 6]])
    let positions = axes.barSeriesList.map { $0.x[0] }
    XCTAssertTrue(positions.contains(1.0))
    XCTAssertTrue(positions.contains(2.0))
  }

  func testBoxplot_customPositions() {
    axes.boxplot([[1.0, 2, 3]], positions: [5.0])
    XCTAssertEqual(axes.barSeriesList.first?.x[0], 5.0)
  }

  func testBoxplot_outlierAddedAsScatter() {
    // Single outlier well beyond 1.5*IQR.
    let data = [[1.0, 2, 3, 4, 5, 100.0]]
    axes.boxplot(data)
    XCTAssertFalse(axes.dataSeries.isEmpty)
    let outlierSeries = axes.dataSeries.filter { $0.seriesType == .scatter }
    XCTAssertFalse(outlierSeries.isEmpty)
    XCTAssertTrue(outlierSeries.flatMap { $0.y }.contains(100.0))
  }

  func testBoxplot_noOutliersWhenAllWithinFence() {
    axes.boxplot([[1.0, 2, 3, 4, 5]])
    let scatterSeries = axes.dataSeries.filter { $0.seriesType == .scatter }
    XCTAssertTrue(scatterSeries.isEmpty)
  }

  func testBoxplot_emptyGroupIsSkipped() {
    axes.boxplot([[]])
    XCTAssertTrue(axes.barSeriesList.isEmpty)
  }

  func testBoxplot_singleValueGroup() {
    axes.boxplot([[42.0]])
    // Should not crash; one group added.
    XCTAssertFalse(axes.barSeriesList.isEmpty)
  }

  func testBoxplot_whiskerLinesAdded() {
    axes.boxplot([[1.0, 2, 3, 4, 5]])
    // Two whisker fill-betweens per group.
    XCTAssertEqual(axes.fillBetweens.count, 2)
  }
}

// MARK: - Violin plot

final class ViolinplotTests: XCTestCase {

  private var axes: Axes!

  override func setUp() {
    super.setUp()
    axes = makeAxes()
  }

  func testViolinplot_addsPolygon() {
    axes.violinplot([[1.0, 2, 2, 3, 3, 3, 4, 4, 5]])
    XCTAssertFalse(axes.polygonSeries.isEmpty)
  }

  func testViolinplot_polygonHasVertices() {
    axes.violinplot([[1.0, 2, 3, 4, 5]])
    let poly = axes.polygonSeries.first!
    XCTAssertGreaterThan(poly.xs.count, 2)
    XCTAssertEqual(poly.xs.count, poly.ys.count)
  }

  func testViolinplot_showMedianAddsScatter() {
    axes.violinplot([[1.0, 2, 3]], showMedian: true)
    let scatter = axes.dataSeries.filter { $0.seriesType == .scatter }
    XCTAssertFalse(scatter.isEmpty)
  }

  func testViolinplot_noMedianScatterWhenDisabled() {
    axes.violinplot([[1.0, 2, 3]], showMedian: false)
    let scatter = axes.dataSeries.filter { $0.seriesType == .scatter }
    XCTAssertTrue(scatter.isEmpty)
  }

  func testViolinplot_multipleGroupsAddMultiplePolygons() {
    axes.violinplot([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    XCTAssertEqual(axes.polygonSeries.count, 3)
  }

  func testViolinplot_emptyGroupSkipped() {
    axes.violinplot([[]])
    XCTAssertTrue(axes.polygonSeries.isEmpty)
  }

  func testViolinplot_customPositions() {
    axes.violinplot([[1.0, 2, 3]], positions: [10.0])
    let poly = axes.polygonSeries.first!
    // Polygon x-coords should be centered near 10.
    let centerX = poly.xs.reduce(0, +) / Double(poly.xs.count)
    XCTAssertEqual(centerX, 10.0, accuracy: 1e-9)
  }
}

// MARK: - KDE plot

final class KDEplotTests: XCTestCase {

  private var axes: Axes!

  override func setUp() {
    super.setUp()
    axes = makeAxes()
  }

  func testKdeplot_addsLineSeries() {
    axes.kdeplot([1.0, 2, 3, 4, 5])
    XCTAssertEqual(axes.dataSeries.count, 1)
    XCTAssertEqual(axes.dataSeries.first?.seriesType, .line)
  }

  func testKdeplot_fillAddsFilllBetween() {
    axes.kdeplot([1.0, 2, 3], fill: true)
    XCTAssertFalse(axes.fillBetweens.isEmpty)
  }

  func testKdeplot_noFillByDefault() {
    axes.kdeplot([1.0, 2, 3], fill: false)
    XCTAssertTrue(axes.fillBetweens.isEmpty)
  }

  func testKdeplot_emptyDataDoesNothing() {
    axes.kdeplot([])
    XCTAssertTrue(axes.dataSeries.isEmpty)
  }

  func testKdeplot_labelPropagated() {
    axes.kdeplot([1.0, 2, 3], label: "density")
    XCTAssertEqual(axes.dataSeries.first?.label, "density")
  }

  func testKdeplot_customBandwidth() {
    axes.kdeplot([1.0, 2, 3], bandwidth: 2.0)
    XCTAssertEqual(axes.dataSeries.count, 1)
  }

  func testKdeplot_yValuesNonNegative() {
    axes.kdeplot([1.0, 2, 2, 3, 4])
    let ys = axes.dataSeries.first!.y
    XCTAssertTrue(ys.allSatisfy { $0 >= 0 })
  }
}

// MARK: - ECDF plot

final class ECDFplotTests: XCTestCase {

  private var axes: Axes!

  override func setUp() {
    super.setUp()
    axes = makeAxes()
  }

  func testEcdfplot_addsOneSeries() {
    axes.ecdfplot([1.0, 2, 3, 4, 5])
    XCTAssertEqual(axes.dataSeries.count, 1)
  }

  func testEcdfplot_yRangeZeroToOne() {
    axes.ecdfplot([5.0, 1, 3, 2, 4])
    let ys = axes.dataSeries.first!.y
    XCTAssertGreaterThanOrEqual(ys.min()!, 0.0)
    XCTAssertLessThanOrEqual(ys.max()!, 1.0)
  }

  func testEcdfplot_monotonicY() {
    axes.ecdfplot([3.0, 1, 4, 1, 5, 9, 2, 6])
    let ys = axes.dataSeries.first!.y
    for i in 1..<ys.count {
      XCTAssertGreaterThanOrEqual(ys[i], ys[i - 1])
    }
  }

  func testEcdfplot_xIsSortedData() {
    axes.ecdfplot([3.0, 1.0, 2.0])
    let xs = axes.dataSeries.first!.x
    // x-values should be in non-decreasing order.
    for i in 1..<xs.count {
      XCTAssertGreaterThanOrEqual(xs[i], xs[i - 1])
    }
  }

  func testEcdfplot_emptyDataDoesNothing() {
    axes.ecdfplot([])
    XCTAssertTrue(axes.dataSeries.isEmpty)
  }

  func testEcdfplot_labelPropagated() {
    axes.ecdfplot([1.0, 2.0], label: "cdf")
    XCTAssertEqual(axes.dataSeries.first?.label, "cdf")
  }
}

// MARK: - Heatmap

final class HeatmapTests: XCTestCase {

  private var axes: Axes!

  override func setUp() {
    super.setUp()
    axes = makeAxes()
  }

  func testHeatmap_addsHeatmapEntry() {
    axes.heatmap([[1.0, 2], [3.0, 4]])
    XCTAssertEqual(axes.heatmapData.count, 1)
  }

  func testHeatmap_storesCorrectDimensions() {
    let data = [[1.0, 2, 3], [4.0, 5, 6]]
    axes.heatmap(data)
    XCTAssertEqual(axes.heatmapData.first?.values.count, 2)
    XCTAssertEqual(axes.heatmapData.first?.values[0].count, 3)
  }

  func testHeatmap_vminVmaxCorrect() {
    axes.heatmap([[0.0, 5], [10.0, 3]])
    XCTAssertEqual(axes.heatmapData.first?.vmin, 0.0)
    XCTAssertEqual(axes.heatmapData.first?.vmax, 10.0)
  }

  func testHeatmap_setsXYLimits() {
    axes.heatmap([[1.0, 2, 3], [4.0, 5, 6]])
    XCTAssertEqual(axes.xLimits?.min, 0.0)
    XCTAssertEqual(axes.xLimits?.max, 3.0)
    XCTAssertEqual(axes.yLimits?.min, 0.0)
    XCTAssertEqual(axes.yLimits?.max, 2.0)
  }

  func testHeatmap_emptyDataDoesNothing() {
    axes.heatmap([])
    XCTAssertTrue(axes.heatmapData.isEmpty)
  }

  func testHeatmap_defaultPaletteIsViridis() {
    axes.heatmap([[1.0, 2], [3.0, 4]])
    XCTAssertEqual(axes.heatmapData.first?.palette.name, "viridis")
  }

  func testHeatmap_customPalette() {
    axes.heatmap([[1.0, 2], [3.0, 4]], palette: .plasma)
    XCTAssertEqual(axes.heatmapData.first?.palette.name, "plasma")
  }

  func testHeatmap_annotateFlag() {
    axes.heatmap([[1.0, 2], [3.0, 4]], annotate: true, fmt: "%.2f")
    XCTAssertTrue(axes.heatmapData.first?.annotate ?? false)
    XCTAssertEqual(axes.heatmapData.first?.fmt, "%.2f")
  }

  func testHeatmap_rendersWithoutCrash() {
    let data = [[1.0, 2, 3], [4.0, 5, 6], [7.0, 8, 9]]
    axes.heatmap(data, annotate: true)
    let ctx = DrawingContext()
    XCTAssertNoThrow(axes.render(to: ctx))
  }

  func testHeatmap_uniformDataNoCrash() {
    // All same value → vmin == vmax; span = 0, color(at: 0.5) should be used.
    axes.heatmap([[5.0, 5], [5.0, 5]])
    let ctx = DrawingContext()
    XCTAssertNoThrow(axes.render(to: ctx))
  }
}

// MARK: - Rendering smoke tests

final class StatisticalRenderTests: XCTestCase {

  private var axes: Axes!
  private var ctx: DrawingContext!

  override func setUp() {
    super.setUp()
    axes = makeAxes()
    ctx = DrawingContext()
  }

  func testBoxplotRenders() {
    axes.boxplot([[1.0, 2, 3, 4, 5, 6, 100]])
    XCTAssertNoThrow(axes.render(to: ctx))
  }

  func testViolinplotRenders() {
    axes.violinplot([[1.0, 2, 2, 3, 3, 3, 4, 5]])
    XCTAssertNoThrow(axes.render(to: ctx))
  }

  func testKDEplotRenders() {
    axes.kdeplot([1.0, 2, 3, 4, 5], fill: true)
    XCTAssertNoThrow(axes.render(to: ctx))
  }

  func testECDFplotRenders() {
    axes.ecdfplot([5.0, 3, 1, 4, 2])
    XCTAssertNoThrow(axes.render(to: ctx))
  }
}

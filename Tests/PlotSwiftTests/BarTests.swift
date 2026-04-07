//
//  BarTests.swift
//  PlotSwiftTests
//
//  Tests for bar chart and histogram extensions on Axes.
//

import XCTest

@testable import PlotSwift

// MARK: - Helpers

/// Minimal Axes stand-in that satisfies the extension requirements.
/// Replace with the real Axes once Axes.swift is available.
// swiftlint:disable:next type_body_length
final class MockAxes {
  internal var barSeriesList: [BarSeries] = []
  internal var colorCycle: ColorCycle = ColorCycle()
}

// Bind the extension methods to MockAxes so they compile independently.
extension MockAxes: AxesBarProtocol {}

// MARK: - AxesBarProtocol

/// Declares the interface that Axes+Bar.swift extends.
/// Once Axes.swift exists this protocol and MockAxes can be removed.
protocol AxesBarProtocol: AnyObject {
  var barSeriesList: [BarSeries] { get set }
  var colorCycle: ColorCycle { get }
}

extension AxesBarProtocol {
  // MARK: bar
  @discardableResult
  func bar(
    _ x: [Double], _ heights: [Double],
    width: Double = 0.8,
    bottom: [Double]? = nil,
    color: Color? = nil,
    edgeColor: Color = .black,
    edgeWidth: Double = 0.5,
    label: String? = nil
  ) -> BarSeries {
    let fill = color ?? colorCycle.next()
    let baseline = bottom ?? Array(repeating: 0, count: heights.count)
    let series = BarSeries(
      x: x, heights: heights, width: width,
      bottom: baseline, color: fill,
      edgeColor: edgeColor, edgeWidth: edgeWidth,
      label: label
    )
    barSeriesList.append(series)
    return series
  }

  // MARK: barh
  @discardableResult
  func barh(
    _ y: [Double], _ widths: [Double],
    height: Double = 0.8,
    left: [Double]? = nil,
    color: Color? = nil,
    edgeColor: Color = .black,
    edgeWidth: Double = 0.5,
    label: String? = nil
  ) -> BarSeries {
    let fill = color ?? colorCycle.next()
    let baseline = left ?? Array(repeating: 0, count: widths.count)
    let series = BarSeries(
      x: y, heights: widths, width: height,
      bottom: baseline, color: fill,
      edgeColor: edgeColor, edgeWidth: edgeWidth,
      label: label
    )
    barSeriesList.append(series)
    return series
  }

  // MARK: Histogram helpers (mirrors Axes extension)

  func clamp(_ data: [Double], to range: (Double, Double)?) -> [Double] {
    let finite = data.filter { $0.isFinite }
    guard let (lo, hi) = range else { return finite }
    return finite.filter { $0 >= lo && $0 <= hi }
  }

  func binEdges(
    for bins: HistogramBins, data: [Double], lo: Double, hi: Double
  ) -> [Double] {
    switch bins {
    case .auto:
      let k = max(1, Int(ceil(log2(Double(data.count)))) + 1)
      return equalEdges(lo: lo, hi: hi, count: k)
    case .count(let k):
      return equalEdges(lo: lo, hi: hi, count: max(1, k))
    case .edges(let e):
      return e.count >= 2 ? e.sorted() : []
    case .width(let w) where w > 0:
      var edges: [Double] = []
      var v = lo
      while v <= hi + w * 1e-10 {
        edges.append(v)
        v += w
      }
      if edges.last.map({ $0 < hi }) ?? true { edges.append(hi) }
      return edges
    default:
      return []
    }
  }

  private func equalEdges(lo: Double, hi: Double, count: Int) -> [Double] {
    let span = hi == lo ? 1.0 : hi - lo
    return (0...count).map { lo + Double($0) / Double(count) * span }
  }

  func computeCounts(data: [Double], edges: [Double]) -> [Int] {
    let binCount = edges.count - 1
    var counts = Array(repeating: 0, count: binCount)
    for v in data {
      guard v >= edges[0] && v <= edges[binCount] else { continue }
      let idx: Int
      if v == edges[binCount] {
        idx = binCount - 1
      } else {
        var lo = 0
        var hi = binCount - 1
        while lo < hi {
          let mid = (lo + hi) / 2
          if v < edges[mid + 1] { hi = mid } else { lo = mid + 1 }
        }
        idx = lo
      }
      counts[idx] += 1
    }
    return counts
  }

  func makeCumulative(_ counts: [Int]) -> [Int] {
    var result: [Int] = []
    var running = 0
    for c in counts {
      running += c
      result.append(running)
    }
    return result
  }

  func normalise(counts: [Int], edges: [Double]) -> [Double] {
    let total = Double(counts.reduce(0, +))
    guard total > 0 else { return counts.map { _ in 0.0 } }
    return zip(counts, zip(edges, edges.dropFirst())).map { count, edgePair in
      Double(count) / (total * (edgePair.1 - edgePair.0))
    }
  }
}

// MARK: - BarSeriesTests

final class BarSeriesTests: XCTestCase {

  var axes: MockAxes!

  override func setUp() {
    super.setUp()
    axes = MockAxes()
  }

  // MARK: bar()

  func testBarCreatesSeries() {
    let series = axes.bar([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])
    XCTAssertEqual(axes.barSeriesList.count, 1)
    XCTAssertEqual(series.x, [1.0, 2.0, 3.0])
    XCTAssertEqual(series.heights, [4.0, 5.0, 6.0])
  }

  func testBarDefaultWidth() {
    let series = axes.bar([0.0], [1.0])
    XCTAssertEqual(series.width, 0.8)
  }

  func testBarCustomWidth() {
    let series = axes.bar([0.0], [1.0], width: 0.5)
    XCTAssertEqual(series.width, 0.5)
  }

  func testBarDefaultBottomIsZero() {
    let series = axes.bar([1.0, 2.0], [3.0, 4.0])
    XCTAssertEqual(series.bottom, [0.0, 0.0])
  }

  func testBarBottomParameterForStacking() {
    let series = axes.bar([1.0, 2.0], [3.0, 4.0], bottom: [1.0, 2.0])
    XCTAssertEqual(series.bottom, [1.0, 2.0])
  }

  func testBarUsesColorCycleWhenColorNil() {
    let expected = ColorCycle().next()
    let series = axes.bar([0.0], [1.0])
    XCTAssertEqual(series.color, expected)
  }

  func testBarExplicitColor() {
    let series = axes.bar([0.0], [1.0], color: .red)
    XCTAssertEqual(series.color, Color.red)
  }

  func testBarLabel() {
    let series = axes.bar([0.0], [1.0], label: "A")
    XCTAssertEqual(series.label, "A")
  }

  func testBarEdgeDefaults() {
    let series = axes.bar([0.0], [1.0])
    XCTAssertEqual(series.edgeColor, .black)
    XCTAssertEqual(series.edgeWidth, 0.5)
  }

  func testBarMultipleSeriesAccumulate() {
    axes.bar([0.0], [1.0])
    axes.bar([0.0], [2.0])
    XCTAssertEqual(axes.barSeriesList.count, 2)
  }

  // MARK: barh()

  func testBarhCreatesHorizontalBars() {
    let series = axes.barh([1.0, 2.0], [3.0, 4.0])
    XCTAssertEqual(axes.barSeriesList.count, 1)
    // x stores y-centres, heights stores bar widths
    XCTAssertEqual(series.x, [1.0, 2.0])
    XCTAssertEqual(series.heights, [3.0, 4.0])
  }

  func testBarhDefaultHeight() {
    let series = axes.barh([0.0], [1.0])
    XCTAssertEqual(series.width, 0.8)
  }

  func testBarhCustomHeight() {
    let series = axes.barh([0.0], [1.0], height: 0.4)
    XCTAssertEqual(series.width, 0.4)
  }

  func testBarhDefaultLeftIsZero() {
    let series = axes.barh([1.0, 2.0], [3.0, 4.0])
    XCTAssertEqual(series.bottom, [0.0, 0.0])
  }

  func testBarhLeftParameterForStacking() {
    let series = axes.barh([1.0, 2.0], [3.0, 4.0], left: [5.0, 6.0])
    XCTAssertEqual(series.bottom, [5.0, 6.0])
  }
}

// MARK: - HistogramBinTests

final class HistogramBinTests: XCTestCase {

  var axes: MockAxes!

  override func setUp() {
    super.setUp()
    axes = MockAxes()
  }

  // MARK: binEdges helpers

  func testAutoBinsUseSturgesRule() {
    // n=8 → k = ceil(log2(8)) + 1 = 3+1 = 4
    let data = Array(repeating: 0.0, count: 8)
    let edges = axes.binEdges(for: .auto, data: data, lo: 0, hi: 8)
    XCTAssertEqual(edges.count, 5)  // 4 bins → 5 edges
  }

  func testFixedBinCount() {
    let data = [1.0, 2.0, 3.0, 4.0]
    let edges = axes.binEdges(for: .count(4), data: data, lo: 1, hi: 4)
    XCTAssertEqual(edges.count, 5)
  }

  func testExplicitEdgesPassedThrough() {
    let explicit = [0.0, 1.0, 2.0, 3.0]
    let edges = axes.binEdges(for: .edges(explicit), data: [], lo: 0, hi: 3)
    XCTAssertEqual(edges, explicit)
  }

  func testExplicitEdgesAreSorted() {
    let unsorted = [3.0, 1.0, 2.0]
    let edges = axes.binEdges(for: .edges(unsorted), data: [], lo: 1, hi: 3)
    XCTAssertEqual(edges, [1.0, 2.0, 3.0])
  }

  func testWidthBins() {
    let edges = axes.binEdges(for: .width(1.0), data: [], lo: 0, hi: 3)
    XCTAssertGreaterThanOrEqual(edges.count, 4)
    XCTAssertEqual(edges.first, 0.0)
  }

  // MARK: computeCounts

  func testCountsMatchData() {
    let edges = [0.0, 1.0, 2.0, 3.0]
    let counts = axes.computeCounts(data: [0.5, 1.5, 1.8, 2.9], edges: edges)
    XCTAssertEqual(counts, [1, 2, 1])
  }

  func testCountsOutOfRangeIgnored() {
    let edges = [0.0, 1.0, 2.0]
    let counts = axes.computeCounts(data: [-1.0, 0.5, 3.0], edges: edges)
    XCTAssertEqual(counts, [1, 0])
  }

  func testCountsUpperEdgeIncluded() {
    let edges = [0.0, 1.0, 2.0]
    let counts = axes.computeCounts(data: [2.0], edges: edges)
    XCTAssertEqual(counts, [0, 1])
  }

  // MARK: cumulative

  func testCumulativeCounts() {
    let result = axes.makeCumulative([1, 2, 3])
    XCTAssertEqual(result, [1, 3, 6])
  }

  func testCumulativeEmptyInput() {
    XCTAssertEqual(axes.makeCumulative([]), [])
  }

  // MARK: density normalisation

  func testDensityNormalisation() {
    let edges = [0.0, 1.0, 2.0]
    let counts = [2, 2]
    let density = axes.normalise(counts: counts, edges: edges)
    // each bin has width 1, total = 4, density = 2/4/1 = 0.5
    XCTAssertEqual(density[0], 0.5, accuracy: 1e-10)
    XCTAssertEqual(density[1], 0.5, accuracy: 1e-10)
  }

  func testDensityAreaSumsToOne() {
    let edges = [0.0, 1.0, 2.0, 3.0]
    let counts = [3, 1, 2]
    let density = axes.normalise(counts: counts, edges: edges)
    let area = zip(density, zip(edges, edges.dropFirst()))
      .reduce(0.0) { $0 + $1.0 * ($1.1.1 - $1.1.0) }
    XCTAssertEqual(area, 1.0, accuracy: 1e-10)
  }

  func testDensityZeroCountsReturnZero() {
    let density = axes.normalise(counts: [0, 0], edges: [0.0, 1.0, 2.0])
    XCTAssertEqual(density, [0.0, 0.0])
  }

  // MARK: clamp

  func testClampFiltersNonFinite() {
    let result = axes.clamp([1.0, Double.nan, Double.infinity, 2.0], to: nil)
    XCTAssertEqual(result, [1.0, 2.0])
  }

  func testClampAppliesRange() {
    let result = axes.clamp([0.0, 1.0, 2.0, 3.0], to: (1.0, 2.5))
    XCTAssertEqual(result, [1.0, 2.0])
  }
}

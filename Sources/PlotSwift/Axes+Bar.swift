//
//  Axes+Bar.swift
//  PlotSwift
//
//  Bar chart and histogram extensions on Axes.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - HistogramBins

/// Specifies how histogram bin edges are determined.
public enum HistogramBins: Sendable {
  /// Sturges' rule: k = ceil(log2(n)) + 1.
  case auto
  /// Fixed number of equal-width bins.
  case count(Int)
  /// Explicit bin edges; must have at least two elements.
  case edges([Double])
  /// Fixed bin width starting from the minimum data value.
  case width(Double)
}

// MARK: - BarSeries

/// Stores the data and style for a single bar or horizontal-bar series.
///
/// Returned by ``Axes/bar(_:_:width:bottom:color:edgeColor:edgeWidth:label:)``
/// and ``Axes/barh(_:_:height:left:color:edgeColor:edgeWidth:label:)``.
public struct BarSeries: Sendable {
  /// Centre x-positions (vertical bars) or y-positions (horizontal bars).
  public let x: [Double]
  /// Heights (vertical bars) or widths (horizontal bars).
  public let heights: [Double]
  /// Width of each bar (vertical) or height of each bar (horizontal).
  public let width: Double
  /// Baseline offset for each bar; enables stacking.
  public let bottom: [Double]
  /// Fill color of the bars.
  public let color: Color
  /// Edge stroke color.
  public let edgeColor: Color
  /// Edge stroke width in points.
  public let edgeWidth: Double
  /// Optional legend label.
  public let label: String?
}

// MARK: - Axes + Bar

// NOTE: Axes.swift must declare:
//   internal var barSeriesList: [BarSeries] = []
//   internal var colorCycle: ColorCycle
extension Axes {

  // MARK: Vertical bars

  /// Plots a vertical bar chart.
  ///
  /// - Parameters:
  ///   - x: Centre x-position of each bar.
  ///   - heights: Height of each bar.
  ///   - width: Bar width (default `0.8`).
  ///   - bottom: Baseline y-value per bar; pass non-nil to stack bars.
  ///   - color: Fill color; cycles automatically when `nil`.
  ///   - edgeColor: Stroke color (default `.black`).
  ///   - edgeWidth: Stroke width in points (default `0.5`).
  ///   - label: Legend label.
  /// - Returns: The created ``BarSeries``.
  @discardableResult
  public func bar(
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

  // MARK: Horizontal bars

  /// Plots a horizontal bar chart.
  ///
  /// x and heights carry the meaning "y-centres" and "bar widths" respectively
  /// so that a `BarSeries` can represent both orientations uniformly. The
  /// rendering layer is responsible for interpreting the geometry as horizontal.
  ///
  /// - Parameters:
  ///   - y: Centre y-position of each bar.
  ///   - widths: Width of each bar.
  ///   - height: Bar height (default `0.8`).
  ///   - left: Left-edge baseline per bar; pass non-nil to stack bars.
  ///   - color: Fill color; cycles automatically when `nil`.
  ///   - edgeColor: Stroke color (default `.black`).
  ///   - edgeWidth: Stroke width in points (default `0.5`).
  ///   - label: Legend label.
  /// - Returns: The created ``BarSeries``.
  @discardableResult
  public func barh(
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
}

// MARK: - Axes + Histogram

extension Axes {

  /// Plots a histogram and returns the computed bin counts and edges.
  ///
  /// - Parameters:
  ///   - data: Input values.
  ///   - bins: Binning strategy (default `.auto` — Sturges' rule).
  ///   - range: Optional `(min, max)` clamp applied before binning.
  ///   - density: When `true`, normalises counts so the area sums to 1.
  ///   - cumulative: When `true`, accumulates counts left to right.
  ///   - color: Fill color; cycles automatically when `nil`.
  ///   - edgeColor: Bar edge stroke color (default `.black`).
  ///   - alpha: Fill opacity (default `1.0`).
  ///   - label: Legend label.
  /// - Returns: A tuple of `(counts, binEdges)` where `binEdges.count == counts.count + 1`.
  @discardableResult
  public func hist(
    _ data: [Double],
    bins: HistogramBins = .auto,
    range: (Double, Double)? = nil,
    density: Bool = false,
    cumulative: Bool = false,
    color: Color? = nil,
    edgeColor: Color = .black,
    alpha: Double = 1.0,
    label: String? = nil
  ) -> (counts: [Int], binEdges: [Double]) {
    let clamped = clamp(data, to: range)
    guard !clamped.isEmpty,
      let dataMin = clamped.min(), let dataMax = clamped.max()
    else {
      return ([], [])
    }
    let edges = binEdges(for: bins, data: clamped, lo: dataMin, hi: dataMax)
    guard edges.count >= 2 else { return ([], edges) }

    var counts = computeCounts(data: clamped, edges: edges)

    if cumulative {
      counts = makeCumulative(counts)
    }

    let fill = color ?? colorCycle.next()
    let heights: [Double]
    if density {
      heights = normalise(counts: counts, edges: edges)
    } else {
      heights = counts.map { Double($0) }
    }

    let centers = zip(edges, edges.dropFirst()).map { ($0 + $1) / 2 }
    let binWidth = edges[1] - edges[0]
    bar(
      centers, heights, width: binWidth,
      color: fill.withAlpha(alpha),
      edgeColor: edgeColor, edgeWidth: 0.5,
      label: label
    )
    return (counts, edges)
  }
}

// MARK: - Histogram helpers (internal)

extension Axes {

  /// Filters data to the optional range, removing non-finite values.
  internal func clamp(_ data: [Double], to range: (Double, Double)?) -> [Double] {
    let finite = data.filter { $0.isFinite }
    guard let (lo, hi) = range else { return finite }
    return finite.filter { $0 >= lo && $0 <= hi }
  }

  /// Computes bin edges for the chosen binning strategy.
  internal func binEdges(
    for bins: HistogramBins,
    data: [Double], lo: Double, hi: Double
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

  /// Produces `count + 1` evenly-spaced edges between `lo` and `hi`.
  private func equalEdges(lo: Double, hi: Double, count: Int) -> [Double] {
    let span = hi == lo ? 1.0 : hi - lo
    return (0...count).map { lo + Double($0) / Double(count) * span }
  }

  /// Tallies values into bins defined by `edges`.
  internal func computeCounts(data: [Double], edges: [Double]) -> [Int] {
    let binCount = edges.count - 1
    var counts = Array(repeating: 0, count: binCount)
    for v in data {
      if let idx = binIndex(for: v, edges: edges, binCount: binCount) {
        counts[idx] += 1
      }
    }
    return counts
  }

  /// Returns the bin index for value `v`, or `nil` when out of range.
  private func binIndex(for v: Double, edges: [Double], binCount: Int) -> Int? {
    guard v >= edges[0] && v <= edges[binCount] else { return nil }
    if v == edges[binCount] { return binCount - 1 }
    var lo = 0
    var hi = binCount - 1
    while lo < hi {
      let mid = (lo + hi) / 2
      if v < edges[mid + 1] { hi = mid } else { lo = mid + 1 }
    }
    return lo
  }

  /// Converts counts to a cumulative sequence.
  internal func makeCumulative(_ counts: [Int]) -> [Int] {
    var result: [Int] = []
    result.reserveCapacity(counts.count)
    var running = 0
    for c in counts {
      running += c
      result.append(running)
    }
    return result
  }

  /// Normalises counts to probability density (area sums to 1).
  internal func normalise(counts: [Int], edges: [Double]) -> [Double] {
    let total = Double(counts.reduce(0, +))
    guard total > 0 else { return counts.map { _ in 0.0 } }
    return zip(counts, zip(edges, edges.dropFirst())).map { count, edgePair in
      Double(count) / (total * (edgePair.1 - edgePair.0))
    }
  }
}

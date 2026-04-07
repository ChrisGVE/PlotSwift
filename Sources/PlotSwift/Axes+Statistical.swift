//
//  Axes+Statistical.swift
//  PlotSwift
//
//  Statistical plot extensions on Axes: box plot, violin plot, KDE, ECDF, heatmap.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - HeatmapData

/// Stores the data and style for a single heatmap.
public struct HeatmapData: Sendable {
  /// Row-major 2D array; rows are y-axis, columns are x-axis.
  public let values: [[Double]]
  /// Color palette for mapping scalar values to color.
  public let palette: ColorPalette
  /// Whether to draw cell value text annotations.
  public let annotate: Bool
  /// Format string for cell annotations (e.g. `"%.1f"`).
  public let fmt: String
  /// Minimum value (maps to palette start).
  public let vmin: Double
  /// Maximum value (maps to palette end).
  public let vmax: Double
}

// MARK: - Axes + Statistical

extension Axes {

  // MARK: Box plot

  /// Draws box plots for one or more datasets.
  ///
  /// Each box spans Q1 to Q3, with a median line. Whiskers extend to 1.5 × IQR
  /// (clamped to actual data). Points beyond the whiskers are drawn as outliers.
  ///
  /// - Parameters:
  ///   - data: One array per group.
  ///   - positions: Centre x-positions; defaults to 1, 2, 3, …
  ///   - widths: Box width as a fraction of the inter-position spacing (default `0.5`).
  ///   - color: Fill color; cycles automatically when `nil`.
  ///   - labels: Legend labels per group.
  public func boxplot(
    _ data: [[Double]],
    positions: [Double]? = nil,
    widths: Double = 0.5,
    color: Color? = nil,
    labels: [String]? = nil
  ) {
    let pos = positions ?? data.indices.map { Double($0 + 1) }
    for (idx, group) in data.enumerated() {
      guard !group.isEmpty, idx < pos.count else { continue }
      let fill = color ?? colorCycle.next()
      let x = pos[idx]
      let label = labels.flatMap { $0.indices.contains(idx) ? $0[idx] : nil }
      drawBox(group: group, x: x, width: widths, color: fill, label: label)
    }
  }

  // MARK: Violin plot

  /// Draws violin plots (KDE mirrored around the position axis).
  ///
  /// - Parameters:
  ///   - data: One array per group.
  ///   - positions: Centre x-positions; defaults to 1, 2, 3, …
  ///   - widths: Half-width scale for the violin (default `0.8`).
  ///   - color: Fill color; cycles automatically when `nil`.
  ///   - showMedian: When `true`, draws a dot at the median (default `true`).
  public func violinplot(
    _ data: [[Double]],
    positions: [Double]? = nil,
    widths: Double = 0.8,
    color: Color? = nil,
    showMedian: Bool = true
  ) {
    let pos = positions ?? data.indices.map { Double($0 + 1) }
    for (idx, group) in data.enumerated() {
      guard !group.isEmpty, idx < pos.count else { continue }
      let fill = color ?? colorCycle.next()
      let x = pos[idx]
      drawViolin(group: group, x: x, halfWidth: widths / 2, color: fill, showMedian: showMedian)
    }
  }

  // MARK: KDE plot

  /// Plots a Kernel Density Estimate using a Gaussian kernel.
  ///
  /// Bandwidth defaults to Silverman's rule: h = 1.06 · σ · n^(−1/5).
  ///
  /// - Parameters:
  ///   - data: Input sample values.
  ///   - bandwidth: Smoothing bandwidth; `nil` uses Silverman's rule.
  ///   - color: Line color; cycles automatically when `nil`.
  ///   - fill: When `true`, shades the area under the curve.
  ///   - alpha: Opacity of the fill (default `0.3`).
  ///   - label: Legend label.
  public func kdeplot(
    _ data: [Double],
    bandwidth: Double? = nil,
    color: Color? = nil,
    fill: Bool = false,
    alpha: Double = 0.3,
    label: String? = nil
  ) {
    guard !data.isEmpty else { return }
    let c = color ?? colorCycle.next()
    let h = bandwidth ?? silvermanBandwidth(data)
    guard h > 0 else { return }
    let (xs, ys) = gaussianKDE(data: data, bandwidth: h, steps: 200)
    plot(xs, ys, color: c, lineStyle: .solid, lineWidth: 1.5, label: label)
    if fill {
      let fb = FillBetween(
        x: xs, y1: ys, y2: Array(repeating: 0, count: xs.count),
        color: c, alpha: alpha)
      fillBetweens.append(fb)
    }
  }

  // MARK: ECDF plot

  /// Plots the Empirical Cumulative Distribution Function as a step function.
  ///
  /// - Parameters:
  ///   - data: Input sample values.
  ///   - color: Line color; cycles automatically when `nil`.
  ///   - label: Legend label.
  public func ecdfplot(
    _ data: [Double],
    color: Color? = nil,
    label: String? = nil
  ) {
    guard !data.isEmpty else { return }
    let c = color ?? colorCycle.next()
    let sorted = data.sorted()
    let n = Double(sorted.count)
    var xs: [Double] = []
    var ys: [Double] = []
    // Emit two points per step to produce a proper step function.
    for (i, v) in sorted.enumerated() {
      let cdf = Double(i) / n
      xs.append(v)
      ys.append(cdf)
      xs.append(v)
      ys.append(Double(i + 1) / n)
    }
    plot(xs, ys, color: c, lineStyle: .solid, lineWidth: 1.5, label: label)
  }

  // MARK: Heatmap

  /// Draws a heatmap, mapping each cell value to a palette color.
  ///
  /// - Parameters:
  ///   - data: Row-major 2D array; `data[row][col]` is at `(col, nRows - 1 - row)`.
  ///   - palette: Palette for scalar-to-color mapping (default `.viridis`).
  ///   - annotate: When `true`, renders each cell's numeric value.
  ///   - fmt: `String(format:)` format string for cell annotations (default `"%.1f"`).
  public func heatmap(
    _ data: [[Double]],
    palette: ColorPalette = .viridis,
    annotate: Bool = false,
    fmt: String = "%.1f"
  ) {
    guard !data.isEmpty else { return }
    let flat = data.flatMap { $0 }
    guard let vmin = flat.min(), let vmax = flat.max() else { return }
    let entry = HeatmapData(
      values: data, palette: palette,
      annotate: annotate, fmt: fmt,
      vmin: vmin, vmax: vmax)
    heatmapData.append(entry)
    // Set axis limits to the cell grid dimensions.
    let nRows = Double(data.count)
    let nCols = Double(data[0].count)
    setXLim(0, nCols)
    setYLim(0, nRows)
  }
}

// MARK: - Statistical helpers (internal)

extension Axes {

  /// Draws one box plot for a single group at position `x`.
  internal func drawBox(
    group: [Double], x: Double, width: Double, color: Color, label: String?
  ) {
    let sorted = group.sorted()
    let (q1, med, q3) = quartiles(sorted)
    let iqr = q3 - q1
    let loFence = q1 - 1.5 * iqr
    let hiFence = q3 + 1.5 * iqr
    let whiskerLo = sorted.first(where: { $0 >= loFence }) ?? q1
    let whiskerHi = sorted.last(where: { $0 <= hiFence }) ?? q3
    let outliers = sorted.filter { $0 < loFence || $0 > hiFence }

    // IQR box (height = q3 - q1, baseline = q1)
    bar(
      [x], [q3 - q1], width: width,
      bottom: [q1], color: color.withAlpha(0.6),
      edgeColor: color, edgeWidth: 1.0, label: label)

    // Median line as a narrow contrasting bar
    bar(
      [x], [0.02 * (q3 - q1 + 1e-9)], width: width,
      bottom: [med - 0.01 * (q3 - q1 + 1e-9)],
      color: .black, edgeColor: .black, edgeWidth: 0)

    // Whisker lines via fill-betweens (zero-width polygon = vertical line)
    let half = width * 0.1
    appendWhiskerLine(x: x, half: half, y0: q1, y1: whiskerLo)
    appendWhiskerLine(x: x, half: half, y0: q3, y1: whiskerHi)

    // Outlier scatter
    if !outliers.isEmpty {
      let xs = Array(repeating: x, count: outliers.count)
      scatter(xs, outliers, color: color, marker: .circle, markerSize: 4)
    }
  }

  /// Appends a vertical whisker line as a thin `FillBetween` polygon.
  private func appendWhiskerLine(x: Double, half: Double, y0: Double, y1: Double) {
    let xs = [x - half, x + half, x + half, x - half]
    let tops = [y1, y1, y1, y1]
    let bots = [y0, y0, y0, y0]
    fillBetweens.append(FillBetween(
      x: xs, y1: tops, y2: bots,
      color: .black, alpha: 1.0, edgeColor: .black, edgeWidth: 1.0))
  }

  /// Draws one violin at `x` using a Gaussian KDE mirrored around the position axis.
  internal func drawViolin(
    group: [Double], x: Double, halfWidth: Double, color: Color, showMedian: Bool
  ) {
    let h = silvermanBandwidth(group)
    guard h > 0 else { return }
    let (evalYs, densities) = gaussianKDE(data: group, bandwidth: h, steps: 100)
    guard let maxDensity = densities.max(), maxDensity > 0 else { return }
    let scale = halfWidth / maxDensity

    // Right side (bottom to top), then left side (top to bottom) — closed polygon.
    // polyX: x-coords (data horizontal axis), polyY: data values (vertical axis).
    let rightXs = densities.map { x + $0 * scale }
    let leftXs  = densities.reversed().map { x - $0 * scale }
    let polyX = rightXs + leftXs
    let polyY = evalYs + evalYs.reversed()

    polygonSeries.append(PolygonSeries(
      xs: polyX, ys: polyY,
      fillColor: color, alpha: 0.6,
      edgeColor: color, edgeWidth: 1.0))

    if showMedian {
      let sorted = group.sorted()
      let (_, med, _) = quartiles(sorted)
      scatter([x], [med], color: .white, marker: .circle, markerSize: 5)
    }
  }

  // MARK: Statistical math

  /// Returns (Q1, median, Q3) for a pre-sorted array.
  internal func quartiles(_ sorted: [Double]) -> (q1: Double, median: Double, q3: Double) {
    let n = sorted.count
    guard n > 0 else { return (0, 0, 0) }
    let med = percentile(sorted, 0.5)
    let q1 = percentile(sorted, 0.25)
    let q3 = percentile(sorted, 0.75)
    return (q1, med, q3)
  }

  /// Linear interpolation percentile on a pre-sorted array.
  internal func percentile(_ sorted: [Double], _ p: Double) -> Double {
    let n = sorted.count
    guard n > 1 else { return sorted[0] }
    let index = p * Double(n - 1)
    let lo = Int(index)
    let hi = min(lo + 1, n - 1)
    let frac = index - Double(lo)
    return sorted[lo] + frac * (sorted[hi] - sorted[lo])
  }

  /// Silverman's rule of thumb: h = 1.06 · σ · n^(−1/5).
  internal func silvermanBandwidth(_ data: [Double]) -> Double {
    let n = data.count
    guard n > 1 else { return 1 }
    let mean = data.reduce(0, +) / Double(n)
    let variance = data.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(n - 1)
    let std = variance.squareRoot()
    guard std > 0 else { return 1 }
    return 1.06 * std * pow(Double(n), -0.2)
  }

  /// Evaluates a Gaussian KDE over `steps` evenly-spaced points.
  /// - Returns: `(xs, densities)` where `xs.count == steps`.
  internal func gaussianKDE(
    data: [Double], bandwidth h: Double, steps: Int
  ) -> (xs: [Double], ys: [Double]) {
    guard !data.isEmpty, h > 0, steps > 1 else { return ([], []) }
    let lo = data.min()! - 3 * h
    let hi = data.max()! + 3 * h
    let xs = linspace(from: lo, to: hi, count: steps)
    let inv2h2 = 1 / (2 * h * h)
    let norm = 1 / (h * (2 * Double.pi).squareRoot() * Double(data.count))
    let ys = xs.map { x -> Double in
      data.reduce(0) { $0 + exp(-((x - $1) * (x - $1)) * inv2h2) } * norm
    }
    return (xs, ys)
  }

  /// Returns `count` evenly-spaced values in `[from, to]`.
  internal func linspace(from lo: Double, to hi: Double, count: Int) -> [Double] {
    guard count > 1 else { return count == 1 ? [lo] : [] }
    let step = (hi - lo) / Double(count - 1)
    return (0..<count).map { lo + Double($0) * step }
  }
}

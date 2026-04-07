//
//  Axes+SeabornPlots.swift
//  PlotSwift
//
//  Seaborn-style and remaining plot type extensions on Axes: point plot,
//  count plot, lineplot with hue/style, scatterplot with hue/size,
//  quiver, and streamplot.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - Axes + SeabornPlots

extension Axes {

  // MARK: Point plot

  /// Draws markers at category means with 95% confidence interval lines.
  ///
  /// For each category in `x`, the corresponding slice of `y` provides the
  /// sample values. A marker is drawn at the sample mean and an error bar
  /// spanning the 95% CI is drawn through it.
  ///
  /// - Parameters:
  ///   - x: Category labels, one per group in `y`.
  ///   - y: One array of values per category.
  ///   - color: Color for markers and CI lines; cycles when `nil`.
  ///   - markers: Per-category marker shapes; uses `.circle` when `nil`.
  ///   - label: Legend label applied to the first series.
  public func pointplot(
    _ x: [String],
    _ y: [[Double]],
    color: Color? = nil,
    markers: [MarkerStyle]? = nil,
    label: String? = nil
  ) {
    guard !x.isEmpty, x.count == y.count else { return }
    let c = color ?? colorCycle.next()
    let positions = x.indices.map { Double($0 + 1) }

    // Connect means with a line.
    let means = y.map { meanOf($0) }
    plot(positions, means, color: c, lineStyle: .solid, lineWidth: 1.5,
         label: label)

    for (idx, group) in y.enumerated() {
      guard !group.isEmpty else { continue }
      let pos = positions[idx]
      let marker = (markers != nil && idx < markers!.count) ? markers![idx] : MarkerStyle.circle
      let mean = means[idx]
      let (lo, hi) = confidenceInterval95(group)

      scatter([pos], [mean], color: c, marker: marker, markerSize: 8)
      errorbar(
        [pos], [mean],
        yerr: .asymmetric([mean - lo], [hi - mean]),
        color: c, lineStyle: .none, lineWidth: 1.5, capsize: 4, marker: .none)
    }
  }

  // MARK: Count plot

  /// Draws a bar chart showing the frequency of each category.
  ///
  /// - Parameters:
  ///   - categories: Category labels for each observation (may repeat).
  ///   - color: Bar fill color; cycles automatically when `nil`.
  public func countplot(_ categories: [String], color: Color? = nil) {
    guard !categories.isEmpty else { return }
    let c = color ?? colorCycle.next()

    // Preserve insertion order for consistent bar positions.
    var seen: [String: Int] = [:]
    var orderedKeys: [String] = []
    for cat in categories {
      if seen[cat] == nil {
        seen[cat] = 0
        orderedKeys.append(cat)
      }
      seen[cat]! += 1
    }

    let positions = orderedKeys.indices.map { Double($0 + 1) }
    let counts = orderedKeys.map { Double(seen[$0] ?? 0) }
    bar(positions, counts, width: 0.8, color: c)
  }

  // MARK: Seaborn lineplot

  /// Plots a line with optional hue and style grouping.
  ///
  /// When `hue` is provided the data is split into groups; each group
  /// receives a distinct color from the cycle. When `style` is provided,
  /// groups are additionally distinguished by line dash style.
  ///
  /// - Parameters:
  ///   - x: X-coordinate values.
  ///   - y: Y-coordinate values.
  ///   - hue: Optional group label per observation.
  ///   - style: Optional style label per observation (mapped to dash styles).
  ///   - label: Legend label used when no hue grouping is applied.
  public func lineplot(
    _ x: [Double],
    _ y: [Double],
    hue: [String]? = nil,
    style: [String]? = nil,
    label: String? = nil
  ) {
    guard !x.isEmpty, x.count == y.count else { return }
    guard let hue else {
      plot(x, y, lineStyle: .solid, lineWidth: 1.5, label: label)
      return
    }

    let lineStyles: [LineStyle] = [.solid, .dashed, .dotted, .dashDot]
    let groups = groupIndices(by: hue, count: x.count)
    let styleGroups = style.map { groupIndices(by: $0, count: x.count) }

    for (groupIdx, (key, indices)) in groups.enumerated() {
      let c = colorCycle.next()
      let gx = indices.map { x[$0] }
      let gy = indices.map { y[$0] }
      let ls = resolveLineStyle(
        for: key, groupIdx: groupIdx,
        styleGroups: styleGroups, lineStyles: lineStyles)
      plot(gx, gy, color: c, lineStyle: ls, lineWidth: 1.5, label: key)
    }
  }

  // MARK: Seaborn scatterplot

  /// Plots a scatter with optional hue and size grouping.
  ///
  /// When `hue` is provided each group gets a distinct color. When `size`
  /// is provided, marker sizes are scaled proportionally within [4, 12].
  ///
  /// - Parameters:
  ///   - x: X-coordinate values.
  ///   - y: Y-coordinate values.
  ///   - hue: Optional group label per observation.
  ///   - size: Optional per-point size scalar (relative scale).
  ///   - label: Legend label used when no hue grouping is applied.
  public func scatterplot(
    _ x: [Double],
    _ y: [Double],
    hue: [String]? = nil,
    size: [Double]? = nil,
    label: String? = nil
  ) {
    guard !x.isEmpty, x.count == y.count else { return }
    guard let hue else {
      let sizes = size.map { scaledSizes($0) }
      plotScatterWithSizes(x, y, sizes: sizes, color: nil, label: label)
      return
    }

    let groups = groupIndices(by: hue, count: x.count)
    for (key, indices) in groups {
      let c = colorCycle.next()
      let gx = indices.map { x[$0] }
      let gy = indices.map { y[$0] }
      let sz: [Double]? = size.map { s in indices.map { scaledSize(s[$0], all: s) } }
      plotScatterWithSizes(gx, gy, sizes: sz, color: c, label: key)
    }
  }

}

// MARK: - Internal math helpers

extension Axes {

  /// Returns the arithmetic mean of a non-empty array.
  internal func meanOf(_ values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    return values.reduce(0, +) / Double(values.count)
  }

  /// Returns (lowerBound, upperBound) for the 95% CI.
  internal func confidenceInterval95(_ values: [Double]) -> (Double, Double) {
    let n = values.count
    guard n > 1 else { let v = values.first ?? 0; return (v, v) }
    let mean = meanOf(values)
    let variance = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(n - 1)
    let se = (variance / Double(n)).squareRoot()
    let t: Double = n >= 30 ? 1.96 : (n >= 10 ? 2.0 : 2.571)
    return (mean - t * se, mean + t * se)
  }

  /// Groups array indices by the string label at each position.
  internal func groupIndices(by labels: [String], count: Int) -> [(String, [Int])] {
    var map: [String: [Int]] = [:]
    var order: [String] = []
    for i in 0..<min(labels.count, count) {
      let key = labels[i]
      if map[key] == nil { order.append(key) }
      map[key, default: []].append(i)
    }
    return order.map { ($0, map[$0]!) }
  }

  /// Scales an array of size values into the range [4, 12] points.
  internal func scaledSizes(_ sizes: [Double]) -> [Double] {
    guard let lo = sizes.min(), let hi = sizes.max(), hi > lo else {
      return Array(repeating: 6, count: sizes.count)
    }
    return sizes.map { 4 + ($0 - lo) / (hi - lo) * 8 }
  }

  /// Scales a single size value relative to all values in the same array.
  internal func scaledSize(_ value: Double, all: [Double]) -> Double {
    guard let lo = all.min(), let hi = all.max(), hi > lo else { return 6 }
    return 4 + (value - lo) / (hi - lo) * 8
  }

  /// Resolves the line style for a hue group, optionally keyed by a style group.
  internal func resolveLineStyle(
    for key: String,
    groupIdx: Int,
    styleGroups: [(String, [Int])]?,
    lineStyles: [LineStyle]
  ) -> LineStyle {
    guard let styleGroups else { return lineStyles[groupIdx % lineStyles.count] }
    let styleIdx = styleGroups.firstIndex(where: { $0.0 == key }) ?? groupIdx
    return lineStyles[styleIdx % lineStyles.count]
  }

  /// Plots a scatter series, optionally assigning a per-point marker size.
  ///
  /// When `sizes` is `nil`, the default marker size is used. When provided,
  /// each point is drawn individually at its scaled size.
  internal func plotScatterWithSizes(
    _ x: [Double],
    _ y: [Double],
    sizes: [Double]?,
    color: Color?,
    label: String?
  ) {
    guard !x.isEmpty else { return }
    guard let sizes else {
      scatter(x, y, color: color, label: label)
      return
    }
    let c = color ?? colorCycle.next()
    for i in 0..<min(x.count, sizes.count) {
      let lbl = i == 0 ? label : nil
      scatter([x[i]], [y[i]], color: c, markerSize: sizes[i], label: lbl)
    }
  }
}

// MARK: - Axes + Vector field plots

extension Axes {

  // MARK: Quiver plot

  /// Draws a vector field using arrows from `(x,y)` pointing in the `(u,v)` direction.
  ///
  /// - Parameters:
  ///   - x: X-origins of the arrows.
  ///   - y: Y-origins of the arrows.
  ///   - u: X-components of the direction vectors.
  ///   - v: Y-components of the direction vectors.
  ///   - color: Arrow color; cycles automatically when `nil`.
  ///   - scale: Multiplier applied to vector magnitudes (default `1.0`).
  public func quiver(
    _ x: [Double],
    _ y: [Double],
    _ u: [Double],
    _ v: [Double],
    color: Color? = nil,
    scale: Double = 1.0
  ) {
    guard !x.isEmpty,
      x.count == y.count, x.count == u.count, x.count == v.count
    else { return }
    let c = color ?? colorCycle.next()
    for i in x.indices {
      let x1 = x[i] + u[i] * scale
      let y1 = y[i] + v[i] * scale
      plot([x[i], x1], [y[i], y1], color: c, lineStyle: .solid, lineWidth: 1.0)
      for seg in quiverArrowhead(from: (x[i], y[i]), to: (x1, y1)) {
        plot(seg.0, seg.1, color: c, lineStyle: .solid, lineWidth: 1.0)
      }
    }
  }

  // MARK: Streamplot

  /// Draws a simplified streamplot following a 2D vector field.
  ///
  /// Seeds are placed on a regular grid controlled by `density`, then lines
  /// are integrated forward using Euler steps until they exit the domain.
  ///
  /// - Parameters:
  ///   - x: 1D x-axis positions (sorted ascending).
  ///   - y: 1D y-axis positions (sorted ascending).
  ///   - u: 2D `u[yi][xi]` x-velocity components.
  ///   - v: 2D `v[yi][xi]` y-velocity components.
  ///   - color: Line color; cycles automatically when `nil`.
  ///   - density: Relative seed density (default `1.0`).
  public func streamplot(
    _ x: [Double],
    _ y: [Double],
    _ u: [[Double]],
    _ v: [[Double]],
    color: Color? = nil,
    density: Double = 1.0
  ) {
    guard !x.isEmpty, !y.isEmpty,
      u.count == y.count, v.count == y.count
    else { return }
    let c = color ?? colorCycle.next()
    let step = streamStepSize(x: x, y: y)
    for seed in streamSeeds(x: x, y: y, density: density) {
      var (px, py) = seed
      var lx: [Double] = [px], ly: [Double] = [py]
      for _ in 0..<100 {
        guard let (uf, vf) = streamInterpolate(
          px: px, py: py, x: x, y: y, u: u, v: v) else { break }
        let mag = (uf * uf + vf * vf).squareRoot()
        guard mag > 1e-12 else { break }
        px += (uf / mag) * step; py += (vf / mag) * step
        lx.append(px); ly.append(py)
        if px < x[0] || px > x[x.count - 1] { break }
        if py < y[0] || py > y[y.count - 1] { break }
      }
      if lx.count >= 2 { plot(lx, ly, color: c, lineStyle: .solid, lineWidth: 1.0) }
    }
  }
}

// MARK: - Vector field helpers (internal)

extension Axes {

  /// Returns two arrowhead barb segments terminating at `to`.
  internal func quiverArrowhead(
    from tail: (Double, Double),
    to tip: (Double, Double),
    length: Double = 0.12
  ) -> [([Double], [Double])] {
    let dx = tip.0 - tail.0, dy = tip.1 - tail.1
    let mag = (dx * dx + dy * dy).squareRoot()
    guard mag > 1e-12 else { return [] }
    let ux = dx / mag, uy = dy / mag
    let ca = cos(Double.pi / 6), sa = sin(Double.pi / 6)
    let lx = tip.0 - length * (ux * ca - uy * sa)
    let ly = tip.1 - length * (uy * ca + ux * sa)
    let rx = tip.0 - length * (ux * ca + uy * sa)
    let ry = tip.1 - length * (uy * ca - ux * sa)
    return [([tip.0, lx], [tip.1, ly]), ([tip.0, rx], [tip.1, ry])]
  }

  /// Generates seed positions on a regular grid for stream integration.
  internal func streamSeeds(
    x: [Double], y: [Double], density: Double
  ) -> [(Double, Double)] {
    let d = max(0.1, density)
    let nx = max(2, Int((Double(x.count) * d * 0.5).rounded()))
    let ny = max(2, Int((Double(y.count) * d * 0.5).rounded()))
    var seeds: [(Double, Double)] = []
    for i in 0..<nx {
      for j in 0..<ny {
        let sx = x[0] + Double(i) / Double(nx - 1) * (x[x.count - 1] - x[0])
        let sy = y[0] + Double(j) / Double(ny - 1) * (y[y.count - 1] - y[0])
        seeds.append((sx, sy))
      }
    }
    return seeds
  }

  /// Step size for stream integration (~1% of the smaller domain span).
  internal func streamStepSize(x: [Double], y: [Double]) -> Double {
    let xSpan = abs((x.last ?? 1) - (x.first ?? 0))
    let ySpan = abs((y.last ?? 1) - (y.first ?? 0))
    return min(xSpan, ySpan) * 0.01
  }

  /// Bilinear interpolation of the vector field at `(px, py)`.
  internal func streamInterpolate(
    px: Double, py: Double,
    x: [Double], y: [Double],
    u: [[Double]], v: [[Double]]
  ) -> (Double, Double)? {
    guard let xi = streamBisect(px, in: x),
      let yi = streamBisect(py, in: y),
      yi + 1 < u.count, xi + 1 < u[yi].count,
      xi + 1 < u[yi + 1].count
    else { return nil }
    let tx = (px - x[xi]) / (x[xi + 1] - x[xi])
    let ty = (py - y[yi]) / (y[yi + 1] - y[yi])
    let uf = streamBilerp(u[yi][xi], u[yi][xi + 1],
                          u[yi + 1][xi], u[yi + 1][xi + 1], tx: tx, ty: ty)
    let vf = streamBilerp(v[yi][xi], v[yi][xi + 1],
                          v[yi + 1][xi], v[yi + 1][xi + 1], tx: tx, ty: ty)
    return (uf, vf)
  }

  /// Returns the largest index `i` where `sorted[i] <= value < sorted[i+1]`.
  internal func streamBisect(_ value: Double, in sorted: [Double]) -> Int? {
    guard sorted.count >= 2,
      value >= sorted[0], value <= sorted[sorted.count - 1]
    else { return nil }
    var lo = 0, hi = sorted.count - 2
    while lo < hi {
      let mid = (lo + hi + 1) / 2
      if sorted[mid] <= value { lo = mid } else { hi = mid - 1 }
    }
    return lo
  }

  /// Bilinear interpolation over four corner values.
  internal func streamBilerp(
    _ v00: Double, _ v10: Double, _ v01: Double, _ v11: Double,
    tx: Double, ty: Double
  ) -> Double {
    let bot = v00 + (v10 - v00) * tx
    let top = v01 + (v11 - v01) * tx
    return bot + (top - bot) * ty
  }
}

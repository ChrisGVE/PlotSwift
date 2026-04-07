//
//  Axes+Image.swift
//  PlotSwift
//
//  2D data visualization: imshow, pcolormesh, contour helpers.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - Image-like plot types

extension Axes {

  /// Displays a 2D array as a colored image.
  ///
  /// Each element of `data` maps to a cell colored by the palette. Row 0 is rendered
  /// at the top of the plot area (matching matplotlib's default `origin='upper'`).
  ///
  /// - Parameters:
  ///   - data: A 2D array of Double values (rows of columns).
  ///   - palette: Color palette for mapping values (default: `.viridis`).
  ///   - vmin: Minimum value for color mapping (nil = data minimum).
  ///   - vmax: Maximum value for color mapping (nil = data maximum).
  ///   - interpolation: Reserved for future use.
  public func imshow(
    _ data: [[Double]],
    palette: ColorPalette = .viridis,
    vmin: Double? = nil,
    vmax: Double? = nil,
    interpolation _: String = "nearest"
  ) {
    guard !data.isEmpty, !data[0].isEmpty else { return }
    let rows = data.count
    let cols = data[0].count

    let allValues = data.flatMap { $0 }.filter { $0.isFinite }
    let lo = vmin ?? (allValues.min() ?? 0)
    let hi = vmax ?? (allValues.max() ?? 1)
    let span = hi == lo ? 1.0 : hi - lo

    setXLim(0, Double(cols))
    setYLim(0, Double(rows))

    for r in 0..<rows {
      for c in 0..<min(cols, data[r].count) {
        let t = (data[r][c] - lo) / span
        let color = palette.color(at: min(max(t, 0), 1))
        let yFlipped = Double(rows - 1 - r)
        addImageCell(
          x: Double(c), y: yFlipped, width: 1, height: 1, color: color)
      }
    }
  }

  /// Displays a pseudocolor mesh from 2D data with explicit grid coordinates.
  ///
  /// - Parameters:
  ///   - x: Column edge coordinates (length = cols + 1).
  ///   - y: Row edge coordinates (length = rows + 1).
  ///   - data: 2D values array (rows x cols).
  ///   - palette: Color palette for mapping.
  ///   - vmin: Minimum for color scale.
  ///   - vmax: Maximum for color scale.
  public func pcolormesh(
    x: [Double], y: [Double], _ data: [[Double]],
    palette: ColorPalette = .viridis,
    vmin: Double? = nil, vmax: Double? = nil
  ) {
    guard !data.isEmpty, !data[0].isEmpty else { return }
    let rows = data.count
    let cols = data[0].count
    guard x.count >= cols + 1, y.count >= rows + 1 else { return }

    let allValues = data.flatMap { $0 }.filter { $0.isFinite }
    let lo = vmin ?? (allValues.min() ?? 0)
    let hi = vmax ?? (allValues.max() ?? 1)
    let span = hi == lo ? 1.0 : hi - lo

    for r in 0..<rows {
      for c in 0..<min(cols, data[r].count) {
        let t = (data[r][c] - lo) / span
        let color = palette.color(at: min(max(t, 0), 1))
        let cellX = x[c]
        let cellY = y[r]
        let cellW = x[c + 1] - x[c]
        let cellH = y[r + 1] - y[r]
        addImageCell(x: cellX, y: cellY, width: cellW, height: cellH, color: color)
      }
    }
  }

  /// Adds a single colored rectangle to internal storage for image-like rendering.
  internal func addImageCell(
    x: Double, y: Double, width: Double, height: Double, color: Color
  ) {
    let series = DataSeries(
      x: [x, x + width], y: [y, y + height],
      color: color, lineStyle: .none, marker: .none,
      lineWidth: 0, markerSize: 0, seriesType: .bar)
    dataSeries.append(series)

    barSeriesList.append(BarSeries(
      x: [x + width / 2], heights: [height], width: width,
      bottom: [y], color: color, edgeColor: color, edgeWidth: 0, label: nil))
  }
}

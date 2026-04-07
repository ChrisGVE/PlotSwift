//
//  Axes+MorePlots.swift
//  PlotSwift
//
//  Additional plot type extensions on Axes: step, stem, stackplot,
//  twinx, and eventplot.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - Supporting enums

/// Placement of the step transition relative to the data point.
public enum StepPlacement: Sendable {
  /// Step occurs before each point (step rises at x[i], flat until x[i+1]).
  case pre
  /// Step occurs after each point (flat from x[i], then rises at x[i+1]).
  case post
  /// Step occurs at the midpoint between consecutive x values.
  case mid
}

/// Orientation for event markers in an event plot.
public enum EventOrientation: Sendable {
  /// Events drawn as vertical lines on a horizontal axis.
  case horizontal
  /// Events drawn as horizontal lines on a vertical axis.
  case vertical
}

// MARK: - Step, Stem, Stackplot, Twinx, Eventplot

extension Axes {

  // MARK: Step plot

  /// Adds a step-wise line series to the axes.
  ///
  /// Converts the input coordinates into staircase-style segments
  /// before delegating to ``plot(_:_:color:lineStyle:lineWidth:marker:markerSize:label:)``.
  ///
  /// - Parameters:
  ///   - x: X-coordinate values.
  ///   - y: Y-coordinate values.
  ///   - where: Where each step transition occurs (default: `.pre`).
  ///   - color: Line color; cycles automatically when `nil`.
  ///   - lineWidth: Stroke width in points.
  ///   - label: Legend label.
  /// - Returns: The created ``DataSeries`` (discardable).
  @discardableResult
  public func step(
    _ x: [Double],
    _ y: [Double],
    where placement: StepPlacement = .pre,
    color: Color? = nil,
    lineWidth: Double = 1.5,
    label: String? = nil
  ) -> DataSeries {
    let (sx, sy) = makeStepCoordinates(x, y, placement: placement)
    return plot(sx, sy, color: color, lineWidth: lineWidth, label: label)
  }

  // MARK: Stem plot

  /// Adds a stem plot: vertical lines from a baseline to each data point,
  /// with a marker at the tip.
  ///
  /// - Parameters:
  ///   - x: X-coordinate values.
  ///   - y: Y-coordinate values.
  ///   - baseline: Y value for the base of each stem (default: `0`).
  ///   - color: Color for stems and markers; cycles automatically when `nil`.
  ///   - marker: Marker shape drawn at each tip (default: `.circle`).
  ///   - label: Legend label applied to the tip markers series.
  public func stem(
    _ x: [Double],
    _ y: [Double],
    baseline: Double = 0,
    color: Color? = nil,
    marker: MarkerStyle = .circle,
    label: String? = nil
  ) {
    guard !x.isEmpty, x.count == y.count else { return }
    let c = color ?? colorCycle.next()
    for i in x.indices {
      plot([x[i], x[i]], [baseline, y[i]], color: c, lineWidth: 1.0)
    }
    scatter(x, y, color: c, marker: marker, label: label)
  }

  // MARK: Stackplot

  /// Adds a stacked area chart using cumulative sums of the provided y arrays.
  ///
  /// Each layer is filled between the previous cumulative sum and the new one.
  ///
  /// - Parameters:
  ///   - x: Shared X-coordinate values.
  ///   - ys: Array of y arrays, one per layer.
  ///   - colors: Colors for each layer; cycles automatically when `nil`.
  ///   - labels: Legend labels for each layer.
  public func stackplot(
    _ x: [Double],
    _ ys: [[Double]],
    colors: [Color]? = nil,
    labels: [String]? = nil
  ) {
    guard !ys.isEmpty, !x.isEmpty else { return }
    var cumulative = Array(repeating: 0.0, count: x.count)
    for (i, layer) in ys.enumerated() {
      let normalized = layer.count == x.count
        ? layer : Array(repeating: 0.0, count: x.count)
      let previous = cumulative
      cumulative = zip(cumulative, normalized).map(+)
      let c = colors?[safe: i] ?? colorCycle.next()
      let lbl = labels?[safe: i]
      fillBetween(x, cumulative, previous, color: c, alpha: 0.7, label: lbl)
    }
  }

  // MARK: Twin x-axis

  /// Creates a new ``Axes`` that shares the same x-axis (plot area) but has
  /// an independent y-axis scale.
  ///
  /// The returned axes is stored in ``twinAxes`` on the receiver and should be
  /// rendered separately after the original axes.
  ///
  /// - Returns: A new ``Axes`` sharing the same ``plotArea``.
  @discardableResult
  public func twinx() -> Axes {
    let twin = Axes(plotArea: plotArea)
    twinAxes = twin
    return twin
  }

  // MARK: Event plot

  /// Adds an event plot: short line markers at each position along an axis.
  ///
  /// - Parameters:
  ///   - positions: Coordinate values of each event.
  ///   - orientation: Whether events lie on a horizontal or vertical axis
  ///     (default: `.horizontal`).
  ///   - color: Line color; cycles automatically when `nil`.
  ///   - lineWidth: Stroke width of each event line (default: `0.7`).
  public func eventplot(
    _ positions: [Double],
    orientation: EventOrientation = .horizontal,
    color: Color? = nil,
    lineWidth: Double = 0.7
  ) {
    guard !positions.isEmpty else { return }
    let c = color ?? colorCycle.next()
    switch orientation {
    case .horizontal:
      for pos in positions {
        axvline(x: pos, color: c, lineWidth: lineWidth)
      }
    case .vertical:
      for pos in positions {
        axhline(y: pos, color: c, lineWidth: lineWidth)
      }
    }
  }
}

// MARK: - Private helpers

extension Axes {

  /// Expands (x, y) into staircase coordinates according to the given placement.
  private func makeStepCoordinates(
    _ x: [Double],
    _ y: [Double],
    placement: StepPlacement
  ) -> ([Double], [Double]) {
    guard x.count >= 2, x.count == y.count else { return (x, y) }
    var sx: [Double] = []
    var sy: [Double] = []
    switch placement {
    case .pre:
      sx.append(x[0]); sy.append(y[0])
      for i in 1..<x.count {
        sx.append(x[i]); sy.append(y[i - 1])
        sx.append(x[i]); sy.append(y[i])
      }
    case .post:
      for i in 0..<(x.count - 1) {
        sx.append(x[i]); sy.append(y[i])
        sx.append(x[i + 1]); sy.append(y[i])
      }
      sx.append(x[x.count - 1]); sy.append(y[y.count - 1])
    case .mid:
      sx.append(x[0]); sy.append(y[0])
      for i in 0..<(x.count - 1) {
        let mid = (x[i] + x[i + 1]) / 2
        sx.append(mid); sy.append(y[i])
        sx.append(mid); sy.append(y[i + 1])
      }
      sx.append(x[x.count - 1]); sy.append(y[y.count - 1])
    }
    return (sx, sy)
  }
}

// MARK: - Safe subscript helper

extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

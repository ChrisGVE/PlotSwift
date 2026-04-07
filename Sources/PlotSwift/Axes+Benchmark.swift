//
//  Axes+Benchmark.swift
//  PlotSwift
//
//  Lightweight benchmarking utilities for measuring Figure render performance.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - PlotBenchmark

/// Utilities for measuring rendering performance of ``Figure`` instances.
///
/// ```swift
/// let fig = Figure(width: 800, height: 600)
/// let ax = fig.addAxes()
/// ax.plot([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])
///
/// let avgSeconds = PlotBenchmark.measureRenderTime(figure: fig, iterations: 20)
/// let svgBytes   = PlotBenchmark.measureSVGSize(figure: fig)
/// ```
public enum PlotBenchmark {

  // MARK: - Render time

  /// Measures the average time taken to render a ``Figure`` to SVG.
  ///
  /// The figure is rendered `iterations` times and the mean wall-clock duration
  /// is returned in seconds.  SVG is used because it is deterministic and does
  /// not require a graphics context setup on non-macOS platforms.
  ///
  /// - Parameters:
  ///   - figure:     The figure to benchmark.
  ///   - iterations: Number of render passes (default: 10).
  /// - Returns: Mean render duration in seconds.
  public static func measureRenderTime(figure: Figure, iterations: Int = 10) -> Double {
    let count = max(1, iterations)
    var total: Double = 0
    for _ in 0..<count {
      let start = Date()
      _ = figure.renderToSVG()
      total += Date().timeIntervalSince(start)
    }
    return total / Double(count)
  }

  // MARK: - SVG size

  /// Returns the UTF-8 character count of the SVG produced by ``Figure/renderToSVG()``.
  ///
  /// This is a proxy for output complexity: larger figures with more data
  /// points produce longer SVG documents.
  ///
  /// - Parameter figure: The figure to measure.
  /// - Returns: Character count of the SVG string.
  public static func measureSVGSize(figure: Figure) -> Int {
    figure.renderToSVG().count
  }
}

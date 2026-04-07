//
//  DataRange.swift
//  PlotSwift
//
//  Data range and axis limit computation for auto-scaling axes.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - DataRange

/// A closed numeric range over a dataset, used for axis scaling.
///
/// `DataRange` captures the minimum and maximum of a data set and provides
/// utilities for padding, union, and expansion to human-friendly tick boundaries.
///
/// ```swift
/// let range = DataRange.from([1.2, 3.7, 2.5])!
/// let (nice, spacing) = range.niceExpanded(targetTicks: 5)
/// // nice ≈ DataRange(min: 1.0, max: 4.0), spacing = 0.5
/// ```
public struct DataRange: Equatable, Sendable {
  /// The lower bound of the range.
  public let min: Double
  /// The upper bound of the range.
  public let max: Double

  /// Creates a range with explicit bounds.
  /// - Parameters:
  ///   - min: Lower bound.
  ///   - max: Upper bound. Must be ≥ `min`.
  public init(min: Double, max: Double) {
    self.min = min
    self.max = max
  }

  // MARK: Computed properties

  /// The difference between `max` and `min`.
  public var span: Double { max - min }

  /// The midpoint of the range.
  public var center: Double { (min + max) / 2 }

  /// `true` when `min == max` (zero-span range).
  public var isEmpty: Bool { min == max }

  // MARK: Static factory

  /// Computes a range from an array of values, filtering out `NaN` and infinite values.
  ///
  /// - Parameter values: The data points to analyse.
  /// - Returns: A `DataRange`, or `nil` if `values` is empty after filtering.
  public static func from(_ values: [Double]) -> DataRange? {
    let finite = values.filter { $0.isFinite }
    guard let lo = finite.min(), let hi = finite.max() else { return nil }
    if lo == hi {
      return DataRange(min: lo - 1, max: hi + 1)
    }
    return DataRange(min: lo, max: hi)
  }

  // MARK: Transformations

  /// Returns a new range symmetrically padded by `percent` of the current span.
  ///
  /// - Parameter percent: Fraction to expand on each side (e.g. `0.05` for 5 %).
  /// - Returns: The expanded `DataRange`.
  public func expanded(by percent: Double) -> DataRange {
    let delta = span * percent
    return DataRange(min: min - delta, max: max + delta)
  }

  /// Returns the smallest range that contains both `self` and `other`.
  ///
  /// - Parameter other: The range to merge with.
  /// - Returns: The union `DataRange`.
  public func union(with other: DataRange) -> DataRange {
    DataRange(min: Swift.min(min, other.min), max: Swift.max(max, other.max))
  }

  /// Returns `true` when `value` falls within `[min, max]`.
  public func contains(_ value: Double) -> Bool {
    value >= min && value <= max
  }

  // MARK: Nice number expansion

  /// Expands the range to nice round boundaries suitable for axis tick labels.
  ///
  /// Uses the classic "nice numbers" algorithm: the tick spacing is rounded to
  /// the nearest value in {1, 2, 5} × 10ⁿ, then the range is extended to the
  /// nearest multiples of that spacing.
  ///
  /// - Parameter targetTicks: Approximate number of tick intervals desired.
  /// - Returns: A tuple of the nice `DataRange` and the chosen `tickSpacing`.
  public func niceExpanded(targetTicks: Int = 5) -> (range: DataRange, tickSpacing: Double) {
    let ticks = Swift.max(1, targetTicks)
    let rawStep = span / Double(ticks)
    let spacing = niceStep(rawStep)
    let niceMin = floor(min / spacing) * spacing
    let niceMax = ceil(max / spacing) * spacing
    return (DataRange(min: niceMin, max: niceMax), spacing)
  }

  // MARK: Private helpers

  /// Rounds `step` up to the nearest value in {1, 2, 5} × 10ⁿ.
  private func niceStep(_ step: Double) -> Double {
    guard step > 0 else { return 1 }
    let magnitude = pow(10, floor(log10(step)))
    let fraction = step / magnitude
    let nice: Double
    if fraction <= 1 {
      nice = 1
    } else if fraction <= 2 {
      nice = 2
    } else if fraction <= 5 {
      nice = 5
    } else {
      nice = 10
    }
    return nice * magnitude
  }
}

// MARK: - AxisLimits

/// The combined x- and y-axis ranges for a plot.
///
/// ```swift
/// let limits = AxisLimits(xRange: xData, yRange: yData)
///     .withPadding(0.05)
///     .niceExpanded()
/// ```
public struct AxisLimits: Equatable, Sendable {
  /// The horizontal axis range.
  public var xRange: DataRange
  /// The vertical axis range.
  public var yRange: DataRange

  /// Creates axis limits from pre-computed ranges.
  public init(xRange: DataRange, yRange: DataRange) {
    self.xRange = xRange
    self.yRange = yRange
  }

  /// Returns new limits with both axes expanded symmetrically by `percent`.
  ///
  /// - Parameter percent: Fraction of the span to add on each side (e.g. `0.05`).
  public func withPadding(_ percent: Double) -> AxisLimits {
    AxisLimits(xRange: xRange.expanded(by: percent), yRange: yRange.expanded(by: percent))
  }

  /// Returns new limits with both axes expanded to nice round boundaries.
  ///
  /// - Parameter targetTicks: Approximate number of tick intervals per axis.
  public func niceExpanded(targetTicks: Int = 5) -> AxisLimits {
    let (niceX, _) = xRange.niceExpanded(targetTicks: targetTicks)
    let (niceY, _) = yRange.niceExpanded(targetTicks: targetTicks)
    return AxisLimits(xRange: niceX, yRange: niceY)
  }
}

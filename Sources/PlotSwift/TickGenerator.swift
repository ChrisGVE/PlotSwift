//
//  TickGenerator.swift
//  PlotSwift
//
//  Automatic tick generation and formatting for plot axes.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - TickDirection

/// Specifies which direction tick marks extend from the axis line.
public enum TickDirection {
  /// Ticks extend toward the inside of the plot area.
  case inside
  /// Ticks extend toward the outside of the plot area.
  case outside
  /// Ticks extend in both directions.
  case both
}

// MARK: - TickFormatter

/// A type that converts a numeric tick value into a display string.
public protocol TickFormatter {
  /// Returns the formatted string for `value`.
  func format(_ value: Double) -> String
}

// MARK: - DefaultTickFormatter

/// Formats tick values as integers when whole, otherwise with up to four significant digits.
public struct DefaultTickFormatter: TickFormatter {
  /// Creates a default tick formatter.
  public init() {}

  public func format(_ value: Double) -> String {
    if value == 0 { return "0" }
    if value.truncatingRemainder(dividingBy: 1) == 0 {
      return String(Int(value))
    }
    let magnitude = abs(value)
    if magnitude >= 0.01 && magnitude < 10_000 {
      return String(format: "%g", value)
    }
    return String(format: "%.4g", value)
  }
}

// MARK: - ScientificTickFormatter

/// Formats tick values in scientific notation, e.g. "1.2e+03".
public struct ScientificTickFormatter: TickFormatter {
  /// Creates a scientific tick formatter.
  public init() {}

  public func format(_ value: Double) -> String {
    String(format: "%e", value)
  }
}

// MARK: - PercentTickFormatter

/// Multiplies the value by 100 and appends a percent sign.
public struct PercentTickFormatter: TickFormatter {
  /// Creates a percent tick formatter.
  public init() {}

  public func format(_ value: Double) -> String {
    let pct = value * 100
    if pct.truncatingRemainder(dividingBy: 1) == 0 {
      return "\(Int(pct))%"
    }
    return String(format: "%g%%", pct)
  }
}

// MARK: - FixedDecimalFormatter

/// Formats tick values with a fixed number of decimal places.
public struct FixedDecimalFormatter: TickFormatter {
  /// Number of decimal places to display.
  public let decimalPlaces: Int

  /// Creates a fixed decimal formatter.
  /// - Parameter decimalPlaces: Number of decimal places (default: 2).
  public init(decimalPlaces: Int = 2) {
    self.decimalPlaces = max(0, decimalPlaces)
  }

  public func format(_ value: Double) -> String {
    String(format: "%.\(decimalPlaces)f", value)
  }
}

// MARK: - TickGenerator

/// Generates evenly spaced, human-readable tick positions for a data range.
public struct TickGenerator {

  /// Creates a tick generator.
  public init() {}

  /// Returns tick positions for `range` using a nice-number spacing algorithm.
  ///
  /// - Parameters:
  ///   - range: The data range to cover.
  ///   - maxTicks: Upper bound on the number of ticks (default: 10).
  /// - Returns: An array of tick values within or bordering the range.
  public func generateTicks(range: DataRange, maxTicks: Int = 10) -> [Double] {
    guard range.span > 0, maxTicks >= 2 else { return [range.min] }

    // Ceiling (not rounding) of the nice spacing guarantees the count never
    // exceeds maxTicks even when the range divides evenly by the spacing.
    let rawSpacing = range.span / Double(maxTicks - 1)
    let spacing = niceNumber(rawSpacing, round: false)

    let firstTick = (range.min / spacing).rounded(.up) * spacing
    var ticks: [Double] = []
    var tick = firstTick
    while tick <= range.max + spacing * 1e-10 {
      ticks.append(tick)
      tick += spacing
    }
    return ticks
  }
}

// MARK: - Internal helpers

/// Returns a "nice" number close to `value`, rounded or ceiled to a 1/2/5 multiple of a power of 10.
func niceNumber(_ value: Double, round: Bool) -> Double {
  guard value > 0 else { return 1 }
  let exponent = floor(log10(value))
  let fraction = value / pow(10, exponent)
  let nice: Double
  if round {
    if fraction < 1.5 {
      nice = 1
    } else if fraction < 3 {
      nice = 2
    } else if fraction < 7 {
      nice = 5
    } else {
      nice = 10
    }
  } else {
    if fraction <= 1 {
      nice = 1
    } else if fraction <= 2 {
      nice = 2
    } else if fraction <= 5 {
      nice = 5
    } else {
      nice = 10
    }
  }
  return nice * pow(10, exponent)
}

//
//  MarkerStyle.swift
//  PlotSwift
//
//  Marker shapes for data point visualization.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

// MARK: - MarkerStyle

/// Marker shapes for data point visualization.
///
/// MarkerStyle defines shapes that can be used to mark data points
/// in scatter plots and line plots.
///
/// The raw values match matplotlib's marker shorthand notation.
public enum MarkerStyle: String, Sendable {
  /// A circle marker.
  case circle = "o"
  /// A square marker.
  case square = "s"
  /// A diamond marker.
  case diamond = "D"
  /// An upward-pointing triangle.
  case triangleUp = "^"
  /// A downward-pointing triangle.
  case triangleDown = "v"
  /// A left-pointing triangle.
  case triangleLeft = "<"
  /// A right-pointing triangle.
  case triangleRight = ">"
  /// A plus sign marker.
  case plus = "+"
  /// An X-shaped cross marker.
  case cross = "x"
  /// A star marker.
  case star = "*"
  /// A small dot marker.
  case dot = "."
  /// No marker (invisible).
  case none = ""
}

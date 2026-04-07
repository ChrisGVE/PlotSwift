//
//  Annotations.swift
//  PlotSwift
//
//  Annotation types for plot labeling and reference lines.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - Annotation

/// A text annotation that can optionally point to a data location with an arrow.
public struct Annotation: Equatable, Sendable {
  /// The annotation text.
  public let text: String
  /// The data point being annotated.
  public let point: (Double, Double)
  /// The position of the text label (nil = same as point).
  public let textPosition: (Double, Double)?
  /// Arrow properties (nil = no arrow).
  public let arrowProps: ArrowProps?
  /// Font size for the annotation text.
  public let fontSize: Double
  /// Text color.
  public let color: Color

  public init(
    text: String,
    point: (Double, Double),
    textPosition: (Double, Double)? = nil,
    arrowProps: ArrowProps? = nil,
    fontSize: Double = 12,
    color: Color = .black
  ) {
    self.text = text
    self.point = point
    self.textPosition = textPosition
    self.arrowProps = arrowProps
    self.fontSize = fontSize
    self.color = color
  }

  public static func == (lhs: Annotation, rhs: Annotation) -> Bool {
    lhs.text == rhs.text
      && lhs.point.0 == rhs.point.0
      && lhs.point.1 == rhs.point.1
      && lhs.fontSize == rhs.fontSize
      && lhs.color == rhs.color
  }
}

// MARK: - ArrowProps

/// Properties for annotation arrows.
public struct ArrowProps: Equatable, Sendable {
  /// The arrow style.
  public var arrowStyle: ArrowStyle
  /// Arrow color.
  public var color: Color
  /// Arrow line width.
  public var lineWidth: Double

  public init(
    arrowStyle: ArrowStyle = .simple,
    color: Color = .black,
    lineWidth: Double = 1.0
  ) {
    self.arrowStyle = arrowStyle
    self.color = color
    self.lineWidth = lineWidth
  }
}

// MARK: - ArrowStyle

/// Visual styles for annotation arrows.
public enum ArrowStyle: Sendable, Equatable {
  /// A simple line with arrowhead.
  case simple
  /// A curved arrow.
  case fancy
  /// A wedge-shaped arrow.
  case wedge
}

// MARK: - ReferenceLine

/// A horizontal or vertical reference line spanning the plot area.
public struct ReferenceLine: Equatable, Sendable {
  /// The axis this line is parallel to.
  public enum Axis: Sendable, Equatable {
    case horizontal(y: Double)
    case vertical(x: Double)
  }

  /// Which axis the line is on.
  public let axis: Axis
  /// Line color.
  public let color: Color
  /// Line dash style.
  public let lineStyle: LineStyle
  /// Line width.
  public let lineWidth: Double

  public init(
    axis: Axis,
    color: Color = .black,
    lineStyle: LineStyle = .solid,
    lineWidth: Double = 1.0
  ) {
    self.axis = axis
    self.color = color
    self.lineStyle = lineStyle
    self.lineWidth = lineWidth
  }
}

// MARK: - ReferenceSpan

/// A shaded horizontal or vertical region on the plot.
public struct ReferenceSpan: Equatable, Sendable {
  /// The axis direction of the span.
  public enum Axis: Sendable, Equatable {
    case horizontal(yMin: Double, yMax: Double)
    case vertical(xMin: Double, xMax: Double)
  }

  /// Which region to shade.
  public let axis: Axis
  /// Fill color.
  public let color: Color
  /// Opacity (0.0 to 1.0).
  public let alpha: Double

  public init(
    axis: Axis,
    color: Color = .blue,
    alpha: Double = 0.3
  ) {
    self.axis = axis
    self.color = color
    self.alpha = alpha
  }
}

// MARK: - FillBetween

/// Data for filling the area between two curves.
public struct FillBetween: Sendable {
  /// X coordinates.
  public let x: [Double]
  /// Upper y boundary.
  public let y1: [Double]
  /// Lower y boundary (defaults to 0 if nil).
  public let y2: [Double]?
  /// Fill color.
  public let color: Color
  /// Fill opacity.
  public let alpha: Double
  /// Optional edge color.
  public let edgeColor: Color?
  /// Edge line width.
  public let edgeWidth: Double
  /// Optional label for legend.
  public let label: String?

  public init(
    x: [Double],
    y1: [Double],
    y2: [Double]? = nil,
    color: Color = .blue,
    alpha: Double = 0.3,
    edgeColor: Color? = nil,
    edgeWidth: Double = 0,
    label: String? = nil
  ) {
    self.x = x
    self.y1 = y1
    self.y2 = y2
    self.color = color
    self.alpha = alpha
    self.edgeColor = edgeColor
    self.edgeWidth = edgeWidth
    self.label = label
  }
}

// MARK: - PolygonSeries

/// A filled and/or stroked polygon defined by explicit (x, y) vertex coordinates.
public struct PolygonSeries: Sendable {
  /// X-coordinates of the polygon vertices (in data space).
  public let xs: [Double]
  /// Y-coordinates of the polygon vertices (in data space).
  public let ys: [Double]
  /// Fill color.
  public let fillColor: Color
  /// Fill opacity.
  public let alpha: Double
  /// Optional edge stroke color (`nil` means no stroke).
  public let edgeColor: Color?
  /// Edge stroke width in points.
  public let edgeWidth: Double

  public init(
    xs: [Double],
    ys: [Double],
    fillColor: Color = .blue,
    alpha: Double = 0.5,
    edgeColor: Color? = nil,
    edgeWidth: Double = 1.0
  ) {
    self.xs = xs
    self.ys = ys
    self.fillColor = fillColor
    self.alpha = alpha
    self.edgeColor = edgeColor
    self.edgeWidth = edgeWidth
  }
}

// MARK: - ErrorBarValue

/// Error bar specification for data points.
public enum ErrorBarValue: Sendable {
  /// Same error for all points.
  case symmetric(Double)
  /// Per-point symmetric error.
  case symmetricArray([Double])
  /// Per-point asymmetric error (lower, upper).
  case asymmetric([Double], [Double])

  /// Resolves the lower and upper error for a given point index.
  public func resolve(at index: Int) -> (lower: Double, upper: Double) {
    switch self {
    case .symmetric(let value):
      return (value, value)
    case .symmetricArray(let values):
      let v = index < values.count ? values[index] : 0
      return (v, v)
    case .asymmetric(let lower, let upper):
      let lo = index < lower.count ? lower[index] : 0
      let hi = index < upper.count ? upper[index] : 0
      return (lo, hi)
    }
  }
}

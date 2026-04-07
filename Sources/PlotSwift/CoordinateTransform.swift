//
//  CoordinateTransform.swift
//  PlotSwift
//
//  Coordinate transformation between data space and pixel space.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - CoordinateTransform

/// Transforms coordinates between data space and pixel space.
///
/// Implement this protocol to define custom mappings between the
/// numeric domain of a dataset and the pixel coordinates of a
/// rendered figure.
public protocol CoordinateTransform {
  /// Converts a data-space point to pixel coordinates.
  /// - Parameters:
  ///   - x: The data x-coordinate.
  ///   - y: The data y-coordinate.
  /// - Returns: The corresponding pixel `(x, y)` tuple.
  func dataToPixel(x: Double, y: Double) -> (Double, Double)

  /// Converts a pixel-space point back to data coordinates.
  /// - Parameters:
  ///   - x: The pixel x-coordinate.
  ///   - y: The pixel y-coordinate.
  /// - Returns: The corresponding data `(x, y)` tuple.
  func pixelToData(x: Double, y: Double) -> (Double, Double)
}

// MARK: - LinearTransform

/// A linear (affine) mapping between a data rectangle and a pixel rectangle.
///
/// Data y increases upward; pixel y increases downward, so the y-axis is
/// inverted during the transformation.
///
/// ```swift
/// let transform = LinearTransform(
///     dataXRange: DataRange(min: 0, max: 10),
///     dataYRange: DataRange(min: -1, max: 1),
///     pixelBounds: CGRect(x: 70, y: 40, width: 460, height: 500)
/// )
/// let (px, py) = transform.dataToPixel(x: 5, y: 0)
/// ```
public struct LinearTransform: CoordinateTransform, Sendable {
  /// The data-space x extent.
  public let dataXRange: DataRange
  /// The data-space y extent.
  public let dataYRange: DataRange
  /// The pixel rectangle that the data space maps onto.
  public let pixelBounds: CGRect

  /// Creates a linear transform.
  /// - Parameters:
  ///   - dataXRange: The x range in data space.
  ///   - dataYRange: The y range in data space.
  ///   - pixelBounds: The target pixel rectangle.
  public init(dataXRange: DataRange, dataYRange: DataRange, pixelBounds: CGRect) {
    self.dataXRange = dataXRange
    self.dataYRange = dataYRange
    self.pixelBounds = pixelBounds
  }

  public func dataToPixel(x: Double, y: Double) -> (Double, Double) {
    let px = pixelBounds.minX + (x - dataXRange.min) / dataXRange.span * pixelBounds.width
    // Invert y: data min maps to pixel bottom (maxY), data max to pixel top (minY).
    let py = pixelBounds.maxY - (y - dataYRange.min) / dataYRange.span * pixelBounds.height
    return (px, Double(py))
  }

  public func pixelToData(x: Double, y: Double) -> (Double, Double) {
    let dx = dataXRange.min + (x - pixelBounds.minX) / pixelBounds.width * dataXRange.span
    let dy = dataYRange.min + (pixelBounds.maxY - y) / pixelBounds.height * dataYRange.span
    return (dx, dy)
  }
}

// MARK: - EdgeInsets

/// Inset distances that define the margin around a rectangular area.
public struct EdgeInsets: Equatable, Sendable {
  /// The inset from the top edge, in points.
  public var top: Double
  /// The inset from the bottom edge, in points.
  public var bottom: Double
  /// The inset from the left edge, in points.
  public var left: Double
  /// The inset from the right edge, in points.
  public var right: Double

  /// Creates an EdgeInsets value.
  public init(top: Double, bottom: Double, left: Double, right: Double) {
    self.top = top
    self.bottom = bottom
    self.left = left
    self.right = right
  }

  /// Default margins suitable for a plot with axis labels and a title.
  public static let defaultPlotMargins = EdgeInsets(top: 40, bottom: 60, left: 70, right: 20)
}

// MARK: - PlotArea

/// Describes the drawable region of a figure, accounting for margins reserved
/// for axis labels, tick marks, and the plot title.
///
/// ```swift
/// let area = PlotArea(bounds: CGRect(x: 0, y: 0, width: 800, height: 600))
/// let rect = area.plotRect  // inset by defaultPlotMargins
/// ```
public struct PlotArea: Sendable {
  /// The total figure rectangle, including all margins.
  public let bounds: CGRect
  /// Space reserved outside the plot content for labels and decorations.
  public var margins: EdgeInsets

  /// The rectangle available for drawing plot content (bounds minus margins).
  public var plotRect: CGRect {
    CGRect(
      x: bounds.minX + margins.left,
      y: bounds.minY + margins.top,
      width: bounds.width - margins.left - margins.right,
      height: bounds.height - margins.top - margins.bottom
    )
  }

  /// Creates a PlotArea with the given bounds and optional custom margins.
  /// - Parameters:
  ///   - bounds: The total figure rectangle.
  ///   - margins: Margin insets (default: ``EdgeInsets/defaultPlotMargins``).
  public init(bounds: CGRect, margins: EdgeInsets = .defaultPlotMargins) {
    self.bounds = bounds
    self.margins = margins
  }
}

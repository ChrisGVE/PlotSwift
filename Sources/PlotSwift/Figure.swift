//
//  Figure.swift
//  PlotSwift
//
//  Top-level container for one or more Axes objects.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - Figure

/// The top-level container for a plot, analogous to matplotlib's `Figure`.
///
/// A `Figure` has a fixed pixel size and holds one or more ``Axes`` objects.
/// Use ``addAxes(rect:)`` for full-figure plots or ``addSubplot(rows:cols:index:)``
/// for grid layouts.  Export the finished figure via ``renderToPNG(scale:)``,
/// ``renderToPDF()``, or ``renderToSVG()``.
///
/// ```swift
/// let fig = Figure(width: 800, height: 600)
/// let ax = fig.addAxes()
/// let png = fig.renderToPNG()
/// ```
public final class Figure {

  // MARK: Properties

  /// Pixel dimensions of the figure.
  public let size: CGSize

  /// Background fill colour (default: white).
  public var backgroundColor: Color = .white

  /// All axes that have been added to this figure, in insertion order.
  public private(set) var axesList: [Axes] = []

  // MARK: Geometry constants

  private enum Layout {
    static let defaultMargin = 0.08  // fraction of figure dimension
    static let subplotSpacing = 0.06  // fraction of cell dimension
  }

  // MARK: Initialiser

  /// Creates a figure with the specified dimensions.
  /// - Parameters:
  ///   - width:  Width in points (default 800).
  ///   - height: Height in points (default 600).
  public init(width: Double = 800, height: Double = 600) {
    size = CGSize(width: width, height: height)
  }

  // MARK: - Adding Axes

  /// Adds a single ``Axes`` to the figure and returns it.
  ///
  /// - Parameter rect: The region the axes should occupy, in figure-space points.
  ///   Pass `nil` (the default) to fill the figure with default margins applied.
  /// - Returns: The newly created ``Axes``.
  @discardableResult
  public func addAxes(rect: CGRect? = nil) -> Axes {
    let bounds = rect ?? defaultBounds()
    let axes = Axes(plotArea: PlotArea(bounds: bounds))
    axesList.append(axes)
    return axes
  }

  /// Adds an ``Axes`` at the grid position indicated by `index`.
  ///
  /// `index` is 1-based, matching matplotlib's `add_subplot(rows, cols, index)`.
  ///
  /// - Parameters:
  ///   - rows:  Number of grid rows.
  ///   - cols:  Number of grid columns.
  ///   - index: 1-based cell index, filling row-by-row left to right.
  /// - Returns: The newly created ``Axes``.
  @discardableResult
  public func addSubplot(rows: Int, cols: Int, index: Int) -> Axes {
    let bounds = subplotBounds(rows: rows, cols: cols, index: index)
    let axes = Axes(plotArea: PlotArea(bounds: bounds))
    axesList.append(axes)
    return axes
  }

  // MARK: - Export

  /// Renders the figure to PNG data.
  /// - Parameter scale: Pixel-density multiplier (default 1.0).
  /// - Returns: PNG-encoded `Data`, or `nil` on failure.
  public func renderToPNG(scale: CGFloat = 1.0) -> Data? {
    let ctx = makeDrawingContext()
    return ctx.renderToPNG(size: size, scale: scale)
  }

  /// Renders the figure to PDF data.
  /// - Returns: PDF-encoded `Data`, or `nil` on failure.
  public func renderToPDF() -> Data? {
    let ctx = makeDrawingContext()
    return ctx.renderToPDF(size: size)
  }

  /// Renders the figure to an SVG string.
  /// - Returns: An SVG document as a `String`.
  public func renderToSVG() -> String {
    let ctx = makeDrawingContext()
    return ctx.renderToSVG(size: size)
  }

  // MARK: - Private helpers

  /// Builds and populates a fresh DrawingContext with background + all axes.
  private func makeDrawingContext() -> DrawingContext {
    let ctx = DrawingContext()
    renderBackground(to: ctx)
    for axes in axesList {
      axes.render(to: ctx)
    }
    return ctx
  }

  /// Emits a filled background rectangle.
  private func renderBackground(to ctx: DrawingContext) {
    ctx.setFillColor(backgroundColor)
    ctx.rect(0, 0, Double(size.width), Double(size.height))
    ctx.fillPath()
  }

  /// Default axes bounds: full figure minus a proportional margin on all sides.
  private func defaultBounds() -> CGRect {
    let mx = Double(size.width) * Layout.defaultMargin
    let my = Double(size.height) * Layout.defaultMargin
    return CGRect(
      x: mx, y: my,
      width: Double(size.width) - 2 * mx,
      height: Double(size.height) - 2 * my
    )
  }

  /// Computes the pixel bounds for a single cell in a rows×cols grid.
  private func subplotBounds(rows: Int, cols: Int, index: Int) -> CGRect {
    let safeIndex = max(1, min(index, rows * cols))
    let row = (safeIndex - 1) / cols
    let col = (safeIndex - 1) % cols

    let cellW = Double(size.width) / Double(cols)
    let cellH = Double(size.height) / Double(rows)
    let padX = cellW * Layout.subplotSpacing
    let padY = cellH * Layout.subplotSpacing

    return CGRect(
      x: Double(col) * cellW + padX,
      y: Double(row) * cellH + padY,
      width: cellW - 2 * padX,
      height: cellH - 2 * padY
    )
  }
}

// MARK: - Module-level convenience

/// Creates a `Figure` together with a grid of ``Axes``, matching matplotlib's
/// `plt.subplots()` signature.
///
/// ```swift
/// let (fig, axes) = subplots(rows: 2, cols: 3, figsize: (1200, 800))
/// axes[0][1].title = "Top-centre"
/// ```
///
/// - Parameters:
///   - rows:    Number of subplot rows (default 1).
///   - cols:    Number of subplot columns (default 1).
///   - figsize: Figure `(width, height)` in points (default 800 × 600).
/// - Returns: The figure and a `rows × cols` 2-D array of axes.
public func subplots(
  rows: Int = 1,
  cols: Int = 1,
  figsize: (Double, Double) = (800, 600)
) -> (Figure, [[Axes]]) {
  let fig = Figure(width: figsize.0, height: figsize.1)
  var grid: [[Axes]] = []
  for r in 0..<rows {
    var row: [Axes] = []
    for c in 0..<cols {
      let index = r * cols + c + 1
      row.append(fig.addSubplot(rows: rows, cols: cols, index: index))
    }
    grid.append(row)
  }
  return (fig, grid)
}

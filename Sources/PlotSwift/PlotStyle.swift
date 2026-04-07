//
//  PlotStyle.swift
//  PlotSwift
//
//  Global style configuration for plot rendering (analogous to matplotlib rcParams).
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

// MARK: - PlotStyle

/// Global style configuration applied to all plot elements.
///
/// `PlotStyle` mirrors matplotlib's `rcParams` concept: a single value object
/// carrying defaults for figure size, fonts, line widths, grid appearance, and
/// the active color palette.  Mutate ``current`` to change defaults globally,
/// or call ``setStyle(_:)`` for a more expressive one-liner.
///
/// ```swift
/// // Switch to the dark-grid seaborn theme
/// setStyle(.darkgrid)
///
/// // Customise a single field
/// PlotStyle.current.lineWidth = 2.0
/// ```
public struct PlotStyle: Sendable {

  // MARK: Figure

  /// Default figure size in points (width, height).
  public var figureSize: (Double, Double) = (800, 600)

  /// Background fill color for the figure.
  public var backgroundColor: Color = .white

  // MARK: Typography

  /// Default font family applied to all text elements.
  public var fontFamily: String = "sans-serif"

  /// Font size used for axis and figure titles.
  public var titleFontSize: Double = 16

  /// Font size used for axis labels.
  public var labelFontSize: Double = 12

  /// Font size used for tick labels.
  public var tickFontSize: Double = 10

  // MARK: Lines & markers

  /// Default stroke width for data lines.
  public var lineWidth: Double = 1.5

  /// Default diameter for data markers.
  public var markerSize: Double = 6

  // MARK: Color palette

  /// Default color palette for cycling through data series.
  public var palette: ColorPalette = .tab10

  // MARK: Grid

  /// Whether the axes grid is shown by default.
  public var gridVisible: Bool = false

  /// Grid line color.
  public var gridColor: Color = .lightGray

  /// Grid line dash pattern.
  public var gridLineStyle: LineStyle = .solid

  /// Grid line stroke width.
  public var gridLineWidth: Double = 0.5

  // MARK: Axes

  /// Stroke width for axis spines.
  public var axesLineWidth: Double = 1.0

  /// Color for axis spines and ticks.
  public var axesColor: Color = .black

  // MARK: Global state

  /// The active style used by all new plots.
  public static var current = PlotStyle()

  /// The immutable factory-default style.
  public static let `default` = PlotStyle()
}

// MARK: - Predefined themes

extension PlotStyle {

  /// Seaborn `darkgrid`: dark axes background with a visible grid.
  public static let darkgrid = PlotStyle(
    backgroundColor: Color(red: 0.925, green: 0.925, blue: 0.925),
    gridVisible: true,
    gridColor: Color(red: 1, green: 1, blue: 1),
    gridLineWidth: 0.8,
    axesColor: Color(red: 0.15, green: 0.15, blue: 0.15)
  )

  /// Seaborn `whitegrid`: white axes background with a visible grid.
  public static let whitegrid = PlotStyle(
    backgroundColor: .white,
    gridVisible: true,
    gridColor: Color(red: 0.8, green: 0.8, blue: 0.8),
    gridLineWidth: 0.8,
    axesColor: .black
  )

  /// Seaborn `dark`: dark axes background, no grid.
  public static let dark = PlotStyle(
    backgroundColor: Color(red: 0.925, green: 0.925, blue: 0.925),
    gridVisible: false,
    axesColor: Color(red: 0.15, green: 0.15, blue: 0.15)
  )

  /// Seaborn `white`: white axes background, no grid, no top/right spines.
  public static let white = PlotStyle(
    backgroundColor: .white,
    gridVisible: false,
    axesColor: .black
  )

  /// Seaborn `ticks`: white background, no grid, tick marks on axes.
  public static let ticks = PlotStyle(
    backgroundColor: .white,
    gridVisible: false,
    axesLineWidth: 1.25,
    axesColor: .black
  )
}

// MARK: - Memberwise convenience init (themes only)

extension PlotStyle {

  /// Internal init used by predefined themes to override select properties.
  init(
    backgroundColor: Color = .white,
    gridVisible: Bool = false,
    gridColor: Color = .lightGray,
    gridLineWidth: Double = 0.5,
    axesLineWidth: Double = 1.0,
    axesColor: Color = .black
  ) {
    self.backgroundColor = backgroundColor
    self.gridVisible = gridVisible
    self.gridColor = gridColor
    self.gridLineWidth = gridLineWidth
    self.axesLineWidth = axesLineWidth
    self.axesColor = axesColor
  }
}

// MARK: - Global convenience

/// Sets the active plot style used by all subsequent plots.
///
/// Equivalent to assigning `PlotStyle.current = style`.
///
/// - Parameter style: The style to activate.
public func setStyle(_ style: PlotStyle) {
  PlotStyle.current = style
}

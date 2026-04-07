//
//  Axes.swift
//  PlotSwift
//
//  Core Axes class representing a single plot area.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - SeriesType

/// The visual representation style for a data series.
public enum SeriesType: Sendable {
  /// A connected line plot.
  case line
  /// A scatter plot of individual markers.
  case scatter
  /// A bar chart.
  case bar
}

// MARK: - LegendPosition

/// The corner where the legend is anchored within the plot area.
public enum LegendPosition: Sendable {
  /// Upper-right corner.
  case topRight
  /// Upper-left corner.
  case topLeft
  /// Lower-right corner.
  case bottomRight
  /// Lower-left corner.
  case bottomLeft
}

// MARK: - DataSeries

/// A single dataset with associated visual styling.
public struct DataSeries: Sendable {
  /// X-coordinate values.
  public let x: [Double]
  /// Y-coordinate values.
  public let y: [Double]
  /// Optional label shown in the legend.
  public let label: String?
  /// Stroke and marker color.
  public let color: Color
  /// Line dash style.
  public let lineStyle: LineStyle
  /// Marker shape drawn at each point.
  public let marker: MarkerStyle
  /// Stroke width in points.
  public let lineWidth: Double
  /// Marker diameter in points.
  public let markerSize: Double
  /// How the series is rendered.
  public let seriesType: SeriesType

  /// Creates a DataSeries with all styling parameters.
  public init(
    x: [Double],
    y: [Double],
    label: String? = nil,
    color: Color,
    lineStyle: LineStyle = .solid,
    marker: MarkerStyle = .none,
    lineWidth: Double = 1.5,
    markerSize: Double = 6.0,
    seriesType: SeriesType = .line
  ) {
    self.x = x
    self.y = y
    self.label = label
    self.color = color
    self.lineStyle = lineStyle
    self.marker = marker
    self.lineWidth = lineWidth
    self.markerSize = markerSize
    self.seriesType = seriesType
  }
}

// MARK: - Axes

/// A rectangular coordinate system that owns data series, axis decoration, and rendering.
///
/// ```swift
/// let ax = Axes(plotArea: PlotArea(bounds: CGRect(x: 0, y: 0, width: 800, height: 600)))
/// ax.plot([1, 2, 3], [4, 5, 6], label: "Series A")
/// ax.setTitle("My Plot")
/// ax.grid(true)
/// let ctx = DrawingContext()
/// ax.render(to: ctx)
/// ```
public final class Axes {

  // MARK: Public properties

  /// The drawing region and margins for this axes.
  public var plotArea: PlotArea

  /// Optional plot title.
  public var title: String?

  /// Optional x-axis label.
  public var xLabel: String?

  /// Optional y-axis label.
  public var yLabel: String?

  /// Explicit x-axis limits; `nil` means auto-scale from data.
  public var xLimits: DataRange?

  /// Explicit y-axis limits; `nil` means auto-scale from data.
  public var yLimits: DataRange?

  /// Whether to draw grid lines at each tick.
  public var showGrid: Bool = false

  /// Grid line color.
  public var gridColor: Color = .lightGray

  /// Grid line dash style.
  public var gridLineStyle: LineStyle = .solid

  /// Grid line stroke width.
  public var gridLineWidth: Double = 0.5

  // MARK: Internal state

  internal var dataSeries: [DataSeries] = []
  internal var colorCycle: ColorCycle
  internal var annotations: [Annotation] = []
  internal var referenceLines: [ReferenceLine] = []
  internal var referenceSpans: [ReferenceSpan] = []
  internal var fillBetweens: [FillBetween] = []
  internal var barSeriesList: [BarSeries] = []
  internal var errorBarData: [ErrorBarData] = []
  internal var showLegend: Bool = false
  internal var legendPosition: LegendPosition = .topRight
  internal var titleStyle: TextStyle?
  internal var xLabelStyle: TextStyle?
  internal var yLabelStyle: TextStyle?
  internal var colorbar: Colorbar?

  // MARK: Init

  /// Creates an axes with the given plot area and optional color palette.
  /// - Parameters:
  ///   - plotArea: The drawable region (bounds + margins).
  ///   - palette: Color palette for automatic series coloring (default: `.tab10`).
  public init(plotArea: PlotArea, palette: ColorPalette = .tab10) {
    self.plotArea = plotArea
    self.colorCycle = ColorCycle(palette: palette)
  }

  // MARK: Configuration

  /// Sets the x-axis display range explicitly.
  public func setXLim(_ min: Double, _ max: Double) {
    xLimits = DataRange(min: min, max: max)
  }

  /// Sets the y-axis display range explicitly.
  public func setYLim(_ min: Double, _ max: Double) {
    yLimits = DataRange(min: min, max: max)
  }

  /// Sets the plot title with an optional custom text style.
  public func setTitle(_ title: String, style: TextStyle? = nil) {
    self.title = title
    titleStyle = style
  }

  /// Sets the x-axis label with an optional custom text style.
  public func setXLabel(_ label: String, style: TextStyle? = nil) {
    xLabel = label
    xLabelStyle = style
  }

  /// Sets the y-axis label with an optional custom text style.
  public func setYLabel(_ label: String, style: TextStyle? = nil) {
    yLabel = label
    yLabelStyle = style
  }

  /// Configures grid display. Unspecified parameters retain their current values.
  public func grid(
    _ show: Bool,
    color: Color? = nil,
    lineStyle: LineStyle? = nil,
    lineWidth: Double? = nil
  ) {
    showGrid = show
    if let c = color { gridColor = c }
    if let s = lineStyle { gridLineStyle = s }
    if let w = lineWidth { gridLineWidth = w }
  }

  // MARK: Plot methods

  /// Adds a line series to the axes.
  ///
  /// - Parameters:
  ///   - x: X-coordinate values.
  ///   - y: Y-coordinate values.
  ///   - color: Line color; cycles automatically when `nil`.
  ///   - lineStyle: Dash style for the connecting line.
  ///   - lineWidth: Stroke width in points.
  ///   - marker: Marker shape drawn at each data point.
  ///   - markerSize: Marker diameter in points.
  ///   - label: Legend label.
  /// - Returns: The created ``DataSeries`` (discardable).
  @discardableResult
  public func plot(
    _ x: [Double],
    _ y: [Double],
    color: Color? = nil,
    lineStyle: LineStyle = .solid,
    lineWidth: Double = 1.5,
    marker: MarkerStyle = .none,
    markerSize: Double = 6.0,
    label: String? = nil
  ) -> DataSeries {
    let c = color ?? colorCycle.next()
    let series = DataSeries(
      x: x, y: y, label: label, color: c,
      lineStyle: lineStyle, marker: marker,
      lineWidth: lineWidth, markerSize: markerSize,
      seriesType: .line)
    dataSeries.append(series)
    return series
  }

  /// Adds a line series using sequential indices as x-coordinates.
  @discardableResult
  public func plot(
    _ y: [Double],
    color: Color? = nil,
    lineStyle: LineStyle = .solid,
    lineWidth: Double = 1.5,
    marker: MarkerStyle = .none,
    markerSize: Double = 6.0,
    label: String? = nil
  ) -> DataSeries {
    let x = y.indices.map { Double($0) }
    return plot(
      x, y, color: color, lineStyle: lineStyle,
      lineWidth: lineWidth, marker: marker,
      markerSize: markerSize, label: label)
  }

  /// Adds a scatter series to the axes.
  ///
  /// - Parameters:
  ///   - x: X-coordinate values.
  ///   - y: Y-coordinate values.
  ///   - color: Marker color; cycles automatically when `nil`.
  ///   - marker: Marker shape.
  ///   - markerSize: Marker diameter in points.
  ///   - alpha: Overall opacity (0–1).
  ///   - label: Legend label.
  /// - Returns: The created ``DataSeries`` (discardable).
  @discardableResult
  public func scatter(
    _ x: [Double],
    _ y: [Double],
    color: Color? = nil,
    marker: MarkerStyle = .circle,
    markerSize: Double = 6.0,
    alpha: Double = 1.0,
    label: String? = nil
  ) -> DataSeries {
    let base = color ?? colorCycle.next()
    let c = Color(red: base.red, green: base.green, blue: base.blue, alpha: alpha)
    let series = DataSeries(
      x: x, y: y, label: label, color: c,
      lineStyle: .none, marker: marker,
      lineWidth: 0, markerSize: markerSize,
      seriesType: .scatter)
    dataSeries.append(series)
    return series
  }

  // MARK: Legend

  /// Shows the legend at the specified position.
  /// - Parameter position: Corner to anchor the legend (default: `.topRight`).
  public func legend(position: LegendPosition = .topRight) {
    showLegend = true
    legendPosition = position
  }
}

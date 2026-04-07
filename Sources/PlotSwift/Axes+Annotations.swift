//
//  Axes+Annotations.swift
//  PlotSwift
//
//  Annotation, reference line, fill, and error bar methods on Axes.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - Annotations

extension Axes {

  /// Adds a text annotation, optionally with an arrow pointing to the data.
  public func annotate(
    _ text: String,
    xy: (Double, Double),
    xytext: (Double, Double)? = nil,
    arrowprops: ArrowProps? = nil,
    fontsize: Double = 12,
    color: Color = .black
  ) {
    let ann = Annotation(
      text: text, point: xy,
      textPosition: xytext, arrowProps: arrowprops,
      fontSize: fontsize, color: color)
    annotations.append(ann)
  }

  /// Draws a horizontal reference line spanning the full x-axis at the given y value.
  public func axhline(
    y: Double,
    color: Color = .black,
    lineStyle: LineStyle = .solid,
    lineWidth: Double = 1.0
  ) {
    referenceLines.append(
      ReferenceLine(
        axis: .horizontal(y: y),
        color: color, lineStyle: lineStyle, lineWidth: lineWidth))
  }

  /// Draws a vertical reference line spanning the full y-axis at the given x value.
  public func axvline(
    x: Double,
    color: Color = .black,
    lineStyle: LineStyle = .solid,
    lineWidth: Double = 1.0
  ) {
    referenceLines.append(
      ReferenceLine(
        axis: .vertical(x: x),
        color: color, lineStyle: lineStyle, lineWidth: lineWidth))
  }

  /// Shades a horizontal band between ymin and ymax.
  public func axhspan(
    ymin: Double, ymax: Double,
    color: Color = .blue, alpha: Double = 0.3
  ) {
    referenceSpans.append(
      ReferenceSpan(
        axis: .horizontal(yMin: ymin, yMax: ymax),
        color: color, alpha: alpha))
  }

  /// Shades a vertical band between xmin and xmax.
  public func axvspan(
    xmin: Double, xmax: Double,
    color: Color = .blue, alpha: Double = 0.3
  ) {
    referenceSpans.append(
      ReferenceSpan(
        axis: .vertical(xMin: xmin, xMax: xmax),
        color: color, alpha: alpha))
  }

  /// Fills the area between two y-value curves (or a curve and zero).
  public func fillBetween(
    _ x: [Double], _ y1: [Double], _ y2: [Double]? = nil,
    color: Color? = nil, alpha: Double = 0.3,
    edgeColor: Color? = nil, edgeWidth: Double = 0,
    label: String? = nil
  ) {
    let fill = FillBetween(
      x: x, y1: y1, y2: y2,
      color: color ?? colorCycle.next(),
      alpha: alpha, edgeColor: edgeColor,
      edgeWidth: edgeWidth, label: label)
    fillBetweens.append(fill)
  }

  /// Plots data points with error bars.
  @discardableResult
  public func errorbar(
    _ x: [Double], _ y: [Double],
    yerr: ErrorBarValue? = nil,
    xerr: ErrorBarValue? = nil,
    color: Color? = nil,
    lineStyle: LineStyle = .solid,
    lineWidth: Double = 1.5,
    capsize: Double = 3.0,
    marker: MarkerStyle = .circle,
    label: String? = nil
  ) -> DataSeries {
    let series = plot(
      x, y, color: color, lineStyle: lineStyle,
      lineWidth: lineWidth, marker: marker, label: label)

    // Store error bar data as an annotation-like structure
    // Error bars are rendered during the axes render pass
    let errAnnotation = ErrorBarData(
      x: x, y: y,
      yerr: yerr, xerr: xerr,
      color: series.color,
      lineWidth: lineWidth,
      capsize: capsize)
    errorBarData.append(errAnnotation)
    return series
  }
}

// MARK: - ErrorBarData

/// Internal storage for error bar rendering data.
struct ErrorBarData {
  let x: [Double]
  let y: [Double]
  let yerr: ErrorBarValue?
  let xerr: ErrorBarValue?
  let color: Color
  let lineWidth: Double
  let capsize: Double
}

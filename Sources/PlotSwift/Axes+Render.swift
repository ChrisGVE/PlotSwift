//
//  Axes+Render.swift
//  PlotSwift
//
//  Rendering logic for the Axes class.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - Axes rendering

extension Axes {

  // MARK: Public entry point

  /// Renders everything — background, grid, axes frame, data series, labels, legend.
  /// - Parameter context: The drawing context that receives all drawing commands.
  public func render(to context: DrawingContext) {
    let rect = plotArea.plotRect
    let limits = effectiveLimits()
    let transform = LinearTransform(
      dataXRange: limits.xRange,
      dataYRange: limits.yRange,
      pixelBounds: rect)
    let tickGen = TickGenerator()
    let xTicks = tickGen.generateTicks(range: limits.xRange)
    let yTicks = tickGen.generateTicks(range: limits.yRange)

    renderBackground(context, rect: rect)
    renderSpans(context, transform: transform, limits: limits)
    if showGrid { renderGrid(context, transform: transform, xTicks: xTicks, yTicks: yTicks) }
    renderFillBetweens(context, transform: transform)
    renderBarSeriesList(context, transform: transform)
    renderAxesFrame(context, rect: rect)
    renderXTicks(context, transform: transform, ticks: xTicks, rect: rect)
    renderYTicks(context, transform: transform, ticks: yTicks, rect: rect)
    renderSeries(context, transform: transform)
    renderErrorBars(context, transform: transform)
    renderRefLines(context, transform: transform, limits: limits)
    renderAnnotationItems(context, transform: transform)
    renderLabels(context, rect: rect)
  }

  // MARK: Background

  private func renderBackground(_ context: DrawingContext, rect: CGRect) {
    context.saveState()
    context.setFillColor(.white)
    context.rect(
      Double(rect.minX), Double(rect.minY),
      Double(rect.width), Double(rect.height))
    context.fillPath()
    context.restoreState()
  }

  // MARK: Axes frame

  private func renderAxesFrame(_ context: DrawingContext, rect: CGRect) {
    context.saveState()
    context.setStrokeColor(.darkGray)
    context.setStrokeWidth(1.0)
    context.rect(
      Double(rect.minX), Double(rect.minY),
      Double(rect.width), Double(rect.height))
    context.strokePath()
    context.restoreState()
  }

  // MARK: Grid

  private func renderGrid(
    _ context: DrawingContext,
    transform: LinearTransform,
    xTicks: [Double],
    yTicks: [Double]
  ) {
    let rect = plotArea.plotRect
    context.saveState()
    context.setStrokeColor(gridColor)
    context.setStrokeWidth(gridLineWidth)
    context.setStrokeStyle(gridLineStyle)
    for tick in xTicks {
      let (px, _) = transform.dataToPixel(x: tick, y: 0)
      context.moveTo(px, Double(rect.minY))
      context.lineTo(px, Double(rect.maxY))
      context.strokePath()
    }
    for tick in yTicks {
      let (_, py) = transform.dataToPixel(x: 0, y: tick)
      context.moveTo(Double(rect.minX), py)
      context.lineTo(Double(rect.maxX), py)
      context.strokePath()
    }
    context.restoreState()
  }

  // MARK: Ticks

  private func renderXTicks(
    _ context: DrawingContext,
    transform: LinearTransform,
    ticks: [Double],
    rect: CGRect
  ) {
    let formatter = DefaultTickFormatter()
    let tickLen: Double = 5
    context.saveState()
    context.setStrokeColor(.darkGray)
    context.setStrokeWidth(1.0)
    let labelStyle = TextStyle(fontSize: 10, anchor: .middle)
    for tick in ticks {
      let (px, _) = transform.dataToPixel(x: tick, y: 0)
      let base = Double(rect.maxY)
      context.moveTo(px, base)
      context.lineTo(px, base + tickLen)
      context.strokePath()
      context.text(formatter.format(tick), x: px, y: base + tickLen + 12, style: labelStyle)
    }
    context.restoreState()
  }

  private func renderYTicks(
    _ context: DrawingContext,
    transform: LinearTransform,
    ticks: [Double],
    rect: CGRect
  ) {
    let formatter = DefaultTickFormatter()
    let tickLen: Double = 5
    context.saveState()
    context.setStrokeColor(.darkGray)
    context.setStrokeWidth(1.0)
    let labelStyle = TextStyle(fontSize: 10, anchor: .end)
    for tick in ticks {
      let (_, py) = transform.dataToPixel(x: 0, y: tick)
      let base = Double(rect.minX)
      context.moveTo(base, py)
      context.lineTo(base - tickLen, py)
      context.strokePath()
      context.text(formatter.format(tick), x: base - tickLen - 4, y: py, style: labelStyle)
    }
    context.restoreState()
  }

  // MARK: Data series

  private func renderSeries(_ context: DrawingContext, transform: LinearTransform) {
    for series in dataSeries {
      switch series.seriesType {
      case .line:
        renderLineSeries(context, series: series, transform: transform)
      case .scatter:
        renderScatterSeries(context, series: series, transform: transform)
      case .bar:
        renderBarSeries(context, series: series, transform: transform)
      }
    }
  }

  private func renderLineSeries(
    _ context: DrawingContext,
    series: DataSeries,
    transform: LinearTransform
  ) {
    guard series.x.count == series.y.count, !series.x.isEmpty else { return }
    context.saveState()
    if series.lineStyle != .none {
      context.setStrokeColor(series.color)
      context.setStrokeWidth(series.lineWidth)
      context.setStrokeStyle(series.lineStyle)
      let (x0, y0) = transform.dataToPixel(x: series.x[0], y: series.y[0])
      context.moveTo(x0, y0)
      for i in 1..<series.x.count {
        let (px, py) = transform.dataToPixel(x: series.x[i], y: series.y[i])
        context.lineTo(px, py)
      }
      context.strokePath()
    }
    if series.marker != .none {
      context.setFillColor(series.color)
      for i in 0..<series.x.count {
        let (px, py) = transform.dataToPixel(x: series.x[i], y: series.y[i])
        context.drawMarker(style: series.marker, x: px, y: py, size: series.markerSize)
      }
    }
    context.restoreState()
  }

  private func renderScatterSeries(
    _ context: DrawingContext,
    series: DataSeries,
    transform: LinearTransform
  ) {
    guard series.x.count == series.y.count, !series.x.isEmpty else { return }
    context.saveState()
    context.setFillColor(series.color)
    context.setAlpha(series.color.alpha)
    for i in 0..<series.x.count {
      let (px, py) = transform.dataToPixel(x: series.x[i], y: series.y[i])
      context.drawMarker(style: series.marker, x: px, y: py, size: series.markerSize)
    }
    context.restoreState()
  }

  private func renderBarSeries(
    _ context: DrawingContext,
    series: DataSeries,
    transform: LinearTransform
  ) {
    guard series.x.count == series.y.count, !series.x.isEmpty else { return }
    context.saveState()
    context.setFillColor(series.color)
    let rect = plotArea.plotRect
    let barWidth =
      series.x.count > 1
      ? abs(
        transform.dataToPixel(x: series.x[1], y: 0).0
          - transform.dataToPixel(x: series.x[0], y: 0).0) * 0.8
      : 20.0
    for i in 0..<series.x.count {
      let (px, py) = transform.dataToPixel(x: series.x[i], y: series.y[i])
      let (_, base) = transform.dataToPixel(x: 0, y: 0)
      let clampedBase = min(max(base, Double(rect.minY)), Double(rect.maxY))
      let barH = clampedBase - py
      context.rect(px - barWidth / 2, py, barWidth, barH)
      context.fillPath()
    }
    context.restoreState()
  }

  // MARK: Labels

  private func renderLabels(_ context: DrawingContext, rect: CGRect) {
    let bounds = plotArea.bounds
    if let t = title {
      let style = titleStyle ?? TextStyle(fontSize: 14, fontWeight: .bold, anchor: .middle)
      let cx = Double(rect.minX) + Double(rect.width) / 2
      context.text(t, x: cx, y: Double(bounds.minY) + 20, style: style)
    }
    if let xl = xLabel {
      let style = xLabelStyle ?? TextStyle(fontSize: 12, anchor: .middle)
      let cx = Double(rect.minX) + Double(rect.width) / 2
      context.text(xl, x: cx, y: Double(bounds.maxY) - 8, style: style)
    }
    if let yl = yLabel {
      let style = yLabelStyle ?? TextStyle(fontSize: 12, anchor: .middle)
      let cy = Double(rect.minY) + Double(rect.height) / 2
      context.text(yl, x: Double(bounds.minX) + 14, y: cy, style: style)
    }
    if showLegend { renderLegend(context, rect: rect) }
  }

  // MARK: Legend

  private func renderLegend(_ context: DrawingContext, rect: CGRect) {
    let labeled = dataSeries.filter { $0.label != nil }
    guard !labeled.isEmpty else { return }
    let lineH: Double = 18
    let pad: Double = 8
    let swatchW: Double = 20
    let boxW: Double = 120
    let boxH = Double(labeled.count) * lineH + pad * 2
    let origin = legendOrigin(rect: rect, boxWidth: boxW, boxHeight: boxH)
    context.saveState()
    context.setFillColor(Color(red: 1, green: 1, blue: 1, alpha: 0.85))
    context.rect(origin.x, origin.y, boxW, boxH)
    context.fillPath()
    context.setStrokeColor(.darkGray)
    context.setStrokeWidth(0.5)
    context.rect(origin.x, origin.y, boxW, boxH)
    context.strokePath()
    let labelStyle = TextStyle(fontSize: 10, anchor: .start)
    for (idx, series) in labeled.enumerated() {
      let y = origin.y + pad + Double(idx) * lineH + lineH / 2
      context.setStrokeColor(series.color)
      context.setStrokeWidth(series.lineWidth > 0 ? series.lineWidth : 1.5)
      context.moveTo(origin.x + pad, y)
      context.lineTo(origin.x + pad + swatchW, y)
      context.strokePath()
      context.text(series.label!, x: origin.x + pad + swatchW + 4, y: y + 4, style: labelStyle)
    }
    context.restoreState()
  }

  private func legendOrigin(rect: CGRect, boxWidth: Double, boxHeight: Double) -> (
    x: Double, y: Double
  ) {
    let pad: Double = 8
    switch legendPosition {
    case .topRight:
      return (Double(rect.maxX) - boxWidth - pad, Double(rect.minY) + pad)
    case .topLeft:
      return (Double(rect.minX) + pad, Double(rect.minY) + pad)
    case .bottomRight:
      return (Double(rect.maxX) - boxWidth - pad, Double(rect.maxY) - boxHeight - pad)
    case .bottomLeft:
      return (Double(rect.minX) + pad, Double(rect.maxY) - boxHeight - pad)
    }
  }

  // MARK: Auto-limits

  /// Computes the effective x/y axis limits from explicit settings or data ranges.
  internal func effectiveLimits() -> AxisLimits {
    let xData: DataRange
    if let xl = xLimits {
      xData = xl
    } else {
      var allX = dataSeries.flatMap { $0.x }
      for b in barSeriesList {
        allX.append(contentsOf: b.x.map { $0 - b.width / 2 })
        allX.append(contentsOf: b.x.map { $0 + b.width / 2 })
      }
      for f in fillBetweens { allX.append(contentsOf: f.x) }
      xData = DataRange.from(allX) ?? DataRange(min: 0, max: 1)
    }
    let yData: DataRange
    if let yl = yLimits {
      yData = yl
    } else {
      var allY = dataSeries.flatMap { $0.y }
      for b in barSeriesList {
        for (i, h) in b.heights.enumerated() {
          let base = i < b.bottom.count ? b.bottom[i] : 0
          allY.append(base)
          allY.append(base + h)
        }
      }
      for f in fillBetweens {
        allY.append(contentsOf: f.y1)
        if let y2 = f.y2 { allY.append(contentsOf: y2) } else { allY.append(0) }
      }
      yData = DataRange.from(allY) ?? DataRange(min: 0, max: 1)
    }
    return AxisLimits(xRange: xData, yRange: yData)
      .withPadding(0.05)
      .niceExpanded()
  }
}

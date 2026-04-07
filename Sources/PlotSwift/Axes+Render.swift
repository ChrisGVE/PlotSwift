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

  // MARK: BarSeriesList rendering

  private func renderBarSeriesList(_ context: DrawingContext, transform: LinearTransform) {
    for bar in barSeriesList {
      context.saveState()
      for i in 0..<bar.x.count {
        let base = i < bar.bottom.count ? bar.bottom[i] : 0
        let top = base + bar.heights[i]
        let (px1, py1) = transform.dataToPixel(x: bar.x[i] - bar.width / 2, y: base)
        let (px2, py2) = transform.dataToPixel(x: bar.x[i] + bar.width / 2, y: top)
        context.setFillColor(bar.color)
        context.setStrokeColor(bar.edgeColor)
        context.setStrokeWidth(bar.edgeWidth)
        context.rect(min(px1, px2), min(py1, py2), abs(px2 - px1), abs(py2 - py1))
        context.fillAndStrokePath()
      }
      context.restoreState()
    }
  }

  // MARK: FillBetween rendering

  private func renderFillBetweens(_ context: DrawingContext, transform: LinearTransform) {
    for fill in fillBetweens {
      guard fill.x.count >= 2, fill.x.count == fill.y1.count else { continue }
      let y2 = fill.y2 ?? Array(repeating: 0, count: fill.x.count)
      guard y2.count == fill.x.count else { continue }
      context.saveState()
      context.setFillColor(fill.color.withAlpha(fill.alpha))
      let (sx, sy) = transform.dataToPixel(x: fill.x[0], y: fill.y1[0])
      context.moveTo(sx, sy)
      for i in 1..<fill.x.count {
        let (px, py) = transform.dataToPixel(x: fill.x[i], y: fill.y1[i])
        context.lineTo(px, py)
      }
      for i in stride(from: fill.x.count - 1, through: 0, by: -1) {
        let (px, py) = transform.dataToPixel(x: fill.x[i], y: y2[i])
        context.lineTo(px, py)
      }
      context.closePath()
      context.fillPath()
      context.restoreState()
    }
  }

  // MARK: Reference lines

  private func renderRefLines(
    _ context: DrawingContext, transform: LinearTransform, limits: AxisLimits
  ) {
    for line in referenceLines {
      context.saveState()
      context.setStrokeColor(line.color)
      context.setStrokeWidth(line.lineWidth)
      context.setStrokeStyle(line.lineStyle)
      switch line.axis {
      case .horizontal(let y):
        let (px1, py) = transform.dataToPixel(x: limits.xRange.min, y: y)
        let (px2, _) = transform.dataToPixel(x: limits.xRange.max, y: y)
        context.moveTo(px1, py)
        context.lineTo(px2, py)
      case .vertical(let x):
        let (px, py1) = transform.dataToPixel(x: x, y: limits.yRange.min)
        let (_, py2) = transform.dataToPixel(x: x, y: limits.yRange.max)
        context.moveTo(px, py1)
        context.lineTo(px, py2)
      }
      context.strokePath()
      context.restoreState()
    }
  }

  // MARK: Reference spans

  private func renderSpans(
    _ context: DrawingContext, transform: LinearTransform, limits: AxisLimits
  ) {
    for span in referenceSpans {
      context.saveState()
      context.setFillColor(span.color.withAlpha(span.alpha))
      switch span.axis {
      case .horizontal(let yMin, let yMax):
        let (px1, py1) = transform.dataToPixel(x: limits.xRange.min, y: yMin)
        let (px2, py2) = transform.dataToPixel(x: limits.xRange.max, y: yMax)
        context.rect(min(px1, px2), min(py1, py2), abs(px2 - px1), abs(py2 - py1))
      case .vertical(let xMin, let xMax):
        let (px1, py1) = transform.dataToPixel(x: xMin, y: limits.yRange.min)
        let (px2, py2) = transform.dataToPixel(x: xMax, y: limits.yRange.max)
        context.rect(min(px1, px2), min(py1, py2), abs(px2 - px1), abs(py2 - py1))
      }
      context.fillPath()
      context.restoreState()
    }
  }

  // MARK: Error bars

  private func renderErrorBars(_ context: DrawingContext, transform: LinearTransform) {
    for eb in errorBarData {
      context.saveState()
      context.setStrokeColor(eb.color)
      context.setStrokeWidth(eb.lineWidth)
      for i in 0..<eb.x.count {
        let (px, py) = transform.dataToPixel(x: eb.x[i], y: eb.y[i])
        if let yerr = eb.yerr {
          let (lo, hi) = yerr.resolve(at: i)
          let (_, pyLo) = transform.dataToPixel(x: eb.x[i], y: eb.y[i] - lo)
          let (_, pyHi) = transform.dataToPixel(x: eb.x[i], y: eb.y[i] + hi)
          context.moveTo(px, pyLo)
          context.lineTo(px, pyHi)
          context.strokePath()
          context.moveTo(px - eb.capsize, pyLo)
          context.lineTo(px + eb.capsize, pyLo)
          context.strokePath()
          context.moveTo(px - eb.capsize, pyHi)
          context.lineTo(px + eb.capsize, pyHi)
          context.strokePath()
        }
        if let xerr = eb.xerr {
          let (lo, hi) = xerr.resolve(at: i)
          let (pxLo, _) = transform.dataToPixel(x: eb.x[i] - lo, y: eb.y[i])
          let (pxHi, _) = transform.dataToPixel(x: eb.x[i] + hi, y: eb.y[i])
          context.moveTo(pxLo, py)
          context.lineTo(pxHi, py)
          context.strokePath()
          context.moveTo(pxLo, py - eb.capsize)
          context.lineTo(pxLo, py + eb.capsize)
          context.strokePath()
          context.moveTo(pxHi, py - eb.capsize)
          context.lineTo(pxHi, py + eb.capsize)
          context.strokePath()
        }
      }
      context.restoreState()
    }
  }

  // MARK: Annotations

  private func renderAnnotationItems(_ context: DrawingContext, transform: LinearTransform) {
    for ann in annotations {
      let (px, py) = transform.dataToPixel(x: ann.point.0, y: ann.point.1)
      let tp: (Double, Double)
      if let t = ann.textPosition {
        tp = transform.dataToPixel(x: t.0, y: t.1)
      } else {
        tp = (px, py)
      }
      if let arrow = ann.arrowProps, ann.textPosition != nil {
        context.saveState()
        context.setStrokeColor(arrow.color)
        context.setStrokeWidth(arrow.lineWidth)
        context.moveTo(tp.0, tp.1)
        context.lineTo(px, py)
        context.strokePath()
        let dx = px - tp.0
        let dy = py - tp.1
        let len = sqrt(dx * dx + dy * dy)
        if len > 0 {
          let hl = 8.0
          let ux = dx / len
          let uy = dy / len
          context.moveTo(px, py)
          context.lineTo(px - hl * ux + 3 * uy, py - hl * uy - 3 * ux)
          context.moveTo(px, py)
          context.lineTo(px - hl * ux - 3 * uy, py - hl * uy + 3 * ux)
          context.strokePath()
        }
        context.restoreState()
      }
      context.text(
        ann.text, x: tp.0, y: tp.1,
        style: TextStyle(fontSize: ann.fontSize, color: ann.color))
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

//
//  Axes+Decorations.swift
//  PlotSwift
//
//  Decoration rendering methods for Axes: bars, fills, reference lines,
//  spans, error bars, and annotations.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - Axes decoration rendering

extension Axes {

  // MARK: BarSeriesList rendering

  func renderBarSeriesList(_ context: DrawingContext, transform: LinearTransform) {
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

  func renderFillBetweens(_ context: DrawingContext, transform: LinearTransform) {
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

  // MARK: Polygon rendering

  func renderPolygons(_ context: DrawingContext, transform: LinearTransform) {
    for poly in polygonSeries {
      guard poly.xs.count >= 3, poly.xs.count == poly.ys.count else { continue }
      context.saveState()
      context.setFillColor(poly.fillColor.withAlpha(poly.alpha))
      let (sx, sy) = transform.dataToPixel(x: poly.xs[0], y: poly.ys[0])
      context.moveTo(sx, sy)
      for i in 1..<poly.xs.count {
        let (px, py) = transform.dataToPixel(x: poly.xs[i], y: poly.ys[i])
        context.lineTo(px, py)
      }
      context.closePath()
      context.fillPath()
      if let edge = poly.edgeColor, poly.edgeWidth > 0 {
        context.setStrokeColor(edge)
        context.setStrokeWidth(poly.edgeWidth)
        let (sx2, sy2) = transform.dataToPixel(x: poly.xs[0], y: poly.ys[0])
        context.moveTo(sx2, sy2)
        for i in 1..<poly.xs.count {
          let (px, py) = transform.dataToPixel(x: poly.xs[i], y: poly.ys[i])
          context.lineTo(px, py)
        }
        context.closePath()
        context.strokePath()
      }
      context.restoreState()
    }
  }

  // MARK: Reference lines

  func renderRefLines(
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

  func renderSpans(
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

  func renderErrorBars(_ context: DrawingContext, transform: LinearTransform) {
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
          renderYErrorBar(context, px: px, pyLo: pyLo, pyHi: pyHi, capsize: eb.capsize)
        }
        if let xerr = eb.xerr {
          let (lo, hi) = xerr.resolve(at: i)
          let (pxLo, _) = transform.dataToPixel(x: eb.x[i] - lo, y: eb.y[i])
          let (pxHi, _) = transform.dataToPixel(x: eb.x[i] + hi, y: eb.y[i])
          renderXErrorBar(context, py: py, pxLo: pxLo, pxHi: pxHi, capsize: eb.capsize)
        }
      }
      context.restoreState()
    }
  }

  // MARK: Annotations

  func renderAnnotationItems(_ context: DrawingContext, transform: LinearTransform) {
    for ann in annotations {
      let (px, py) = transform.dataToPixel(x: ann.point.0, y: ann.point.1)
      let tp: (Double, Double)
      if let t = ann.textPosition {
        tp = transform.dataToPixel(x: t.0, y: t.1)
      } else {
        tp = (px, py)
      }
      if let arrow = ann.arrowProps, ann.textPosition != nil {
        renderAnnotationArrow(context, from: tp, to: (px, py), arrow: arrow)
      }
      context.text(
        ann.text, x: tp.0, y: tp.1,
        style: TextStyle(fontSize: ann.fontSize, color: ann.color))
    }
  }
}

// MARK: - Private helpers

extension Axes {

  private func renderYErrorBar(
    _ context: DrawingContext,
    px: Double, pyLo: Double, pyHi: Double, capsize: Double
  ) {
    context.moveTo(px, pyLo)
    context.lineTo(px, pyHi)
    context.strokePath()
    context.moveTo(px - capsize, pyLo)
    context.lineTo(px + capsize, pyLo)
    context.strokePath()
    context.moveTo(px - capsize, pyHi)
    context.lineTo(px + capsize, pyHi)
    context.strokePath()
  }

  private func renderXErrorBar(
    _ context: DrawingContext,
    py: Double, pxLo: Double, pxHi: Double, capsize: Double
  ) {
    context.moveTo(pxLo, py)
    context.lineTo(pxHi, py)
    context.strokePath()
    context.moveTo(pxLo, py - capsize)
    context.lineTo(pxLo, py + capsize)
    context.strokePath()
    context.moveTo(pxHi, py - capsize)
    context.lineTo(pxHi, py + capsize)
    context.strokePath()
  }

  private func renderAnnotationArrow(
    _ context: DrawingContext,
    from tp: (Double, Double), to target: (Double, Double),
    arrow: ArrowProps
  ) {
    context.saveState()
    context.setStrokeColor(arrow.color)
    context.setStrokeWidth(arrow.lineWidth)
    context.moveTo(tp.0, tp.1)
    context.lineTo(target.0, target.1)
    context.strokePath()
    let dx = target.0 - tp.0
    let dy = target.1 - tp.1
    let len = sqrt(dx * dx + dy * dy)
    if len > 0 {
      let hl = 8.0
      let ux = dx / len
      let uy = dy / len
      context.moveTo(target.0, target.1)
      context.lineTo(target.0 - hl * ux + 3 * uy, target.1 - hl * uy - 3 * ux)
      context.moveTo(target.0, target.1)
      context.lineTo(target.0 - hl * ux - 3 * uy, target.1 - hl * uy + 3 * ux)
      context.strokePath()
    }
    context.restoreState()
  }
}

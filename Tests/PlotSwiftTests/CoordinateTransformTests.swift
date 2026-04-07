//
//  CoordinateTransformTests.swift
//  PlotSwift
//
//  Tests for CoordinateTransform, LinearTransform, PlotArea, and EdgeInsets.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Testing

@testable import PlotSwift

// MARK: - LinearTransform tests

@Suite("LinearTransform")
struct LinearTransformTests {

  // Shared fixture: data [0, 10] x [0, 5] mapped to pixel rect (0,0) 100x200.
  private let transform = LinearTransform(
    dataXRange: DataRange(min: 0, max: 10),
    dataYRange: DataRange(min: 0, max: 5),
    pixelBounds: CGRect(x: 0, y: 0, width: 100, height: 200)
  )

  @Test("data minimum maps to pixel origin x")
  func dataMinMapsToPixelLeft() {
    let (px, _) = transform.dataToPixel(x: 0, y: 0)
    #expect(abs(px - 0) < 1e-10)
  }

  @Test("data maximum maps to pixel right edge")
  func dataMaxMapsToPixelRight() {
    let (px, _) = transform.dataToPixel(x: 10, y: 0)
    #expect(abs(px - 100) < 1e-10)
  }

  @Test("data y minimum maps to pixel bottom (maxY)")
  func dataYMinMapsToPixelBottom() {
    let (_, py) = transform.dataToPixel(x: 0, y: 0)
    #expect(abs(py - 200) < 1e-10)
  }

  @Test("data y maximum maps to pixel top (minY)")
  func dataYMaxMapsToPixelTop() {
    let (_, py) = transform.dataToPixel(x: 0, y: 5)
    #expect(abs(py - 0) < 1e-10)
  }

  @Test("midpoint maps to pixel centre")
  func midpointMapsToCenter() {
    let (px, py) = transform.dataToPixel(x: 5, y: 2.5)
    #expect(abs(px - 50) < 1e-10)
    #expect(abs(py - 100) < 1e-10)
  }

  @Test("pixel-to-data is inverse of data-to-pixel (round-trip)")
  func roundTrip() {
    let (px, py) = transform.dataToPixel(x: 3.7, y: 1.2)
    let (dx, dy) = transform.pixelToData(x: px, y: py)
    #expect(abs(dx - 3.7) < 1e-10)
    #expect(abs(dy - 1.2) < 1e-10)
  }

  @Test("y-axis inversion: higher data y gives smaller pixel y")
  func yAxisInversion() {
    let (_, py1) = transform.dataToPixel(x: 0, y: 1)
    let (_, py2) = transform.dataToPixel(x: 0, y: 4)
    #expect(py2 < py1)
  }

  @Test("negative data ranges transform correctly")
  func negativeDataRange() {
    let neg = LinearTransform(
      dataXRange: DataRange(min: -10, max: -2),
      dataYRange: DataRange(min: -5, max: -1),
      pixelBounds: CGRect(x: 0, y: 0, width: 80, height: 40)
    )
    let (px, py) = neg.dataToPixel(x: -10, y: -5)
    #expect(abs(px - 0) < 1e-10)
    #expect(abs(py - 40) < 1e-10)

    let (px2, py2) = neg.dataToPixel(x: -2, y: -1)
    #expect(abs(px2 - 80) < 1e-10)
    #expect(abs(py2 - 0) < 1e-10)
  }

  @Test("negative data range round-trip")
  func negativeRoundTrip() {
    let neg = LinearTransform(
      dataXRange: DataRange(min: -10, max: -2),
      dataYRange: DataRange(min: -5, max: -1),
      pixelBounds: CGRect(x: 0, y: 0, width: 80, height: 40)
    )
    let (px, py) = neg.dataToPixel(x: -6, y: -3)
    let (dx, dy) = neg.pixelToData(x: px, y: py)
    #expect(abs(dx - (-6)) < 1e-10)
    #expect(abs(dy - (-3)) < 1e-10)
  }

  @Test("offset pixelBounds are respected")
  func offsetPixelBounds() {
    let offset = LinearTransform(
      dataXRange: DataRange(min: 0, max: 1),
      dataYRange: DataRange(min: 0, max: 1),
      pixelBounds: CGRect(x: 50, y: 30, width: 100, height: 80)
    )
    let (px, py) = offset.dataToPixel(x: 0, y: 0)
    #expect(abs(px - 50) < 1e-10)
    #expect(abs(py - 110) < 1e-10)  // minY(30) + height(80)
  }
}

// MARK: - PlotArea tests

@Suite("PlotArea")
struct PlotAreaTests {

  @Test("plotRect insets bounds by default margins")
  func defaultMargins() {
    let area = PlotArea(bounds: CGRect(x: 0, y: 0, width: 800, height: 600))
    let rect = area.plotRect
    let m = EdgeInsets.defaultPlotMargins
    #expect(abs(Double(rect.minX) - m.left) < 1e-10)
    #expect(abs(Double(rect.minY) - m.top) < 1e-10)
    #expect(abs(Double(rect.width) - (800 - m.left - m.right)) < 1e-10)
    #expect(abs(Double(rect.height) - (600 - m.top - m.bottom)) < 1e-10)
  }

  @Test("custom margins produce correct plotRect")
  func customMargins() {
    let insets = EdgeInsets(top: 10, bottom: 20, left: 30, right: 40)
    let area = PlotArea(bounds: CGRect(x: 0, y: 0, width: 200, height: 100), margins: insets)
    let rect = area.plotRect
    #expect(abs(Double(rect.minX) - 30) < 1e-10)
    #expect(abs(Double(rect.minY) - 10) < 1e-10)
    #expect(abs(Double(rect.width) - 130) < 1e-10)
    #expect(abs(Double(rect.height) - 70) < 1e-10)
  }

  @Test("defaultPlotMargins has expected values")
  func defaultMarginValues() {
    let m = EdgeInsets.defaultPlotMargins
    #expect(m.top == 40)
    #expect(m.bottom == 60)
    #expect(m.left == 70)
    #expect(m.right == 20)
  }

  @Test("bounds property is preserved")
  func boundsPreserved() {
    let b = CGRect(x: 5, y: 10, width: 400, height: 300)
    let area = PlotArea(bounds: b)
    #expect(area.bounds == b)
  }
}

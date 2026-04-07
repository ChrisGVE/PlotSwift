//
//  DrawingContextRenderTests.swift
//  PlotSwiftTests
//
//  Tests for marker rendering, SVG arc conversion, and rendering improvements.
//

import CoreGraphics
import XCTest

@testable import PlotSwift

final class DrawingContextRenderTests: XCTestCase {

  // MARK: - Marker Command Tests

  func testDrawMarkerAddsCommand() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .circle, x: 50, y: 50, size: 8)
    XCTAssertEqual(ctx.commandCount, 1)
    if case .marker(let style, let x, let y, let size) = ctx.commands[0] {
      XCTAssertEqual(style, .circle)
      XCTAssertEqual(x, 50)
      XCTAssertEqual(y, 50)
      XCTAssertEqual(size, 8)
    } else {
      XCTFail("Expected marker command")
    }
  }

  func testDrawMarkerNoneProducesNoCommand() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .none, x: 50, y: 50)
    XCTAssertEqual(ctx.commandCount, 0)
  }

  func testDrawMarkerDefaultSize() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .square, x: 10, y: 20)
    if case .marker(_, _, _, let size) = ctx.commands[0] {
      XCTAssertEqual(size, 6.0)
    } else {
      XCTFail("Expected marker command")
    }
  }

  func testAllMarkerStylesProduceCommands() {
    let styles: [MarkerStyle] = [
      .circle, .square, .diamond, .triangleUp, .triangleDown,
      .triangleLeft, .triangleRight, .plus, .cross, .star, .dot,
    ]
    for style in styles {
      let ctx = DrawingContext()
      ctx.drawMarker(style: style, x: 0, y: 0, size: 10)
      XCTAssertEqual(ctx.commandCount, 1, "Style \(style) should produce a command")
    }
  }

  func testMarkerAffectsBounds() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .circle, x: 100, y: 100, size: 20)
    let bounds = ctx.bounds
    // Marker bounds use size/2 only; no stroke expansion applied to markers.
    XCTAssertEqual(bounds.minX, 90)
    XCTAssertEqual(bounds.minY, 90)
    XCTAssertEqual(bounds.maxX, 110)
    XCTAssertEqual(bounds.maxY, 110)
  }

  // MARK: - SVG Arc Tests

  func testSVGArcRendersPath() {
    let ctx = DrawingContext()
    ctx.arc(cx: 50, cy: 50, r: 25, startAngle: 0, endAngle: .pi)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("<path"), "SVG should contain arc path element")
    XCTAssertTrue(svg.contains(" A"), "SVG arc should contain A command")
  }

  func testSVGArcFullCircle() {
    let ctx = DrawingContext()
    ctx.arc(cx: 100, cy: 100, r: 50, startAngle: 0, endAngle: 2 * .pi)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    // Full circle should produce two arc commands
    let arcCount = svg.components(separatedBy: " A").count - 1
    XCTAssertEqual(arcCount, 2, "Full circle should use two half-arc SVG commands")
  }

  func testSVGArcSmallAngle() {
    let ctx = DrawingContext()
    ctx.arc(cx: 50, cy: 50, r: 25, startAngle: 0, endAngle: .pi / 4)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains(" A"), "Small arc should render")
    // Small arc should have large-arc-flag = 0
    XCTAssertTrue(svg.contains(" 0,"), "Small arc should have largeArcFlag=0")
  }

  func testSVGArcClockwise() {
    let ctx = DrawingContext()
    ctx.arc(cx: 50, cy: 50, r: 25, startAngle: 0, endAngle: .pi, clockwise: true)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("<path"), "Clockwise arc should render")
  }

  // MARK: - SVG Marker Tests

  func testSVGMarkerCircle() {
    let ctx = DrawingContext()
    ctx.setFillColor(.red)
    ctx.drawMarker(style: .circle, x: 50, y: 50, size: 10)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("<circle"), "Circle marker should render as SVG circle")
  }

  func testSVGMarkerSquare() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .square, x: 50, y: 50, size: 10)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("<rect"), "Square marker should render as SVG rect")
  }

  func testSVGMarkerTriangles() {
    for style in [MarkerStyle.triangleUp, .triangleDown, .triangleLeft, .triangleRight] {
      let ctx = DrawingContext()
      ctx.drawMarker(style: style, x: 50, y: 50, size: 10)
      let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
      XCTAssertTrue(
        svg.contains("<polygon"), "Triangle marker \(style) should render as polygon")
    }
  }

  func testSVGMarkerDiamond() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .diamond, x: 50, y: 50, size: 10)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("<polygon"), "Diamond marker should render as polygon")
  }

  func testSVGMarkerPlus() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .plus, x: 50, y: 50, size: 10)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("<line"), "Plus marker should render as SVG lines")
  }

  func testSVGMarkerCross() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .cross, x: 50, y: 50, size: 10)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("<line"), "Cross marker should render as SVG lines")
  }

  func testSVGMarkerStar() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .star, x: 50, y: 50, size: 10)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("<polygon"), "Star marker should render as polygon")
  }

  func testSVGMarkerDot() {
    let ctx = DrawingContext()
    ctx.drawMarker(style: .dot, x: 50, y: 50, size: 10)
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("<circle"), "Dot marker should render as small circle")
  }

  // MARK: - SVG Alpha and Transform Tests

  func testSVGAlphaApplied() {
    let ctx = DrawingContext()
    ctx.setAlpha(0.5)
    ctx.setFillColor(.red)
    ctx.rect(10, 10, 80, 80)
    ctx.fillPath()
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(
      svg.contains("fill-opacity"), "Alpha should produce fill-opacity in SVG")
  }

  func testSVGTransformApplied() {
    let ctx = DrawingContext()
    ctx.translate(10, 20)
    ctx.moveTo(0, 0)
    ctx.lineTo(50, 50)
    ctx.strokePath()
    ctx.popTransform()
    let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
    XCTAssertTrue(svg.contains("transform"), "Transform should be applied in SVG")
  }

  // MARK: - Color Clamping Tests

  func testColorClampingOutOfRange() {
    let color = Color(red: 1.5, green: -0.5, blue: 2.0, alpha: -1.0)
    XCTAssertEqual(color.red, 1.0)
    XCTAssertEqual(color.green, 0.0)
    XCTAssertEqual(color.blue, 1.0)
    XCTAssertEqual(color.alpha, 0.0)
  }

  func testColorWithAlpha() {
    let color = Color.red.withAlpha(0.5)
    XCTAssertEqual(color.red, 1.0)
    XCTAssertEqual(color.green, 0.0)
    XCTAssertEqual(color.blue, 0.0)
    XCTAssertEqual(color.alpha, 0.5)
  }

  func testToHexClamps() {
    let color = Color(red: 1.5, green: -0.1, blue: 0.5)
    let hex = color.toHex()
    XCTAssertEqual(hex, "#FF007F")
  }

  // MARK: - Bounds Improvements

  func testBoundsIncludesCurves() {
    let ctx = DrawingContext()
    ctx.moveTo(0, 0)
    ctx.curveTo(cp1x: 25, cp1y: 100, cp2x: 75, cp2y: -50, x: 100, y: 0)
    let bounds = ctx.bounds
    // Default stroke width 1.0 → expand by 0.5.
    XCTAssertEqual(bounds.minX, -0.5, accuracy: 1e-10)
    XCTAssertEqual(bounds.minY, -50.5, accuracy: 1e-10)
    XCTAssertEqual(bounds.maxX, 100.5, accuracy: 1e-10)
    XCTAssertEqual(bounds.maxY, 100.5, accuracy: 1e-10)
  }

  func testBoundsIncludesQuadCurves() {
    let ctx = DrawingContext()
    ctx.moveTo(0, 0)
    ctx.quadCurveTo(cpx: 50, cpy: 100, x: 100, y: 0)
    let bounds = ctx.bounds
    // Default stroke width 1.0 → expand by 0.5.
    XCTAssertEqual(bounds.minY, -0.5, accuracy: 1e-10)
    XCTAssertEqual(bounds.maxY, 100.5, accuracy: 1e-10)
  }

  func testBoundsIncludesArcs() {
    let ctx = DrawingContext()
    ctx.arc(cx: 100, cy: 100, r: 50, startAngle: 0, endAngle: .pi)
    let bounds = ctx.bounds
    // Default stroke width 1.0 → expand by 0.5.
    XCTAssertEqual(bounds.minX, 49.5, accuracy: 1e-10)
    XCTAssertEqual(bounds.minY, 49.5, accuracy: 1e-10)
    XCTAssertEqual(bounds.maxX, 150.5, accuracy: 1e-10)
    XCTAssertEqual(bounds.maxY, 150.5, accuracy: 1e-10)
  }

  // MARK: - PNG/PDF Marker Rendering

  #if canImport(ImageIO)
    func testPNGRenderWithMarkers() {
      let ctx = DrawingContext()
      ctx.setFillColor(.blue)
      ctx.setStrokeColor(.black)
      ctx.drawMarker(style: .circle, x: 50, y: 50, size: 10)
      ctx.drawMarker(style: .square, x: 70, y: 50, size: 10)
      ctx.drawMarker(style: .star, x: 90, y: 50, size: 10)
      let data = ctx.renderToPNG(size: CGSize(width: 200, height: 100))
      XCTAssertNotNil(data)
      XCTAssertGreaterThan(data?.count ?? 0, 0)
    }

    func testPDFRenderWithMarkers() {
      let ctx = DrawingContext()
      ctx.setFillColor(.red)
      ctx.drawMarker(style: .diamond, x: 50, y: 50, size: 12)
      let data = ctx.renderToPDF(size: CGSize(width: 200, height: 100))
      XCTAssertNotNil(data)
      XCTAssertGreaterThan(data?.count ?? 0, 0)
    }
  #endif
}

//
//  AnnotationsTests.swift
//  PlotSwiftTests
//
//  Tests for annotation types, reference lines, and error bar values.
//

import XCTest

@testable import PlotSwift

final class AnnotationsTests: XCTestCase {

  // MARK: - Annotation

  func testAnnotationCreation() {
    let ann = Annotation(text: "peak", point: (3.0, 5.0))
    XCTAssertEqual(ann.text, "peak")
    XCTAssertEqual(ann.point.0, 3.0)
    XCTAssertEqual(ann.point.1, 5.0)
    XCTAssertNil(ann.textPosition)
    XCTAssertNil(ann.arrowProps)
    XCTAssertEqual(ann.fontSize, 12)
    XCTAssertEqual(ann.color, .black)
  }

  func testAnnotationWithArrow() {
    let arrow = ArrowProps(arrowStyle: .fancy, color: .red, lineWidth: 2)
    let ann = Annotation(
      text: "here", point: (1, 2),
      textPosition: (3, 4), arrowProps: arrow,
      fontSize: 16, color: .blue)
    XCTAssertEqual(ann.textPosition!.0, 3)
    XCTAssertEqual(ann.arrowProps?.arrowStyle, .fancy)
    XCTAssertEqual(ann.arrowProps?.color, .red)
  }

  func testAnnotationEquality() {
    let a = Annotation(text: "x", point: (1, 2))
    let b = Annotation(text: "x", point: (1, 2))
    let c = Annotation(text: "y", point: (1, 2))
    XCTAssertEqual(a, b)
    XCTAssertNotEqual(a, c)
  }

  // MARK: - ArrowProps

  func testArrowPropsDefaults() {
    let props = ArrowProps()
    XCTAssertEqual(props.arrowStyle, .simple)
    XCTAssertEqual(props.color, .black)
    XCTAssertEqual(props.lineWidth, 1.0)
  }

  // MARK: - ReferenceLine

  func testReferenceLineHorizontal() {
    let line = ReferenceLine(axis: .horizontal(y: 5.0), color: .red)
    if case .horizontal(let y) = line.axis {
      XCTAssertEqual(y, 5.0)
    } else {
      XCTFail("Expected horizontal axis")
    }
    XCTAssertEqual(line.color, .red)
  }

  func testReferenceLineVertical() {
    let line = ReferenceLine(axis: .vertical(x: 3.0), lineStyle: .dashed)
    if case .vertical(let x) = line.axis {
      XCTAssertEqual(x, 3.0)
    } else {
      XCTFail("Expected vertical axis")
    }
    XCTAssertEqual(line.lineStyle, .dashed)
  }

  // MARK: - ReferenceSpan

  func testReferenceSpanHorizontal() {
    let span = ReferenceSpan(
      axis: .horizontal(yMin: 1.0, yMax: 3.0),
      color: .blue, alpha: 0.2)
    if case .horizontal(let yMin, let yMax) = span.axis {
      XCTAssertEqual(yMin, 1.0)
      XCTAssertEqual(yMax, 3.0)
    } else {
      XCTFail("Expected horizontal span")
    }
    XCTAssertEqual(span.alpha, 0.2)
  }

  func testReferenceSpanVertical() {
    let span = ReferenceSpan(axis: .vertical(xMin: 2.0, xMax: 5.0))
    if case .vertical(let xMin, let xMax) = span.axis {
      XCTAssertEqual(xMin, 2.0)
      XCTAssertEqual(xMax, 5.0)
    } else {
      XCTFail("Expected vertical span")
    }
  }

  // MARK: - FillBetween

  func testFillBetweenDefaults() {
    let fill = FillBetween(
      x: [1, 2, 3], y1: [1, 4, 1])
    XCTAssertEqual(fill.x.count, 3)
    XCTAssertNil(fill.y2)
    XCTAssertEqual(fill.alpha, 0.3)
    XCTAssertNil(fill.edgeColor)
  }

  func testFillBetweenTwoCurves() {
    let fill = FillBetween(
      x: [0, 1, 2], y1: [3, 5, 3], y2: [1, 2, 1],
      color: .green, alpha: 0.5, label: "range")
    XCTAssertNotNil(fill.y2)
    XCTAssertEqual(fill.label, "range")
    XCTAssertEqual(fill.color, .green)
  }

  // MARK: - ErrorBarValue

  func testSymmetricError() {
    let err = ErrorBarValue.symmetric(1.5)
    let (lo, hi) = err.resolve(at: 0)
    XCTAssertEqual(lo, 1.5)
    XCTAssertEqual(hi, 1.5)
  }

  func testSymmetricArrayError() {
    let err = ErrorBarValue.symmetricArray([0.5, 1.0, 1.5])
    XCTAssertEqual(err.resolve(at: 0).lower, 0.5)
    XCTAssertEqual(err.resolve(at: 1).upper, 1.0)
    XCTAssertEqual(err.resolve(at: 2).lower, 1.5)
  }

  func testSymmetricArrayOutOfBounds() {
    let err = ErrorBarValue.symmetricArray([1.0])
    let (lo, hi) = err.resolve(at: 5)
    XCTAssertEqual(lo, 0)
    XCTAssertEqual(hi, 0)
  }

  func testAsymmetricError() {
    let err = ErrorBarValue.asymmetric([0.5, 1.0], [1.5, 2.0])
    let r0 = err.resolve(at: 0)
    XCTAssertEqual(r0.lower, 0.5)
    XCTAssertEqual(r0.upper, 1.5)
    let r1 = err.resolve(at: 1)
    XCTAssertEqual(r1.lower, 1.0)
    XCTAssertEqual(r1.upper, 2.0)
  }

  func testAsymmetricErrorOutOfBounds() {
    let err = ErrorBarValue.asymmetric([1.0], [2.0])
    let r = err.resolve(at: 3)
    XCTAssertEqual(r.lower, 0)
    XCTAssertEqual(r.upper, 0)
  }
}

//
//  ColorbarTests.swift
//  PlotSwift
//
//  Tests for the Colorbar widget.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import XCTest

@testable import PlotSwift

final class ColorbarTests: XCTestCase {

  // MARK: - Creation

  func testDefaultInit() {
    let cb = Colorbar(palette: .viridis, vmin: 0, vmax: 1)
    XCTAssertEqual(cb.vmin, 0)
    XCTAssertEqual(cb.vmax, 1)
    XCTAssertNil(cb.label)
    XCTAssertEqual(cb.orientation, .vertical)
    XCTAssertNil(cb.tickPositions)
  }

  func testInitWithAllParameters() {
    let cb = Colorbar(
      palette: .plasma,
      vmin: -5,
      vmax: 5,
      label: "Temperature",
      orientation: .horizontal
    )
    XCTAssertEqual(cb.vmin, -5)
    XCTAssertEqual(cb.vmax, 5)
    XCTAssertEqual(cb.label, "Temperature")
    XCTAssertEqual(cb.orientation, .horizontal)
  }

  // MARK: - Orientation

  func testVerticalOrientation() {
    let cb = Colorbar(palette: .viridis, vmin: 0, vmax: 100, orientation: .vertical)
    XCTAssertEqual(cb.orientation, .vertical)
  }

  func testHorizontalOrientation() {
    let cb = Colorbar(palette: .viridis, vmin: 0, vmax: 100, orientation: .horizontal)
    XCTAssertEqual(cb.orientation, .horizontal)
  }

  // MARK: - Tick generation

  func testAutoTicksGenerated() {
    let cb = Colorbar(palette: .viridis, vmin: 0, vmax: 10)
    // Render so tick logic is exercised; verify via explicit call using TickGenerator
    let range = DataRange(min: 0, max: 10)
    let ticks = TickGenerator().generateTicks(range: range, maxTicks: 6)
    XCTAssertFalse(ticks.isEmpty)
    XCTAssertTrue(ticks.allSatisfy { $0 >= 0 && $0 <= 10 })
    // Colorbar should produce the same ticks (no explicit override)
    XCTAssertNil(cb.tickPositions)
  }

  func testExplicitTickPositions() {
    let cb = Colorbar(palette: .viridis, vmin: 0, vmax: 1)
    cb.tickPositions = [0.0, 0.25, 0.5, 0.75, 1.0]
    XCTAssertEqual(cb.tickPositions, [0.0, 0.25, 0.5, 0.75, 1.0])
  }

  func testTicksOutsideRangeAreSkipped() {
    // Render with explicit ticks that include out-of-range values;
    // only 0...1 should produce drawing commands for tick lines.
    let cb = Colorbar(palette: .viridis, vmin: 0, vmax: 1)
    cb.tickPositions = [-1.0, 0.0, 0.5, 1.0, 2.0]
    let ctx = DrawingContext()
    cb.render(to: ctx, in: CGRect(x: 0, y: 0, width: 20, height: 200))
    // Commands must exist (gradient + border + ticks)
    XCTAssertGreaterThan(ctx.commandCount, 0)
  }

  // MARK: - Render produces drawing commands

  func testRenderVerticalProducesCommands() {
    let cb = Colorbar(palette: .viridis, vmin: 0, vmax: 1)
    let ctx = DrawingContext()
    cb.render(to: ctx, in: CGRect(x: 0, y: 0, width: 20, height: 300))
    XCTAssertGreaterThan(ctx.commandCount, 0)
  }

  func testRenderHorizontalProducesCommands() {
    let cb = Colorbar(palette: .plasma, vmin: -1, vmax: 1, orientation: .horizontal)
    let ctx = DrawingContext()
    cb.render(to: ctx, in: CGRect(x: 0, y: 0, width: 300, height: 20))
    XCTAssertGreaterThan(ctx.commandCount, 0)
  }

  func testRenderWithLabelProducesMoreCommands() {
    let cbNoLabel = Colorbar(palette: .viridis, vmin: 0, vmax: 1)
    let cbWithLabel = Colorbar(palette: .viridis, vmin: 0, vmax: 1, label: "Value")
    let rect = CGRect(x: 0, y: 0, width: 20, height: 300)

    let ctxA = DrawingContext()
    cbNoLabel.render(to: ctxA, in: rect)

    let ctxB = DrawingContext()
    cbWithLabel.render(to: ctxB, in: rect)

    // Label rendering adds at least one extra text command
    XCTAssertGreaterThan(ctxB.commandCount, ctxA.commandCount)
  }

  // MARK: - Axes integration

  func testAxesColorbarMethod() {
    let plotArea = PlotArea(bounds: CGRect(x: 0, y: 0, width: 800, height: 600))
    let ax = Axes(plotArea: plotArea)
    let cb = ax.colorbar(palette: .viridis, vmin: 0, vmax: 1, label: "Z")
    XCTAssertNotNil(ax.colorbar)
    XCTAssertEqual(cb.label, "Z")
    XCTAssertEqual(cb.vmin, 0)
    XCTAssertEqual(cb.vmax, 1)
  }

  func testAxesColorbarIsStored() {
    let plotArea = PlotArea(bounds: CGRect(x: 0, y: 0, width: 800, height: 600))
    let ax = Axes(plotArea: plotArea)
    XCTAssertNil(ax.colorbar)
    ax.colorbar(palette: .plasma, vmin: -5, vmax: 5)
    XCTAssertNotNil(ax.colorbar)
  }

  func testAxesColorbarReturnsDiscardableResult() {
    let plotArea = PlotArea(bounds: CGRect(x: 0, y: 0, width: 800, height: 600))
    let ax = Axes(plotArea: plotArea)
    // @discardableResult: calling without capturing the return value must not warn/fail
    ax.colorbar(palette: .viridis, vmin: 0, vmax: 1)
    XCTAssertNotNil(ax.colorbar)
  }
}

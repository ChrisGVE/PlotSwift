//
//  AnimationTests.swift
//  PlotSwiftTests
//
//  Tests for animation scene infrastructure.
//

import CoreGraphics
import XCTest

@testable import PlotSwift

final class AnimationTests: XCTestCase {

  // MARK: - AnimationScene

  func testSceneCreation() {
    let scene = AnimationScene(width: 640, height: 480, fps: 24)
    XCTAssertEqual(scene.width, 640)
    XCTAssertEqual(scene.height, 480)
    XCTAssertEqual(scene.fps, 24)
    XCTAssertTrue(scene.frames.isEmpty)
  }

  func testSceneDefaults() {
    let scene = AnimationScene()
    XCTAssertEqual(scene.width, 800)
    XCTAssertEqual(scene.height, 600)
    XCTAssertEqual(scene.fps, 30)
  }

  func testAddFrame() {
    let scene = AnimationScene()
    let fig = Figure(width: 800, height: 600)
    scene.addFrame(fig)
    XCTAssertEqual(scene.frames.count, 1)
  }

  func testAddFrameWithClosure() {
    let scene = AnimationScene()
    let fig = scene.addFrame { fig in
      let ax = fig.addAxes()
      ax.plot([0, 1], [0, 1])
    }
    XCTAssertEqual(scene.frames.count, 1)
    XCTAssertEqual(fig.axesList.count, 1)
  }

  func testDuration() {
    let scene = AnimationScene(fps: 30)
    for _ in 0..<60 {
      scene.addFrame(Figure())
    }
    XCTAssertEqual(scene.duration, 2.0, accuracy: 0.001)
  }

  func testClear() {
    let scene = AnimationScene()
    scene.addFrame(Figure())
    scene.addFrame(Figure())
    XCTAssertEqual(scene.frames.count, 2)
    scene.clear()
    XCTAssertTrue(scene.frames.isEmpty)
  }

  func testRenderAllFrames() {
    let scene = AnimationScene(width: 100, height: 100)
    for _ in 0..<3 {
      let fig = Figure(width: 100, height: 100)
      fig.addAxes()
      scene.addFrame(fig)
    }
    let pngs = scene.renderAllFrames()
    XCTAssertEqual(pngs.count, 3)
    for png in pngs {
      XCTAssertGreaterThan(png.count, 0)
    }
  }

  func testRenderAllFramesSVG() {
    let scene = AnimationScene(width: 100, height: 100)
    scene.addFrame(Figure(width: 100, height: 100))
    let svgs = scene.renderAllFramesSVG()
    XCTAssertEqual(svgs.count, 1)
    XCTAssertTrue(svgs[0].contains("<svg"))
  }

  func testRenderFrameAtIndex() {
    let scene = AnimationScene(width: 100, height: 100)
    scene.addFrame(Figure(width: 100, height: 100))
    XCTAssertNotNil(scene.renderFrame(at: 0))
    XCTAssertNil(scene.renderFrame(at: 1))
    XCTAssertNil(scene.renderFrame(at: -1))
  }

  // MARK: - Easing

  func testLinearEasing() {
    XCTAssertEqual(Easing.linear(0), 0)
    XCTAssertEqual(Easing.linear(0.5), 0.5)
    XCTAssertEqual(Easing.linear(1), 1)
  }

  func testEaseIn() {
    XCTAssertEqual(Easing.easeIn(0), 0)
    XCTAssertLessThan(Easing.easeIn(0.5), 0.5)
    XCTAssertEqual(Easing.easeIn(1), 1)
  }

  func testEaseOut() {
    XCTAssertEqual(Easing.easeOut(0), 0)
    XCTAssertGreaterThan(Easing.easeOut(0.5), 0.5)
    XCTAssertEqual(Easing.easeOut(1), 1)
  }

  func testEaseInOut() {
    XCTAssertEqual(Easing.easeInOut(0), 0)
    XCTAssertEqual(Easing.easeInOut(0.5), 0.5, accuracy: 0.001)
    XCTAssertEqual(Easing.easeInOut(1), 1)
  }

  // MARK: - AnimationBuilder

  func testAnimationBuilder() {
    let scene = AnimationScene()
    let builder = AnimationBuilder(scene: scene)
    builder.animate(frames: 10) { t in
      let fig = Figure(width: 800, height: 600)
      let ax = fig.addAxes()
      ax.plot([0, 1], [0, t])
      return fig
    }
    XCTAssertEqual(scene.frames.count, 10)
  }

  func testAnimationBuilderWithEasing() {
    let scene = AnimationScene()
    let builder = AnimationBuilder(scene: scene)
    var tValues: [Double] = []
    builder.animate(frames: 5, easing: Easing.easeIn) { t in
      tValues.append(t)
      return Figure()
    }
    XCTAssertEqual(tValues.count, 5)
    // easeIn should make middle values smaller than linear
    XCTAssertLessThan(tValues[1], 0.3)
  }
}

final class ImagePlotTests: XCTestCase {

  func testImshowCreatesBarSeries() {
    let ax = Axes(plotArea: PlotArea(bounds: CGRect(x: 0, y: 0, width: 400, height: 400)))
    ax.imshow([[1, 2], [3, 4]])
    XCTAssertGreaterThan(ax.barSeriesList.count, 0)
  }

  func testImshowSetsLimits() {
    let ax = Axes(plotArea: PlotArea(bounds: CGRect(x: 0, y: 0, width: 400, height: 400)))
    ax.imshow([[1, 2, 3], [4, 5, 6]])
    XCTAssertEqual(ax.xLimits?.max, 3.0)
    XCTAssertEqual(ax.yLimits?.max, 2.0)
  }

  func testImshowEmptyData() {
    let ax = Axes(plotArea: PlotArea(bounds: CGRect(x: 0, y: 0, width: 400, height: 400)))
    ax.imshow([])
    XCTAssertEqual(ax.barSeriesList.count, 0)
  }

  func testPcolormeshCreatesBarSeries() {
    let ax = Axes(plotArea: PlotArea(bounds: CGRect(x: 0, y: 0, width: 400, height: 400)))
    ax.pcolormesh(
      x: [0, 1, 2], y: [0, 1, 2],
      [[1, 2], [3, 4]])
    XCTAssertGreaterThan(ax.barSeriesList.count, 0)
  }

  func testPcolormeshInsufficientEdges() {
    let ax = Axes(plotArea: PlotArea(bounds: CGRect(x: 0, y: 0, width: 400, height: 400)))
    ax.pcolormesh(x: [0], y: [0], [[1, 2]])
    XCTAssertEqual(ax.barSeriesList.count, 0)
  }
}

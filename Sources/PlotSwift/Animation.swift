//
//  Animation.swift
//  PlotSwift
//
//  Animation scene infrastructure for creating animated visualizations.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - AnimationScene

/// A container for frame-by-frame animated figures.
///
/// ```swift
/// let scene = AnimationScene(width: 800, height: 600, fps: 30)
/// for i in 0..<60 {
///     let fig = Figure(width: 800, height: 600)
///     let ax = fig.addAxes()
///     let t = Double(i) / 60.0
///     ax.plot([0, t * 10], [0, sin(t * .pi * 2)])
///     scene.addFrame(fig)
/// }
/// let frames = scene.renderAllFrames()
/// ```
public final class AnimationScene {

  /// Width of each frame in points.
  public let width: Double

  /// Height of each frame in points.
  public let height: Double

  /// Frames per second for timing calculations.
  public let fps: Double

  /// All figures representing individual frames.
  public private(set) var frames: [Figure] = []

  /// Creates an animation scene with the given dimensions and frame rate.
  public init(width: Double = 800, height: Double = 600, fps: Double = 30) {
    self.width = width
    self.height = height
    self.fps = fps
  }

  /// The total duration of the animation in seconds.
  public var duration: Double {
    Double(frames.count) / fps
  }

  /// Adds a pre-built figure as the next frame.
  public func addFrame(_ figure: Figure) {
    frames.append(figure)
  }

  /// Creates a new figure sized to this scene and adds it as a frame.
  /// - Parameter setup: A closure that configures the figure before it is appended.
  /// - Returns: The created figure.
  @discardableResult
  public func addFrame(_ setup: (Figure) -> Void) -> Figure {
    let fig = Figure(width: width, height: height)
    setup(fig)
    frames.append(fig)
    return fig
  }

  /// Renders all frames to PNG data.
  /// - Parameter scale: Pixel density multiplier.
  /// - Returns: An array of PNG data, one per frame.
  public func renderAllFrames(scale: CGFloat = 1.0) -> [Data] {
    frames.compactMap { $0.renderToPNG(scale: scale) }
  }

  /// Renders all frames to SVG strings.
  public func renderAllFramesSVG() -> [String] {
    frames.map { $0.renderToSVG() }
  }

  /// Renders a single frame by index.
  /// - Parameters:
  ///   - index: Frame index (0-based).
  ///   - scale: Pixel density multiplier.
  /// - Returns: PNG data for the frame, or nil if index is out of range.
  public func renderFrame(at index: Int, scale: CGFloat = 1.0) -> Data? {
    guard index >= 0, index < frames.count else { return nil }
    return frames[index].renderToPNG(scale: scale)
  }

  /// Removes all frames.
  public func clear() {
    frames.removeAll()
  }
}

// MARK: - AnimationEffect

/// Types of animation transitions that can be applied.
public enum AnimationEffect: Sendable {
  /// Object appears in the scene.
  case fadeIn(duration: Double)
  /// Object disappears from the scene.
  case fadeOut(duration: Double)
  /// Object moves from one position to another.
  case translate(dx: Double, dy: Double, duration: Double)
  /// Object scales by the given factor.
  case scale(factor: Double, duration: Double)
  /// Custom interpolation between start and end values.
  case custom(duration: Double, interpolate: @Sendable (Double) -> Double)
}

// MARK: - Easing Functions

/// Standard easing functions for smooth animations.
public enum Easing {

  /// Linear interpolation (no easing).
  public static func linear(_ t: Double) -> Double { t }

  /// Quadratic ease-in.
  public static func easeIn(_ t: Double) -> Double { t * t }

  /// Quadratic ease-out.
  public static func easeOut(_ t: Double) -> Double { t * (2 - t) }

  /// Quadratic ease-in-out.
  public static func easeInOut(_ t: Double) -> Double {
    t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
  }

  /// Sine ease-in-out.
  public static func sine(_ t: Double) -> Double {
    (1 - cos(t * .pi)) / 2
  }
}

// MARK: - AnimationBuilder

/// Builds an animation by interpolating data over a sequence of frames.
///
/// ```swift
/// let builder = AnimationBuilder(scene: scene)
/// builder.animate(frames: 60) { t in
///     let fig = Figure(width: 800, height: 600)
///     let ax = fig.addAxes()
///     let x = Array(stride(from: 0, through: 10, by: 0.1))
///     let y = x.map { sin($0 + t * 2 * .pi) }
///     ax.plot(x, y)
///     return fig
/// }
/// ```
public final class AnimationBuilder {

  private let scene: AnimationScene

  /// Creates a builder targeting the given scene.
  public init(scene: AnimationScene) {
    self.scene = scene
  }

  /// Generates frames by calling `frameBuilder` with normalized time (0 to 1).
  /// - Parameters:
  ///   - frames: Number of frames to generate.
  ///   - easing: Easing function applied to the time parameter.
  ///   - frameBuilder: Closure receiving `t` in [0,1] and returning a Figure.
  public func animate(
    frames: Int,
    easing: @escaping (Double) -> Double = Easing.linear,
    _ frameBuilder: (Double) -> Figure
  ) {
    for i in 0..<frames {
      let rawT = Double(i) / Double(max(1, frames - 1))
      let t = easing(rawT)
      scene.addFrame(frameBuilder(t))
    }
  }
}

//
//  Animation+Export.swift
//  PlotSwift
//
//  Video export helpers for AnimationScene.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

extension AnimationScene {

  /// Writes all frames as numbered PNG files to a directory.
  ///
  /// The output files are named `frame_0000.png`, `frame_0001.png`, etc.
  /// Use an external tool like FFmpeg to assemble them into video:
  /// ```
  /// ffmpeg -framerate 30 -i frame_%04d.png -c:v libx264 -pix_fmt yuv420p output.mp4
  /// ```
  ///
  /// - Parameters:
  ///   - directory: The directory URL to write frames into (created if absent).
  ///   - prefix: File name prefix (default: "frame").
  ///   - scale: Pixel density multiplier (default: 1.0).
  /// - Returns: The number of frames written.
  /// - Throws: If the directory cannot be created or a frame fails to write.
  @discardableResult
  public func exportFrames(
    to directory: URL,
    prefix: String = "frame",
    scale: CGFloat = 1.0
  ) throws -> Int {
    let fm = FileManager.default
    if !fm.fileExists(atPath: directory.path) {
      try fm.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    var written = 0
    for (i, frame) in frames.enumerated() {
      guard let data = frame.renderToPNG(scale: scale) else { continue }
      let name = String(format: "%@_%04d.png", prefix, i)
      let url = directory.appendingPathComponent(name)
      try data.write(to: url)
      written += 1
    }
    return written
  }

  /// Returns a shell command string for assembling exported frames into an MP4 video.
  ///
  /// - Parameters:
  ///   - directory: The directory containing the frame PNGs.
  ///   - prefix: The frame file name prefix used during export.
  ///   - output: The desired output file path.
  /// - Returns: An FFmpeg command string.
  public func ffmpegCommand(
    directory: URL,
    prefix: String = "frame",
    output: String = "output.mp4"
  ) -> String {
    let pattern = directory.appendingPathComponent("\(prefix)_%04d.png").path
    return
      "ffmpeg -framerate \(Int(fps)) -i \(pattern) -c:v libx264 -pix_fmt yuv420p \(output)"
  }
}

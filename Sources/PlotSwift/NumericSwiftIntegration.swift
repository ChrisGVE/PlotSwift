//
//  NumericSwiftIntegration.swift
//  PlotSwift
//
//  Conditional extensions on Axes for NumericSwift interoperability.
//  This file compiles to nothing when NumericSwift is not available.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

#if canImport(NumericSwift)
  import NumericSwift

  extension Axes {

    // MARK: - Distribution plot

    /// Plots the probability density function of a ``Distribution`` over a given range.
    ///
    /// - Parameters:
    ///   - distribution: Any ``Distribution`` value whose PDF is evaluated.
    ///   - range: X-axis span to sample. When `nil`, a ±4-sigma interval around
    ///     the distribution's mean is used when available, otherwise `0...1`.
    ///   - samples: Number of evenly-spaced sample points (default: 100).
    ///   - color: Line color; cycles automatically when `nil`.
    ///   - label: Legend label.
    /// - Returns: The created ``DataSeries`` (discardable).
    @discardableResult
    public func plot(
      _ distribution: any Distribution,
      range: ClosedRange<Double>? = nil,
      samples: Int = 100,
      color: Color? = nil,
      label: String? = nil
    ) -> DataSeries {
      let resolvedRange = range ?? defaultRange(for: distribution)
      let step = (resolvedRange.upperBound - resolvedRange.lowerBound) / Double(max(samples - 1, 1))
      let x = (0..<samples).map { resolvedRange.lowerBound + Double($0) * step }
      let y = x.map { distribution.pdf($0) }
      return plot(x, y, color: color, label: label)
    }

    // MARK: - KDE plot

    /// Draws a kernel density estimate of a raw sample using a Gaussian kernel.
    ///
    /// - Parameters:
    ///   - data: Raw sample values.
    ///   - bandwidth: Smoothing bandwidth (h). When `nil`, Silverman's rule of
    ///     thumb is applied: `h = 1.06 * σ * n^(−1/5)`.
    ///   - color: Line color; cycles automatically when `nil`.
    ///   - label: Legend label.
    public func kdeplot(
      _ data: [Double],
      bandwidth: Double? = nil,
      color: Color? = nil,
      label: String? = nil
    ) {
      guard !data.isEmpty else { return }
      let h = bandwidth ?? silvermanBandwidth(data)
      let lo = (data.min() ?? 0) - 3 * h
      let hi = (data.max() ?? 1) + 3 * h
      let samples = 200
      let step = (hi - lo) / Double(samples - 1)
      let x = (0..<samples).map { lo + Double($0) * step }
      let y = x.map { xi in
        data.reduce(0.0) { acc, xi_k in
          acc + gaussianKernel((xi - xi_k) / h)
        } / (Double(data.count) * h)
      }
      plot(x, y, color: color, label: label)
    }

    // MARK: - Private helpers

    private func defaultRange(for distribution: any Distribution) -> ClosedRange<Double> {
      if let mean = distribution.mean, let std = distribution.standardDeviation {
        return (mean - 4 * std)...(mean + 4 * std)
      }
      return 0.0...1.0
    }

    private func silvermanBandwidth(_ data: [Double]) -> Double {
      let n = Double(data.count)
      guard n > 1 else { return 1.0 }
      let mean = data.reduce(0, +) / n
      let variance = data.reduce(0.0) { $0 + ($1 - mean) * ($1 - mean) } / (n - 1)
      let sigma = variance.squareRoot()
      return 1.06 * sigma * pow(n, -0.2)
    }

    private func gaussianKernel(_ u: Double) -> Double {
      exp(-0.5 * u * u) / (2 * Double.pi).squareRoot()
    }
  }
#endif

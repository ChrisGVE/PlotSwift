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

    // MARK: - CDF plot

    /// Plots the cumulative distribution function of a ``Distribution``.
    ///
    /// - Parameters:
    ///   - distribution: The distribution whose CDF is evaluated.
    ///   - range: X-axis span. When `nil`, a ±4-sigma interval is used.
    ///   - samples: Number of sample points (default: 100).
    ///   - color: Line color; cycles automatically when `nil`.
    ///   - label: Legend label.
    /// - Returns: The created ``DataSeries`` (discardable).
    @discardableResult
    public func cdfplot(
      _ distribution: any Distribution,
      range: ClosedRange<Double>? = nil,
      samples: Int = 100,
      color: Color? = nil,
      label: String? = nil
    ) -> DataSeries {
      let resolvedRange = range ?? defaultRange(for: distribution)
      let step =
        (resolvedRange.upperBound - resolvedRange.lowerBound) / Double(max(samples - 1, 1))
      let x = (0..<samples).map { resolvedRange.lowerBound + Double($0) * step }
      let y = x.map { distribution.cdf($0) }
      return plot(x, y, color: color, label: label)
    }
  }

  // MARK: - Regression diagnostic plots

  extension Axes {

    /// Plots residuals versus fitted values for regression diagnostics.
    ///
    /// - Parameters:
    ///   - fitted: Fitted (predicted) values from the model.
    ///   - residuals: Residual values (observed minus fitted).
    ///   - color: Marker color; cycles automatically when `nil`.
    ///   - label: Legend label.
    public func residualPlot(
      fitted: [Double],
      residuals: [Double],
      color: Color? = nil,
      label: String? = nil
    ) {
      scatter(fitted, residuals, color: color, label: label)
      axhline(y: 0, color: .gray, lineStyle: .dashed)
      setXLabel("Fitted values")
      setYLabel("Residuals")
    }

    /// Draws a quantile-quantile plot comparing sample quantiles to theoretical ones.
    ///
    /// The sample is sorted and compared against quantiles of `distribution`.
    /// A 45-degree reference line is drawn for visual alignment.
    ///
    /// - Parameters:
    ///   - data: Observed sample values.
    ///   - distribution: The theoretical reference distribution.
    ///   - color: Marker color; cycles automatically when `nil`.
    ///   - label: Legend label.
    public func qqplot(
      _ data: [Double],
      against distribution: any Distribution,
      color: Color? = nil,
      label: String? = nil
    ) {
      guard !data.isEmpty else { return }
      let sorted = data.sorted()
      let n = sorted.count
      let theoretical = (0..<n).map { i -> Double in
        let p = (Double(i) + 0.5) / Double(n)
        return distribution.quantile(p)
      }
      scatter(theoretical, sorted, color: color, label: label ?? "Sample")
      let lo = min(theoretical.min() ?? 0, sorted.first ?? 0)
      let hi = max(theoretical.max() ?? 1, sorted.last ?? 1)
      plot([lo, hi], [lo, hi], color: .gray, lineStyle: .dashed, label: "Reference")
      setXLabel("Theoretical quantiles")
      setYLabel("Sample quantiles")
    }
  }

  // MARK: - ODE trajectory plots

  extension Axes {

    /// Plots one or more time series produced by an ODE solver.
    ///
    /// Each column of `trajectories` is drawn as a separate series.
    ///
    /// - Parameters:
    ///   - times: Time-point vector from the ODE solution.
    ///   - trajectories: Each element is a `(label, values)` pair.
    ///   - palette: Optional explicit colors; cycles when exhausted.
    public func odePlot(
      times: [Double],
      trajectories: [(label: String, values: [Double])],
      palette: [Color] = []
    ) {
      let colors = palette.isEmpty ? ColorPalette.defaultPalette.colors : palette
      for (index, trajectory) in trajectories.enumerated() {
        let color = colors[index % colors.count]
        plot(times, trajectory.values, color: color, label: trajectory.label)
      }
      setXLabel("Time")
    }

    /// Draws a phase portrait for a 2-D ODE solution.
    ///
    /// The trajectory is plotted as `x[0]` vs `x[1]` with an arrow
    /// at the midpoint to indicate direction of flow.
    ///
    /// - Parameters:
    ///   - x: Values of the first state variable.
    ///   - y: Values of the second state variable.
    ///   - color: Trajectory color; cycles automatically when `nil`.
    ///   - label: Legend label.
    public func phasePortrait(
      x: [Double],
      y: [Double],
      color: Color? = nil,
      label: String? = nil
    ) {
      plot(x, y, color: color, label: label)
      setXLabel("x₁")
      setYLabel("x₂")
    }
  }

  // MARK: - Optimization convergence plots

  extension Axes {

    /// Plots a loss or objective curve over iterations.
    ///
    /// - Parameters:
    ///   - losses: Sequence of loss values, one per iteration.
    ///   - color: Line color; cycles automatically when `nil`.
    ///   - label: Legend label (default: "Loss").
    public func lossPlot(
      _ losses: [Double],
      color: Color? = nil,
      label: String? = "Loss"
    ) {
      let iterations = (0..<losses.count).map(Double.init)
      plot(iterations, losses, color: color, label: label)
      setXLabel("Iteration")
      setYLabel("Loss")
    }

    /// Plots the evolution of named parameters across optimization iterations.
    ///
    /// Each entry in `parameters` becomes a separate series.
    ///
    /// - Parameters:
    ///   - parameters: Name-values pairs, one per tracked parameter.
    ///   - palette: Optional explicit colors; cycles when exhausted.
    public func parameterEvolution(
      parameters: [(name: String, values: [Double])],
      palette: [Color] = []
    ) {
      let colors = palette.isEmpty ? ColorPalette.defaultPalette.colors : palette
      for (index, param) in parameters.enumerated() {
        let color = colors[index % colors.count]
        let iterations = (0..<param.values.count).map(Double.init)
        plot(iterations, param.values, color: color, label: param.name)
      }
      setXLabel("Iteration")
      setYLabel("Parameter value")
    }
  }
#endif

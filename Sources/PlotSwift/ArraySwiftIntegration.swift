//
//  ArraySwiftIntegration.swift
//  PlotSwift
//
//  Conditional extensions on Axes for ArraySwift interoperability.
//  This file compiles to nothing when ArraySwift is not available.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

#if canImport(ArraySwift)
  import ArraySwift

  extension Axes {

    // MARK: - NDArray line plot

    /// Adds a line series from two 1-D ``NDArray`` values.
    ///
    /// The arrays are flattened to `[Double]` in row-major order before plotting,
    /// so callers should ensure both arrays are rank-1 with equal element counts.
    ///
    /// - Parameters:
    ///   - x: X-coordinate values as a 1-D ``NDArray``.
    ///   - y: Y-coordinate values as a 1-D ``NDArray``.
    ///   - color: Line color; cycles automatically when `nil`.
    ///   - label: Legend label.
    /// - Returns: The created ``DataSeries`` (discardable).
    @discardableResult
    public func plot(
      _ x: NDArray<Double>,
      _ y: NDArray<Double>,
      color: Color? = nil,
      label: String? = nil
    ) -> DataSeries {
      return plot(Array(x), Array(y), color: color, label: label)
    }

    // MARK: - Heatmap

    /// Renders a rank-2 ``NDArray`` as a false-color grid.
    ///
    /// Each element maps to a rectangle whose fill color is determined by its
    /// normalised position within the array's value range and the chosen palette.
    /// Rows in the array map to y-coordinates (row 0 at the top).
    ///
    /// - Parameters:
    ///   - data: A rank-2 ``NDArray`` of shape `[rows, cols]`.
    ///   - palette: Color palette used to map scalar values to colors
    ///     (default: `.viridis`).
    public func heatmap(
      _ data: NDArray<Double>,
      palette: ColorPalette = .viridis
    ) {
      let shape = data.shape
      guard shape.count == 2 else { return }
      let rows = shape[0]
      let cols = shape[1]
      guard rows > 0, cols > 0 else { return }

      let flat = Array(data)
      guard
        let minVal = flat.min(),
        let maxVal = flat.max(),
        maxVal > minVal
      else { return }

      let cellW = 1.0 / Double(cols)
      let cellH = 1.0 / Double(rows)

      for row in 0..<rows {
        for col in 0..<cols {
          let value = flat[row * cols + col]
          let t = (value - minVal) / (maxVal - minVal)
          let fill = palette.color(at: t)
          let xLeft = Double(col) * cellW
          let yTop = Double(row) * cellH
          let series = DataSeries(
            x: [xLeft, xLeft + cellW],
            y: [yTop, yTop + cellH],
            label: nil,
            color: fill,
            lineStyle: .none,
            marker: .none,
            lineWidth: 0,
            markerSize: 0,
            seriesType: .scatter
          )
          dataSeries.append(series)
        }
      }
    }
  }
#endif

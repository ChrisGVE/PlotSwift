//
//  ColorPaletteTests.swift
//  PlotSwift
//
//  Tests for ColorPalette and ColorCycle.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Testing

@testable import PlotSwift

// MARK: - Palette color counts

@Suite("ColorPalette – predefined palette sizes")
struct ColorPaletteSizeTests {

  @Test("tab10 has 10 colors")
  func tab10Count() {
    #expect(ColorPalette.tab10.colors.count == 10)
  }

  @Test("set1 has 9 colors")
  func set1Count() {
    #expect(ColorPalette.set1.colors.count == 9)
  }

  @Test("set2 has 8 colors")
  func set2Count() {
    #expect(ColorPalette.set2.colors.count == 8)
  }

  @Test("set3 has 12 colors")
  func set3Count() {
    #expect(ColorPalette.set3.colors.count == 12)
  }

  @Test("viridis has 16 colors")
  func viridisCount() {
    #expect(ColorPalette.viridis.colors.count == 16)
  }

  @Test("plasma has 16 colors")
  func plasmaCount() {
    #expect(ColorPalette.plasma.colors.count == 16)
  }

  @Test("magma has 16 colors")
  func magmaCount() {
    #expect(ColorPalette.magma.colors.count == 16)
  }

  @Test("inferno has 16 colors")
  func infernoCount() {
    #expect(ColorPalette.inferno.colors.count == 16)
  }

  @Test("coolwarm has 16 colors")
  func coolwarmCount() {
    #expect(ColorPalette.coolwarm.colors.count == 16)
  }
}

// MARK: - Palette names

@Suite("ColorPalette – names")
struct ColorPaletteNameTests {

  @Test("predefined palettes carry correct names")
  func predefinedNames() {
    #expect(ColorPalette.tab10.name == "tab10")
    #expect(ColorPalette.set1.name == "set1")
    #expect(ColorPalette.set2.name == "set2")
    #expect(ColorPalette.set3.name == "set3")
    #expect(ColorPalette.viridis.name == "viridis")
    #expect(ColorPalette.plasma.name == "plasma")
    #expect(ColorPalette.magma.name == "magma")
    #expect(ColorPalette.inferno.name == "inferno")
    #expect(ColorPalette.coolwarm.name == "coolwarm")
  }
}

// MARK: - named(_:) lookup

@Suite("ColorPalette – named(_:)")
struct ColorPaletteNamedTests {

  @Test("lookup returns correct palette for each known name")
  func knownNames() {
    let knownNames = [
      "tab10", "set1", "set2", "set3",
      "viridis", "plasma", "magma", "inferno", "coolwarm",
    ]
    for name in knownNames {
      let palette = ColorPalette.named(name)
      #expect(palette != nil, "Expected non-nil palette for name '\(name)'")
      #expect(palette?.name == name)
    }
  }

  @Test("lookup is case-insensitive")
  func caseInsensitive() {
    #expect(ColorPalette.named("Tab10") != nil)
    #expect(ColorPalette.named("VIRIDIS") != nil)
    #expect(ColorPalette.named("CoolWarm") != nil)
  }

  @Test("lookup returns nil for unknown names")
  func unknownName() {
    #expect(ColorPalette.named("notapalette") == nil)
    #expect(ColorPalette.named("") == nil)
  }
}

// MARK: - color(at:) interpolation

@Suite("ColorPalette – color(at:) interpolation")
struct ColorPaletteInterpolationTests {

  private let accuracy = 1e-6

  @Test("t=0.0 returns first key color")
  func atZero() {
    let palette = ColorPalette.viridis
    let result = palette.color(at: 0.0)
    let expected = palette.colors.first!
    #expect(abs(result.red - expected.red) < accuracy)
    #expect(abs(result.green - expected.green) < accuracy)
    #expect(abs(result.blue - expected.blue) < accuracy)
  }

  @Test("t=1.0 returns last key color")
  func atOne() {
    let palette = ColorPalette.viridis
    let result = palette.color(at: 1.0)
    let expected = palette.colors.last!
    #expect(abs(result.red - expected.red) < accuracy)
    #expect(abs(result.green - expected.green) < accuracy)
    #expect(abs(result.blue - expected.blue) < accuracy)
  }

  @Test("t=0.5 lies between first and last colors on a two-color palette")
  func atHalfTwoColors() {
    let a = Color(red: 0, green: 0, blue: 0)
    let b = Color(red: 1, green: 1, blue: 1)
    let palette = ColorPalette(name: "bw", colors: [a, b])
    let mid = palette.color(at: 0.5)
    #expect(abs(mid.red - 0.5) < accuracy)
    #expect(abs(mid.green - 0.5) < accuracy)
    #expect(abs(mid.blue - 0.5) < accuracy)
  }

  @Test("t below 0 clamps to first color")
  func clampBelow() {
    let palette = ColorPalette.plasma
    let result = palette.color(at: -1.0)
    let expected = palette.colors.first!
    #expect(abs(result.red - expected.red) < accuracy)
  }

  @Test("t above 1 clamps to last color")
  func clampAbove() {
    let palette = ColorPalette.plasma
    let result = palette.color(at: 2.0)
    let expected = palette.colors.last!
    #expect(abs(result.red - expected.red) < accuracy)
  }

  @Test("single-color palette always returns the same color")
  func singleColor() {
    let only = Color(red: 0.4, green: 0.5, blue: 0.6)
    let palette = ColorPalette(name: "single", colors: [only])
    for t in [0.0, 0.5, 1.0] {
      let result = palette.color(at: t)
      #expect(abs(result.red - only.red) < accuracy)
    }
  }
}

// MARK: - ColorCycle

@Suite("ColorCycle")
struct ColorCycleTests {

  @Test("next() returns colors in order")
  func sequentialColors() {
    let cycle = ColorCycle(palette: .tab10)
    for i in 0..<ColorPalette.tab10.colors.count {
      let expected = ColorPalette.tab10.colors[i]
      let got = cycle.next()
      #expect(got == expected, "Mismatch at index \(i)")
    }
  }

  @Test("next() wraps around after last color")
  func wrapsAround() {
    let palette = ColorPalette.tab10
    let cycle = ColorCycle(palette: palette)
    // exhaust the palette
    for _ in 0..<palette.colors.count { _ = cycle.next() }
    // next call must wrap to first color
    #expect(cycle.next() == palette.colors[0])
  }

  @Test("currentIndex advances with each call to next()")
  func currentIndexAdvances() {
    let cycle = ColorCycle(palette: .tab10)
    #expect(cycle.currentIndex == 0)
    _ = cycle.next()
    #expect(cycle.currentIndex == 1)
    _ = cycle.next()
    #expect(cycle.currentIndex == 2)
  }

  @Test("reset() returns currentIndex to zero")
  func resetIndex() {
    let cycle = ColorCycle(palette: .tab10)
    _ = cycle.next()
    _ = cycle.next()
    cycle.reset()
    #expect(cycle.currentIndex == 0)
  }

  @Test("reset() causes next call to return the first color again")
  func resetReturnsFirst() {
    let cycle = ColorCycle(palette: .tab10)
    let first = cycle.next()
    _ = cycle.next()
    _ = cycle.next()
    cycle.reset()
    #expect(cycle.next() == first)
  }

  @Test("default palette is tab10")
  func defaultPalette() {
    let cycle = ColorCycle()
    #expect(cycle.palette.name == "tab10")
  }

  @Test("custom palette is respected")
  func customPalette() {
    let cycle = ColorCycle(palette: .viridis)
    #expect(cycle.palette.name == "viridis")
    #expect(cycle.next() == ColorPalette.viridis.colors[0])
  }
}

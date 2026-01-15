//
//  PlotTypesTests.swift
//  PlotSwiftTests
//
//  Tests for PlotSwift types
//

import XCTest
import CoreGraphics
@testable import PlotSwift

final class PlotTypesTests: XCTestCase {

    // MARK: - Color Tests

    func testColorRGB() {
        let color = Color(red: 1.0, green: 0.5, blue: 0.25)
        XCTAssertEqual(color.red, 1.0)
        XCTAssertEqual(color.green, 0.5)
        XCTAssertEqual(color.blue, 0.25)
        XCTAssertEqual(color.alpha, 1.0)
    }

    func testColorRGBA() {
        let color = Color(red: 1.0, green: 0.5, blue: 0.25, alpha: 0.8)
        XCTAssertEqual(color.alpha, 0.8)
    }

    func testColorFromHex() {
        let color = Color(hex: "#FF8040")
        XCTAssertNotNil(color)
        XCTAssertEqual(color!.red, 1.0, accuracy: 0.01)
        XCTAssertEqual(color!.green, 0.5, accuracy: 0.01)
        XCTAssertEqual(color!.blue, 0.25, accuracy: 0.01)
    }

    func testColorFromHexWithoutHash() {
        let color = Color(hex: "00FF00")
        XCTAssertNotNil(color)
        XCTAssertEqual(color!.red, 0, accuracy: 0.01)
        XCTAssertEqual(color!.green, 1.0, accuracy: 0.01)
        XCTAssertEqual(color!.blue, 0, accuracy: 0.01)
    }

    func testColorFromHexWithAlpha() {
        let color = Color(hex: "#FF804080")
        XCTAssertNotNil(color)
        XCTAssertEqual(color!.alpha, 0.5, accuracy: 0.01)
    }

    func testColorFromName() {
        XCTAssertEqual(Color(name: "red"), Color.red)
        XCTAssertEqual(Color(name: "blue"), Color.blue)
        XCTAssertEqual(Color(name: "green"), Color.green)
        XCTAssertEqual(Color(name: "black"), Color.black)
        XCTAssertEqual(Color(name: "white"), Color.white)
        XCTAssertNil(Color(name: "invalid"))
    }

    func testColorToHex() {
        let color = Color(red: 1.0, green: 0.5, blue: 0.0)
        XCTAssertEqual(color.toHex(), "#FF7F00")
    }

    func testColorToHexWithAlpha() {
        let color = Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        XCTAssertEqual(color.toHex(includeAlpha: true), "#FF00007F")
    }

    func testPredefinedColors() {
        XCTAssertEqual(Color.black.red, 0)
        XCTAssertEqual(Color.white.red, 1)
        XCTAssertEqual(Color.red.red, 1)
        XCTAssertEqual(Color.clear.alpha, 0)
    }

    func testColorCGColor() {
        let color = Color(red: 1.0, green: 0.5, blue: 0.25, alpha: 0.8)
        let cgColor = color.cgColor
        XCTAssertNotNil(cgColor)
    }

    // MARK: - TextStyle Tests

    func testTextStyleDefaults() {
        let style = TextStyle()
        XCTAssertEqual(style.fontFamily, "sans-serif")
        XCTAssertEqual(style.fontSize, 12)
        XCTAssertEqual(style.fontWeight, .normal)
        XCTAssertEqual(style.anchor, .start)
    }

    func testTextStyleCustom() {
        let style = TextStyle(
            fontFamily: "Helvetica",
            fontSize: 14,
            fontWeight: .bold,
            color: .blue,
            anchor: .middle
        )
        XCTAssertEqual(style.fontFamily, "Helvetica")
        XCTAssertEqual(style.fontSize, 14)
        XCTAssertEqual(style.fontWeight, .bold)
        XCTAssertEqual(style.color, .blue)
        XCTAssertEqual(style.anchor, .middle)
    }

    func testFontWeightRawValues() {
        XCTAssertEqual(TextStyle.FontWeight.normal.rawValue, "normal")
        XCTAssertEqual(TextStyle.FontWeight.bold.rawValue, "bold")
        XCTAssertEqual(TextStyle.FontWeight.light.rawValue, "light")
    }

    func testTextAnchorRawValues() {
        XCTAssertEqual(TextStyle.TextAnchor.start.rawValue, "start")
        XCTAssertEqual(TextStyle.TextAnchor.middle.rawValue, "middle")
        XCTAssertEqual(TextStyle.TextAnchor.end.rawValue, "end")
    }

    // MARK: - LineStyle Tests

    func testLineStyleRawValues() {
        XCTAssertEqual(LineStyle.solid.rawValue, "-")
        XCTAssertEqual(LineStyle.dashed.rawValue, "--")
        XCTAssertEqual(LineStyle.dotted.rawValue, ":")
        XCTAssertEqual(LineStyle.dashDot.rawValue, "-.")
        XCTAssertEqual(LineStyle.none.rawValue, "")
    }

    func testLineStyleDashPattern() {
        XCTAssertNil(LineStyle.solid.dashPattern)
        XCTAssertNil(LineStyle.none.dashPattern)
        XCTAssertNotNil(LineStyle.dashed.dashPattern)
        XCTAssertNotNil(LineStyle.dotted.dashPattern)
        XCTAssertNotNil(LineStyle.dashDot.dashPattern)
    }

    func testLineStyleDashPatternValues() {
        XCTAssertEqual(LineStyle.dashed.dashPattern, [6, 4])
        XCTAssertEqual(LineStyle.dotted.dashPattern, [2, 2])
        XCTAssertEqual(LineStyle.dashDot.dashPattern, [6, 2, 2, 2])
    }

    // MARK: - MarkerStyle Tests

    func testMarkerStyleRawValues() {
        XCTAssertEqual(MarkerStyle.circle.rawValue, "o")
        XCTAssertEqual(MarkerStyle.square.rawValue, "s")
        XCTAssertEqual(MarkerStyle.diamond.rawValue, "D")
        XCTAssertEqual(MarkerStyle.triangleUp.rawValue, "^")
        XCTAssertEqual(MarkerStyle.triangleDown.rawValue, "v")
        XCTAssertEqual(MarkerStyle.triangleLeft.rawValue, "<")
        XCTAssertEqual(MarkerStyle.triangleRight.rawValue, ">")
        XCTAssertEqual(MarkerStyle.plus.rawValue, "+")
        XCTAssertEqual(MarkerStyle.cross.rawValue, "x")
        XCTAssertEqual(MarkerStyle.star.rawValue, "*")
        XCTAssertEqual(MarkerStyle.dot.rawValue, ".")
        XCTAssertEqual(MarkerStyle.none.rawValue, "")
    }

    // MARK: - DrawingCommand Tests

    func testDrawingCommandMoveTo() {
        let cmd = DrawingCommand.moveTo(x: 10, y: 20)
        if case .moveTo(let x, let y) = cmd {
            XCTAssertEqual(x, 10)
            XCTAssertEqual(y, 20)
        } else {
            XCTFail("Expected moveTo command")
        }
    }

    func testDrawingCommandLineTo() {
        let cmd = DrawingCommand.lineTo(x: 30, y: 40)
        if case .lineTo(let x, let y) = cmd {
            XCTAssertEqual(x, 30)
            XCTAssertEqual(y, 40)
        } else {
            XCTFail("Expected lineTo command")
        }
    }

    func testDrawingCommandCurveTo() {
        let cmd = DrawingCommand.curveTo(cp1x: 10, cp1y: 20, cp2x: 30, cp2y: 40, x: 50, y: 60)
        if case .curveTo(let cp1x, let cp1y, let cp2x, let cp2y, let x, let y) = cmd {
            XCTAssertEqual(cp1x, 10)
            XCTAssertEqual(cp1y, 20)
            XCTAssertEqual(cp2x, 30)
            XCTAssertEqual(cp2y, 40)
            XCTAssertEqual(x, 50)
            XCTAssertEqual(y, 60)
        } else {
            XCTFail("Expected curveTo command")
        }
    }

    func testDrawingCommandQuadCurveTo() {
        let cmd = DrawingCommand.quadCurveTo(cpx: 10, cpy: 20, x: 30, y: 40)
        if case .quadCurveTo(let cpx, let cpy, let x, let y) = cmd {
            XCTAssertEqual(cpx, 10)
            XCTAssertEqual(cpy, 20)
            XCTAssertEqual(x, 30)
            XCTAssertEqual(y, 40)
        } else {
            XCTFail("Expected quadCurveTo command")
        }
    }

    func testDrawingCommandClosePath() {
        let cmd = DrawingCommand.closePath
        if case .closePath = cmd {
            // Success
        } else {
            XCTFail("Expected closePath command")
        }
    }

    func testDrawingCommandRect() {
        let cmd = DrawingCommand.rect(x: 10, y: 20, width: 100, height: 50)
        if case .rect(let x, let y, let width, let height) = cmd {
            XCTAssertEqual(x, 10)
            XCTAssertEqual(y, 20)
            XCTAssertEqual(width, 100)
            XCTAssertEqual(height, 50)
        } else {
            XCTFail("Expected rect command")
        }
    }

    func testDrawingCommandEllipse() {
        let cmd = DrawingCommand.ellipse(cx: 50, cy: 50, rx: 25, ry: 15)
        if case .ellipse(let cx, let cy, let rx, let ry) = cmd {
            XCTAssertEqual(cx, 50)
            XCTAssertEqual(cy, 50)
            XCTAssertEqual(rx, 25)
            XCTAssertEqual(ry, 15)
        } else {
            XCTFail("Expected ellipse command")
        }
    }

    func testDrawingCommandArc() {
        let cmd = DrawingCommand.arc(cx: 50, cy: 50, r: 25, startAngle: 0, endAngle: .pi, clockwise: true)
        if case .arc(let cx, let cy, let r, let startAngle, let endAngle, let clockwise) = cmd {
            XCTAssertEqual(cx, 50)
            XCTAssertEqual(cy, 50)
            XCTAssertEqual(r, 25)
            XCTAssertEqual(startAngle, 0)
            XCTAssertEqual(endAngle, .pi)
            XCTAssertTrue(clockwise)
        } else {
            XCTFail("Expected arc command")
        }
    }

    func testDrawingCommandText() {
        let style = TextStyle(fontSize: 14, color: .black)
        let cmd = DrawingCommand.text("Hello", x: 100, y: 200, style: style)
        if case .text(let text, let x, let y, let cmdStyle) = cmd {
            XCTAssertEqual(text, "Hello")
            XCTAssertEqual(x, 100)
            XCTAssertEqual(y, 200)
            XCTAssertEqual(cmdStyle.fontSize, 14)
        } else {
            XCTFail("Expected text command")
        }
    }

    func testDrawingCommandSetStrokeColor() {
        let cmd = DrawingCommand.setStrokeColor(.red)
        if case .setStrokeColor(let color) = cmd {
            XCTAssertEqual(color, .red)
        } else {
            XCTFail("Expected setStrokeColor command")
        }
    }

    func testDrawingCommandSetStrokeWidth() {
        let cmd = DrawingCommand.setStrokeWidth(2.5)
        if case .setStrokeWidth(let width) = cmd {
            XCTAssertEqual(width, 2.5)
        } else {
            XCTFail("Expected setStrokeWidth command")
        }
    }

    func testDrawingCommandSetFillColor() {
        let cmd = DrawingCommand.setFillColor(.blue)
        if case .setFillColor(let color) = cmd {
            XCTAssertEqual(color, .blue)
        } else {
            XCTFail("Expected setFillColor command")
        }
    }

    func testDrawingCommandSetAlpha() {
        let cmd = DrawingCommand.setAlpha(0.5)
        if case .setAlpha(let alpha) = cmd {
            XCTAssertEqual(alpha, 0.5)
        } else {
            XCTFail("Expected setAlpha command")
        }
    }

    // MARK: - DrawingContext Tests

    func testDrawingContextCreation() {
        let ctx = DrawingContext()
        XCTAssertEqual(ctx.commandCount, 0)
        XCTAssertTrue(ctx.commands.isEmpty)
    }

    func testDrawingContextMoveTo() {
        let ctx = DrawingContext()
        ctx.moveTo(10, 20)
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .moveTo(x: 10, y: 20))
    }

    func testDrawingContextLineTo() {
        let ctx = DrawingContext()
        ctx.lineTo(30, 40)
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .lineTo(x: 30, y: 40))
    }

    func testDrawingContextClosePath() {
        let ctx = DrawingContext()
        ctx.closePath()
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .closePath)
    }

    func testDrawingContextClear() {
        let ctx = DrawingContext()
        ctx.moveTo(0, 0)
        ctx.lineTo(100, 100)
        XCTAssertEqual(ctx.commandCount, 2)
        ctx.clear()
        XCTAssertEqual(ctx.commandCount, 0)
    }

    func testDrawingContextRect() {
        let ctx = DrawingContext()
        ctx.rect(10, 20, 100, 50)
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .rect(x: 10, y: 20, width: 100, height: 50))
    }

    func testDrawingContextEllipse() {
        let ctx = DrawingContext()
        ctx.ellipse(cx: 50, cy: 50, rx: 25, ry: 15)
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .ellipse(cx: 50, cy: 50, rx: 25, ry: 15))
    }

    func testDrawingContextCircle() {
        let ctx = DrawingContext()
        ctx.circle(cx: 50, cy: 50, r: 25)
        XCTAssertEqual(ctx.commandCount, 1)
        // circle is implemented as ellipse with rx = ry = r
        XCTAssertEqual(ctx.commands[0], .ellipse(cx: 50, cy: 50, rx: 25, ry: 25))
    }

    func testDrawingContextText() {
        let ctx = DrawingContext()
        let style = TextStyle(fontSize: 14, color: .black)
        ctx.text("Hello", x: 100, y: 200, style: style)
        XCTAssertEqual(ctx.commandCount, 1)
        if case .text(let str, let x, let y, let cmdStyle) = ctx.commands[0] {
            XCTAssertEqual(str, "Hello")
            XCTAssertEqual(x, 100)
            XCTAssertEqual(y, 200)
            XCTAssertEqual(cmdStyle.fontSize, 14)
        } else {
            XCTFail("Expected text command")
        }
    }

    func testDrawingContextSetStrokeColor() {
        let ctx = DrawingContext()
        ctx.setStrokeColor(.red)
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .setStrokeColor(.red))
    }

    func testDrawingContextSetStrokeWidth() {
        let ctx = DrawingContext()
        ctx.setStrokeWidth(2.0)
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .setStrokeWidth(2.0))
    }

    func testDrawingContextSetFillColor() {
        let ctx = DrawingContext()
        ctx.setFillColor(.blue)
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .setFillColor(.blue))
    }

    func testDrawingContextStrokePath() {
        let ctx = DrawingContext()
        ctx.strokePath()
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .strokePath)
    }

    func testDrawingContextFillPath() {
        let ctx = DrawingContext()
        ctx.fillPath()
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .fillPath)
    }

    func testDrawingContextFillAndStrokePath() {
        let ctx = DrawingContext()
        ctx.fillAndStrokePath()
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .fillAndStrokePath)
    }

    func testDrawingContextSaveRestoreState() {
        let ctx = DrawingContext()
        ctx.saveState()
        ctx.restoreState()
        XCTAssertEqual(ctx.commandCount, 2)
        XCTAssertEqual(ctx.commands[0], .saveState)
        XCTAssertEqual(ctx.commands[1], .restoreState)
    }

    func testDrawingContextTranslate() {
        let ctx = DrawingContext()
        ctx.translate(10, 20)
        XCTAssertEqual(ctx.commandCount, 1)
        if case .pushTransform(let transform) = ctx.commands[0] {
            XCTAssertEqual(transform.tx, 10)
            XCTAssertEqual(transform.ty, 20)
        } else {
            XCTFail("Expected pushTransform command")
        }
    }

    func testDrawingContextScale() {
        let ctx = DrawingContext()
        ctx.scale(2.0, 3.0)
        XCTAssertEqual(ctx.commandCount, 1)
        if case .pushTransform(let transform) = ctx.commands[0] {
            XCTAssertEqual(transform.a, 2.0)
            XCTAssertEqual(transform.d, 3.0)
        } else {
            XCTFail("Expected pushTransform command")
        }
    }

    func testDrawingContextRotate() {
        let ctx = DrawingContext()
        ctx.rotate(.pi / 2)
        XCTAssertEqual(ctx.commandCount, 1)
        if case .pushTransform(let transform) = ctx.commands[0] {
            XCTAssertEqual(transform.a, cos(.pi / 2), accuracy: 0.0001)
            XCTAssertEqual(transform.b, sin(.pi / 2), accuracy: 0.0001)
        } else {
            XCTFail("Expected pushTransform command")
        }
    }

    func testDrawingContextCurrentTransform() {
        let ctx = DrawingContext()
        XCTAssertEqual(ctx.currentTransform, .identity)
        ctx.translate(10, 20)
        XCTAssertEqual(ctx.currentTransform.tx, 10)
        XCTAssertEqual(ctx.currentTransform.ty, 20)
        ctx.popTransform()
        XCTAssertEqual(ctx.currentTransform, .identity)
    }

    func testDrawingContextBounds() {
        let ctx = DrawingContext()
        XCTAssertEqual(ctx.bounds, .zero)

        ctx.moveTo(10, 20)
        ctx.lineTo(100, 150)
        let bounds = ctx.bounds
        XCTAssertEqual(bounds.minX, 10)
        XCTAssertEqual(bounds.minY, 20)
        XCTAssertEqual(bounds.maxX, 100)
        XCTAssertEqual(bounds.maxY, 150)
    }

    func testDrawingContextBoundsWithRect() {
        let ctx = DrawingContext()
        ctx.rect(10, 20, 100, 50)
        let bounds = ctx.bounds
        XCTAssertEqual(bounds.minX, 10)
        XCTAssertEqual(bounds.minY, 20)
        XCTAssertEqual(bounds.width, 100)
        XCTAssertEqual(bounds.height, 50)
    }

    func testDrawingContextBoundsWithEllipse() {
        let ctx = DrawingContext()
        ctx.ellipse(cx: 50, cy: 50, rx: 25, ry: 15)
        let bounds = ctx.bounds
        XCTAssertEqual(bounds.minX, 25)  // cx - rx
        XCTAssertEqual(bounds.minY, 35)  // cy - ry
        XCTAssertEqual(bounds.maxX, 75)  // cx + rx
        XCTAssertEqual(bounds.maxY, 65)  // cy + ry
    }

    func testDrawingContextClip() {
        let ctx = DrawingContext()
        ctx.clipRect(0, 0, 100, 100)
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .clipRect(x: 0, y: 0, width: 100, height: 100))
    }

    func testDrawingContextResetClip() {
        let ctx = DrawingContext()
        ctx.resetClip()
        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .resetClip)
    }

    // MARK: - SVG Export Tests

    func testDrawingContextRenderToSVG() {
        let ctx = DrawingContext()
        ctx.setStrokeColor(.red)
        ctx.setStrokeWidth(2.0)
        ctx.moveTo(10, 20)
        ctx.lineTo(100, 150)
        ctx.strokePath()

        let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
        XCTAssertTrue(svg.contains("<svg"))
        XCTAssertTrue(svg.contains("</svg>"))
        XCTAssertTrue(svg.contains("width=\"200\""))
        XCTAssertTrue(svg.contains("height=\"200\""))
    }

    func testDrawingContextRenderToSVGWithText() {
        let ctx = DrawingContext()
        let style = TextStyle(fontSize: 14, color: .black)
        ctx.text("Hello World", x: 50, y: 100, style: style)

        let svg = ctx.renderToSVG(size: CGSize(width: 200, height: 200))
        XCTAssertTrue(svg.contains("<text"))
        XCTAssertTrue(svg.contains("Hello World"))
    }

    // MARK: - PNG/PDF Export Tests

    #if canImport(ImageIO)
    func testDrawingContextRenderToPNG() {
        let ctx = DrawingContext()
        ctx.setFillColor(.blue)
        ctx.rect(10, 10, 80, 80)
        ctx.fillPath()

        let pngData = ctx.renderToPNG(size: CGSize(width: 100, height: 100))
        XCTAssertNotNil(pngData)
        XCTAssertGreaterThan(pngData?.count ?? 0, 0)
    }

    func testDrawingContextRenderToPNGWithScale() {
        let ctx = DrawingContext()
        ctx.setFillColor(.red)
        ctx.rect(0, 0, 50, 50)
        ctx.fillPath()

        let pngData = ctx.renderToPNG(size: CGSize(width: 100, height: 100), scale: 2.0)
        XCTAssertNotNil(pngData)
    }

    func testDrawingContextRenderToPDF() {
        let ctx = DrawingContext()
        ctx.setStrokeColor(.black)
        ctx.moveTo(0, 0)
        ctx.lineTo(100, 100)
        ctx.strokePath()

        let pdfData = ctx.renderToPDF(size: CGSize(width: 200, height: 200))
        XCTAssertNotNil(pdfData)
        XCTAssertGreaterThan(pdfData?.count ?? 0, 0)
    }
    #endif

    // MARK: - Complex Path Tests

    func testDrawingContextComplexPath() {
        let ctx = DrawingContext()
        ctx.moveTo(10, 10)
        ctx.lineTo(100, 10)
        ctx.lineTo(100, 100)
        ctx.lineTo(10, 100)
        ctx.closePath()

        XCTAssertEqual(ctx.commandCount, 5)
        XCTAssertEqual(ctx.commands[0], .moveTo(x: 10, y: 10))
        XCTAssertEqual(ctx.commands[1], .lineTo(x: 100, y: 10))
        XCTAssertEqual(ctx.commands[2], .lineTo(x: 100, y: 100))
        XCTAssertEqual(ctx.commands[3], .lineTo(x: 10, y: 100))
        XCTAssertEqual(ctx.commands[4], .closePath)
    }

    func testDrawingContextCurvePath() {
        let ctx = DrawingContext()
        ctx.moveTo(0, 0)
        ctx.curveTo(cp1x: 25, cp1y: 50, cp2x: 75, cp2y: 50, x: 100, y: 0)

        XCTAssertEqual(ctx.commandCount, 2)
        XCTAssertEqual(ctx.commands[1], .curveTo(cp1x: 25, cp1y: 50, cp2x: 75, cp2y: 50, x: 100, y: 0))
    }

    func testDrawingContextQuadCurvePath() {
        let ctx = DrawingContext()
        ctx.moveTo(0, 0)
        ctx.quadCurveTo(cpx: 50, cpy: 100, x: 100, y: 0)

        XCTAssertEqual(ctx.commandCount, 2)
        XCTAssertEqual(ctx.commands[1], .quadCurveTo(cpx: 50, cpy: 100, x: 100, y: 0))
    }

    func testDrawingContextArc() {
        let ctx = DrawingContext()
        ctx.arc(cx: 50, cy: 50, r: 25, startAngle: 0, endAngle: .pi)

        XCTAssertEqual(ctx.commandCount, 1)
        XCTAssertEqual(ctx.commands[0], .arc(cx: 50, cy: 50, r: 25, startAngle: 0, endAngle: .pi, clockwise: false))
    }

    // MARK: - Color Name Tests

    func testColorFromNameCaseInsensitive() {
        XCTAssertEqual(Color(name: "RED"), Color.red)
        XCTAssertEqual(Color(name: "Red"), Color.red)
        XCTAssertEqual(Color(name: "BLUE"), Color.blue)
    }

    func testColorFromNameGray() {
        XCTAssertEqual(Color(name: "gray"), Color.gray)
        XCTAssertEqual(Color(name: "grey"), Color.gray)
        XCTAssertEqual(Color(name: "lightgray"), Color.lightGray)
        XCTAssertEqual(Color(name: "lightgrey"), Color.lightGray)
        XCTAssertEqual(Color(name: "darkgray"), Color.darkGray)
        XCTAssertEqual(Color(name: "darkgrey"), Color.darkGray)
    }

    func testColorFromNameTransparent() {
        XCTAssertEqual(Color(name: "none"), Color.clear)
        XCTAssertEqual(Color(name: "transparent"), Color.clear)
    }
}

#!/usr/bin/env swift

import Foundation
import AppKit

// Icon sizes needed for watchOS - pixel sizes that match Contents.json expectations
// Format: pixel size to generate
let iconPixelSizes: [Int] = [
    48,   // notificationCenter 24x24@2x (38mm)
    55,   // notificationCenter 27.5x27.5@2x (42mm)
    58,   // companionSettings 29x29@2x
    66,   // notificationCenter 33x33@2x (45mm)
    80,   // appLauncher 40x40@2x (38mm)
    87,   // companionSettings 29x29@3x
    88,   // appLauncher 44x44@2x (40mm)
    92,   // appLauncher 46x46@2x (41mm)
    100,  // appLauncher 50x50@2x (44mm)
    102,  // appLauncher 51x51@2x (45mm)
    108,  // appLauncher 54x54@2x (49mm)
    172,  // quickLook 86x86@2x (38mm)
    196,  // quickLook 98x98@2x (42mm)
    216,  // quickLook 108x108@2x (44mm)
    234,  // quickLook 117x117@2x (45mm)
    258,  // quickLook 129x129@2x (49mm)
    1024, // watch-marketing 1024x1024@1x
]

// Colors from Theme
let backgroundColor = NSColor(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x1E/255.0, alpha: 1.0)
let accentColor = NSColor(red: 0x30/255.0, green: 0xD1/255.0, blue: 0x58/255.0, alpha: 1.0)

func generateIcon(pixelSize: Int) -> NSBitmapImageRep {
    // Use NSBitmapImageRep directly to avoid Retina 2x scaling
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let s = Double(pixelSize)
    let rect = NSRect(x: 0, y: 0, width: s, height: s)

    // Fill background
    backgroundColor.setFill()
    rect.fill()

    // Two bubbles side by side like SF Symbol bubble.left.and.bubble.right.fill
    // Left bubble is slightly lower, right bubble slightly higher

    let bubbleWidth = s * 0.28
    let bubbleHeight = s * 0.22
    let cornerRadius = s * 0.06
    let tailWidth = s * 0.06
    let tailHeight = s * 0.05
    let gap = s * 0.04  // gap between bubbles

    // Center the pair
    let totalWidth = bubbleWidth * 2 + gap
    let startX = (s - totalWidth) / 2

    let centerY = s * 0.48
    let verticalOffset = s * 0.06  // how much the bubbles are offset from each other

    accentColor.setFill()

    // LEFT BUBBLE (slightly lower, tail on bottom-left)
    let leftX = startX
    let leftY = centerY - verticalOffset

    // Main bubble body
    let leftBubble = NSBezierPath(roundedRect: NSRect(
        x: leftX,
        y: leftY,
        width: bubbleWidth,
        height: bubbleHeight
    ), xRadius: cornerRadius, yRadius: cornerRadius)
    leftBubble.fill()

    // Left bubble tail (bottom-left, pointing left and down)
    let leftTail = NSBezierPath()
    leftTail.move(to: NSPoint(x: leftX + cornerRadius * 0.5, y: leftY + cornerRadius))
    leftTail.line(to: NSPoint(x: leftX - tailWidth * 0.3, y: leftY - tailHeight))
    leftTail.line(to: NSPoint(x: leftX + tailWidth * 1.2, y: leftY + cornerRadius * 0.3))
    leftTail.close()
    leftTail.fill()

    // RIGHT BUBBLE (slightly higher, tail on bottom-right)
    let rightX = startX + bubbleWidth + gap
    let rightY = centerY + verticalOffset

    // Main bubble body
    let rightBubble = NSBezierPath(roundedRect: NSRect(
        x: rightX,
        y: rightY,
        width: bubbleWidth,
        height: bubbleHeight
    ), xRadius: cornerRadius, yRadius: cornerRadius)
    rightBubble.fill()

    // Right bubble tail (bottom-right, pointing right and down)
    let rightTail = NSBezierPath()
    rightTail.move(to: NSPoint(x: rightX + bubbleWidth - cornerRadius * 0.5, y: rightY + cornerRadius))
    rightTail.line(to: NSPoint(x: rightX + bubbleWidth + tailWidth * 0.3, y: rightY - tailHeight))
    rightTail.line(to: NSPoint(x: rightX + bubbleWidth - tailWidth * 1.2, y: rightY + cornerRadius * 0.3))
    rightTail.close()
    rightTail.fill()

    NSGraphicsContext.restoreGraphicsState()

    return rep
}

func saveIcon(_ rep: NSBitmapImageRep, to path: String) {
    guard let pngData = rep.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG data")
        return
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("Created: \(path) (\(rep.pixelsWide)x\(rep.pixelsHigh))")
    } catch {
        print("Failed to write \(path): \(error)")
    }
}

// Output directory
let outputDir = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : FileManager.default.currentDirectoryPath + "/WatchGPT Watch App/Assets.xcassets/AppIcon.appiconset"

// Create output directory if needed
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

// Generate all icons
for pixelSize in iconPixelSizes {
    let filename = "AppIcon-\(pixelSize).png"
    let image = generateIcon(pixelSize: pixelSize)
    let path = "\(outputDir)/\(filename)"
    saveIcon(image, to: path)
}

print("\nDone! Generated \(iconPixelSizes.count) watch app icons.")

// Run on macOS with `swift scripts/make-icon.swift` to regenerate original vector icons.
import AppKit
import Foundation
import ImageIO

let directory = "PocketFlap/Assets.xcassets/AppIcon.appiconset"
try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
let entries: [(String, String, String)] = [
    ("iphone", "20x20", "2x"), ("iphone", "20x20", "3x"),
    ("iphone", "29x29", "2x"), ("iphone", "29x29", "3x"),
    ("iphone", "40x40", "2x"), ("iphone", "40x40", "3x"),
    ("iphone", "60x60", "2x"), ("iphone", "60x60", "3x"),
    ("ipad", "20x20", "1x"), ("ipad", "20x20", "2x"),
    ("ipad", "29x29", "1x"), ("ipad", "29x29", "2x"),
    ("ipad", "40x40", "1x"), ("ipad", "40x40", "2x"),
    ("ipad", "76x76", "1x"), ("ipad", "76x76", "2x"),
    ("ipad", "83.5x83.5", "2x"), ("ios-marketing", "1024x1024", "1x")
]
var images: [[String: String]] = []
for (idiom, size, scale) in entries {
    let pixels = Int(Double(size.components(separatedBy: "x")[0])! * Double(scale.dropLast())!)
    let context = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8,
                            bytesPerRow: pixels * 4, space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    context.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
    func shape(_ rect: CGRect, _ color: NSColor, oval: Bool = false) {
        context.setFillColor(color.cgColor)
        if oval { context.fillEllipse(in: rect) } else { context.fill(rect) }
    }
    let ink = NSColor(calibratedRed: 0.08, green: 0.17, blue: 0.23, alpha: 1)
    shape(CGRect(x: 0, y: 0, width: 1024, height: 1024), NSColor(calibratedRed: 0.76, green: 0.92, blue: 0.92, alpha: 1))
    shape(CGRect(x: 780, y: 0, width: 170, height: 290), NSColor(calibratedRed: 0.12, green: 0.57, blue: 0.48, alpha: 1))
    shape(CGRect(x: 780, y: 734, width: 170, height: 290), NSColor(calibratedRed: 0.12, green: 0.57, blue: 0.48, alpha: 1))
    shape(CGRect(x: 180, y: 310, width: 560, height: 470), ink, oval: true)
    shape(CGRect(x: 208, y: 338, width: 504, height: 414), NSColor(calibratedRed: 1, green: 0.76, blue: 0.23, alpha: 1), oval: true)
    shape(CGRect(x: 155, y: 335, width: 295, height: 200), NSColor(calibratedRed: 0.97, green: 0.54, blue: 0.23, alpha: 1), oval: true)
    shape(CGRect(x: 535, y: 535, width: 150, height: 168), .white, oval: true)
    shape(CGRect(x: 614, y: 570, width: 49, height: 79), ink, oval: true)
    shape(CGRect(x: 675, y: 437, width: 160, height: 90), NSColor(calibratedRed: 0.95, green: 0.35, blue: 0.24, alpha: 1))
    let filename = "icon-\(pixels).png"
    let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "\(directory)/\(filename)") as CFURL,
                                                       "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, context.makeImage()!, nil)
    precondition(CGImageDestinationFinalize(destination), "Could not save icon")
    images.append(["idiom": idiom, "size": size, "scale": scale, "filename": filename])
}
let contents: [String: Any] = ["images": images, "info": ["author": "xcode", "version": 1] as [String: Any]]
try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    .write(to: URL(fileURLWithPath: "\(directory)/Contents.json"))

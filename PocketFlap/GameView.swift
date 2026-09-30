import UIKit

final class GameView: UIView {
    private var game = GameModel()
    private var best = UserDefaults.standard.integer(forKey: "bestScore")
    private let pauseButton = UIButton(type: .system)
    private var scale: CGFloat = 1
    private var origin = CGPoint.zero
    private let ink = UIColor(red: 0.08, green: 0.17, blue: 0.23, alpha: 1)
    private let teal = UIColor(red: 0.12, green: 0.57, blue: 0.48, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isMultipleTouchEnabled = false
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.setTitleColor(.white, for: .normal)
        pauseButton.backgroundColor = ink
        pauseButton.layer.cornerRadius = 16
        pauseButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        pauseButton.addTarget(self, action: #selector(togglePause), for: .touchUpInside)
        addSubview(pauseButton)
        accessibilityLabel = "Pocket Flap game. Tap to fly through the gaps."
    }

    required init?(coder: NSCoder) { fatalError("Use init(frame:)") }

    override func layoutSubviews() {
        super.layoutSubviews()
        scale = min(bounds.width / 390, bounds.height / 780)
        origin = CGPoint(x: (bounds.width - 390 * scale) / 2, y: (bounds.height - 780 * scale) / 2)
        pauseButton.frame = CGRect(x: origin.x + 292 * scale, y: origin.y + 18 * scale,
                                   width: 82 * scale, height: max(44, 40 * scale))
        setNeedsDisplay()
    }

    func pause() { game.pause(); refresh() }

    @objc private func togglePause() {
        if game.phase == .paused { game.resume() } else { game.pause() }
        refresh()
    }

    func advance(_ elapsed: Double) {
        let oldPhase = game.phase
        game.update(elapsed)
        if game.score > best {
            best = game.score
            UserDefaults.standard.set(best, forKey: "bestScore")
        }
        if oldPhase != .over && game.phase == .over {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        refresh()
    }

    private func refresh() {
        pauseButton.isHidden = game.phase == .ready || game.phase == .over
        pauseButton.setTitle(game.phase == .paused ? "Resume" : "Pause", for: .normal)
        setNeedsDisplay()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch game.phase {
        case .over: game.restart(); game.flap()
        case .paused: game.resume()
        case .ready, .playing: game.flap()
        }
        refresh()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.translateBy(x: origin.x, y: origin.y)
        context.scaleBy(x: scale, y: scale)
        context.clip(to: CGRect(x: 0, y: 0, width: 390, height: 780))
        fill(CGRect(x: 0, y: 0, width: 390, height: 780), UIColor(red: 0.76, green: 0.92, blue: 0.92, alpha: 1))
        // Original vector artwork; no downloaded textures or game assets.
        for (x, y) in [(35.0, 155.0), (255.0, 235.0), (135.0, 470.0)] {
            ellipse(CGRect(x: x, y: y, width: 100, height: 24), .white.withAlphaComponent(0.65))
            ellipse(CGRect(x: x + 22, y: y - 18, width: 44, height: 40), .white.withAlphaComponent(0.65))
        }
        for x in stride(from: -40, through: 390, by: 90) {
            ellipse(CGRect(x: x, y: 590, width: 150, height: 170), UIColor(red: 0.57, green: 0.79, blue: 0.68, alpha: 1))
        }
        for pipe in game.pipes {
            let top = CGFloat(pipe.gapY - GameModel.gap / 2)
            let bottom = CGFloat(pipe.gapY + GameModel.gap / 2)
            let x = CGFloat(pipe.x)
            fill(CGRect(x: x, y: 0, width: 66, height: top), teal)
            fill(CGRect(x: x, y: bottom, width: 66, height: 690 - bottom), teal)
            fill(CGRect(x: x + 7, y: 0, width: 8, height: top - 12), .white.withAlphaComponent(0.2))
            fill(CGRect(x: x + 7, y: bottom + 12, width: 8, height: 690 - bottom - 12), .white.withAlphaComponent(0.2))
            fill(CGRect(x: x, y: top - 18, width: 66, height: 18), ink)
            fill(CGRect(x: x, y: bottom, width: 66, height: 18), ink)
        }
        fill(CGRect(x: 0, y: 690, width: 390, height: 90), UIColor(red: 0.97, green: 0.88, blue: 0.66, alpha: 1))
        fill(CGRect(x: 0, y: 690, width: 390, height: 7), teal)
        for x in stride(from: 0, through: 390, by: 24) {
            fill(CGRect(x: x, y: 709, width: 12, height: 4), ink.withAlphaComponent(0.12))
        }

        context.saveGState()
        context.translateBy(x: 105, y: CGFloat(game.birdY))
        context.rotate(by: CGFloat(max(-0.35, min(0.9, game.velocity / 700))))
        ellipse(CGRect(x: -20, y: -17, width: 40, height: 34), ink)
        ellipse(CGRect(x: -17, y: -14, width: 34, height: 28), UIColor(red: 1, green: 0.76, blue: 0.23, alpha: 1))
        ellipse(CGRect(x: -20, y: 0, width: 22, height: 13), UIColor(red: 0.97, green: 0.54, blue: 0.23, alpha: 1))
        ellipse(CGRect(x: 6, y: -10, width: 12, height: 13), .white)
        ellipse(CGRect(x: 12, y: -7, width: 4, height: 6), ink)
        fill(CGRect(x: 15, y: 2, width: 13, height: 7), UIColor(red: 0.95, green: 0.35, blue: 0.24, alpha: 1), radius: 3)
        context.restoreGState()

        text("BEST  \(best)", y: 31, size: 14, weight: .bold, x: 20, width: 140, alignment: .left)
        text("\(game.score)", y: 74, size: 60, weight: .heavy)
        text("POCKET FLAP  /  JUST ONE MORE", y: 748, size: 12, weight: .semibold)
        switch game.phase {
        case .ready:
            card(title: "Pocket Flap", subtitle: "Small wings. Big ambitions.", action: "TAP ANYWHERE TO FLY")
        case .paused:
            card(title: "Take a breather", subtitle: "Your flight is on pause.", action: "TAP TO RESUME")
        case .over:
            card(title: "Nice flight!", subtitle: "Score \(game.score)   ·   Best \(best)", action: "TAP TO TRY AGAIN")
        case .playing: break
        }
        context.restoreGState()
        pauseButton.isHidden = game.phase == .ready || game.phase == .over
    }

    private func card(title: String, subtitle: String, action: String) {
        fill(CGRect(x: 22, y: 395, width: 346, height: 175), ink.withAlphaComponent(0.12), radius: 25)
        fill(CGRect(x: 22, y: 389, width: 346, height: 175), UIColor(red: 1, green: 0.98, blue: 0.91, alpha: 1), radius: 25)
        text(title, y: 414, size: 30, weight: .heavy)
        text(subtitle, y: 456, size: 16, weight: .medium)
        fill(CGRect(x: 48, y: 501, width: 294, height: 42), ink, radius: 14)
        text(action, y: 515, size: 13, weight: .bold, color: .white)
    }

    private func fill(_ rect: CGRect, _ color: UIColor, radius: CGFloat = 0) {
        color.setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: radius).fill()
    }

    private func ellipse(_ rect: CGRect, _ color: UIColor) {
        color.setFill()
        UIBezierPath(ovalIn: rect).fill()
    }

    private func text(_ value: String, y: CGFloat, size: CGFloat, weight: UIFont.Weight,
                      color: UIColor? = nil, x: CGFloat = 0, width: CGFloat = 390,
                      alignment: NSTextAlignment = .center) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        (value as NSString).draw(in: CGRect(x: x, y: y, width: width, height: size * 1.5),
                                withAttributes: [.font: UIFont.systemFont(ofSize: size, weight: weight),
                                                 .foregroundColor: color ?? ink, .paragraphStyle: paragraph])
    }
}

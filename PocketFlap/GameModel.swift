import Foundation

/// Fixed logical coordinates keep the difficulty identical across device sizes.
struct GameModel {
    enum Phase { case ready, playing, paused, over }
    struct Pipe {
        var x: Double
        let gapY: Double
        var scored = false
    }

    static let width = 390.0
    static let height = 780.0
    static let floor = 690.0
    static let birdX = 105.0
    static let radius = 15.0
    static let pipeWidth = 66.0
    static let gap = 182.0
    private(set) var phase: Phase = .ready
    private(set) var birdY = 330.0
    private(set) var velocity = 0.0
    private(set) var score = 0
    private(set) var pipes: [Pipe] = []
    private var spawnRemaining = 0.9

    mutating func flap() {
        if phase == .ready { phase = .playing }
        guard phase == .playing else { return }
        velocity = -340
    }

    mutating func restart() { self = GameModel() }
    mutating func pause() { if phase == .playing { phase = .paused } }
    mutating func resume() { if phase == .paused { phase = .playing } }

    mutating func update(_ elapsed: Double, nextGap: () -> Double = { Double.random(in: 210...470) }) {
        guard phase == .playing, elapsed > 0 else { return }
        // Ignore large scheduling gaps; integrate at 120 Hz to avoid tunneling.
        var remaining = min(elapsed, 0.1)
        while remaining > 0 && phase == .playing {
            let dt = min(remaining, 1.0 / 120.0)
            remaining -= dt
            velocity += 980 * dt
            birdY += velocity * dt
            spawnRemaining -= dt
            if spawnRemaining <= 0 {
                pipes.append(Pipe(x: Self.width + 12, gapY: min(470, max(210, nextGap()))))
                spawnRemaining += 1.65
            }
            let speed = 165.0 + min(Double(score) * 2, 45)
            for index in pipes.indices {
                pipes[index].x -= speed * dt
                let pipe = pipes[index]
                if Self.hitsPipe(birdY: birdY, pipe: pipe) { phase = .over }
                if !pipe.scored && pipe.x + Self.pipeWidth < Self.birdX - Self.radius {
                    pipes[index].scored = true
                    score += 1
                }
            }
            pipes.removeAll { $0.x + Self.pipeWidth < -10 }
            if birdY - Self.radius <= 0 || birdY + Self.radius >= Self.floor {
                birdY = min(Self.floor - Self.radius, max(Self.radius, birdY))
                phase = .over
            }
        }
    }

    static func hitsPipe(birdY: Double, pipe: Pipe) -> Bool {
        let rectangles = [
            (pipe.x, 0.0, pipeWidth, pipe.gapY - gap / 2),
            (pipe.x, pipe.gapY + gap / 2, pipeWidth, floor - pipe.gapY - gap / 2)
        ]
        return rectangles.contains { x, y, width, height in
            let dx = birdX - min(x + width, max(x, birdX))
            let dy = birdY - min(y + height, max(y, birdY))
            return dx * dx + dy * dy <= radius * radius
        }
    }
}

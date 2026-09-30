import Foundation

func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else { fatalError(message) }
}

var game = GameModel()
game.update(0.1)
check(game.birdY == 330 && game.phase == .ready, "Ready state must not move")
game.flap()
game.update(1.0 / 60)
check(game.birdY < 330, "A flap must lift the bird")
game.pause()
let pausedY = game.birdY
game.update(1)
game.flap()
check(game.phase == .paused && game.birdY == pausedY, "Pause must freeze play")
game.resume()
for _ in 0..<300 { game.update(1.0 / 60) }
check(game.phase == .over, "Falling must end the game")
game.restart()
check(game.phase == .ready && game.score == 0 && game.pipes.isEmpty, "Restart must reset the run")

let pipe = GameModel.Pipe(x: 90, gapY: 340)
check(!GameModel.hitsPipe(birdY: 340, pipe: pipe), "Gap must be passable")
check(GameModel.hitsPipe(birdY: 240, pipe: pipe), "Top pipe must collide")
check(GameModel.hitsPipe(birdY: 440, pipe: pipe), "Bottom pipe must collide")
check(!GameModel.hitsPipe(birdY: 240, pipe: .init(x: 160, gapY: 340)), "Distant pipes must not collide")

// A deterministic autopilot must survive, pass pipes, and score each once.
game.flap()
for _ in 0..<1_200 {
    if game.birdY > 365 && game.velocity > 0 { game.flap() }
    game.update(1.0 / 120, nextGap: { 340 })
}
check(game.phase == .playing, "A consistent flight through fixed gaps must survive")
check(game.score == 5, "Score must increase exactly once per passed pipe")
check(game.pipes.count < 5, "Offscreen pipes must be removed")
var longFrame = GameModel()
var cappedFrame = GameModel()
longFrame.flap(); cappedFrame.flap()
longFrame.update(20); cappedFrame.update(0.1)
check(abs(longFrame.birdY - cappedFrame.birdY) < 0.001, "Long frame must be capped")
print("PASS: start, flap, pause, resume, death, restart, collision, scoring, cleanup, time cap")

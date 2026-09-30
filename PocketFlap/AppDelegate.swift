import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = GameViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        (window?.rootViewController as? GameViewController)?.pauseGame()
    }
}

final class GameViewController: UIViewController {
    private let game = GameView()
    private var displayLink: CADisplayLink?
    private var previousTime: CFTimeInterval = 0
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.08, green: 0.17, blue: 0.23, alpha: 1)
        game.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(game)
        NSLayoutConstraint.activate([
            game.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            game.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            game.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            game.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previousTime = 0
        let link = CADisplayLink(target: self, selector: #selector(frame(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
        displayLink = nil
        pauseGame()
    }

    func pauseGame() { game.pause(); previousTime = 0 }

    @objc private func frame(_ link: CADisplayLink) {
        if previousTime != 0 { game.advance(link.timestamp - previousTime) }
        previousTime = link.timestamp
    }
}

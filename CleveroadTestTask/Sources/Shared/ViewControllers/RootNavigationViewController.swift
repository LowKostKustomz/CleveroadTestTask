import UIKit

protocol RootNavigationProtocol {
    func setRootContent(_ content: UIViewController)
}

class RootNavigationViewController: UIViewController, RootNavigationProtocol {

    // MARK: - Private properties

    private let contentContainer: UIView = UIView()
    private var viewAppeared: Bool = false
    private var currentContent: UIViewController? = nil

    // MARK: - Public properties

    weak var appController: AppController? = nil

    // MARK: - Overridden methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        self.setupContentView()
        self.layoutViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !self.viewAppeared {
            self.viewAppeared = true
            self.appController?.onRootWillAppear()
        }
    }

    // MARK: - Public methods

    func setRootContent(_ contentViewController: UIViewController) {
        let previousContentViewController = self.currentContent

        self.addChild(contentViewController)
        self.contentContainer.addSubview(contentViewController.view)
        contentViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentViewController.didMove(toParent: self)
        self.currentContent = contentViewController

        previousContentViewController?.willMove(toParent: nil)
        previousContentViewController?.view.removeFromSuperview()
        previousContentViewController?.removeFromParent()
    }

    // MARK: - Private methods

    private func setupView() {
        self.view.backgroundColor = .white
    }

    private func setupContentView() {
        self.contentContainer.backgroundColor = .clear
    }

    private func layoutViews() {
        self.view.addSubview(self.contentContainer)

        self.contentContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

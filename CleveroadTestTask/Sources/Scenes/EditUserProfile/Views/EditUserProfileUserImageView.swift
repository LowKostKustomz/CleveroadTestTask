import UIKit
import Nuke

class EditUserProfileUserImageView: UIView {

    // MARK: - Private properties

    private let imageView: UIImageView = UIImageView()

    private let imageViewSize: CGFloat = 96

    // MARK: - Public properties

    var imageURL: URL? = nil {
        didSet {
            self.imageView.image = nil
            guard let url = self.imageURL else { return }
            let imageRequest = ImageRequest(url: url)
            loadImage(
                with: imageRequest,
                into: self.imageView,
                completion: { [weak self] (_, _) in
                    self?.imageView.hideLoading()
            })
        }
    }

    // MARK: -

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func commonInit() {
        self.setupView()
        self.setupImageView()
        self.layoutViews()
    }

    private func setupView() {
        self.backgroundColor = .clear
    }

    private func setupImageView() {
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = self.imageViewSize / 2.0
    }

    private func layoutViews() {
        self.addSubview(self.imageView)

        self.imageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(self.imageViewSize)
            make.left.greaterThanOrEqualToSuperview().inset(15)
            make.right.lessThanOrEqualToSuperview().inset(15)
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().inset(40)
            make.bottom.lessThanOrEqualToSuperview().inset(48)
        }
    }
}

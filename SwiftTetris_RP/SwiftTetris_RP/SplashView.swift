import UIKit

class SplashView: UIView {

    let centerPalm = UIImageView(image: UIImage(named: "Image"))
    let leftPalm = UIImageView(image: UIImage(named: "Image"))
    let rightPalm = UIImageView(image: UIImage(named: "Image"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .white
        [leftPalm, centerPalm, rightPalm].forEach {
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        // Center all on top of each other
        NSLayoutConstraint.activate([
            centerPalm.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPalm.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerPalm.widthAnchor.constraint(equalToConstant: 100),
            
            leftPalm.centerXAnchor.constraint(equalTo: centerXAnchor),
            leftPalm.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftPalm.widthAnchor.constraint(equalToConstant: 100),
            
            rightPalm.centerXAnchor.constraint(equalTo: centerXAnchor),
            rightPalm.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightPalm.widthAnchor.constraint(equalToConstant: 100),
        ])
    }

    func startAnimation(completion: @escaping () -> Void) {
        leftPalm.alpha = 0
        rightPalm.alpha = 0
        centerPalm.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        UIView.animate(withDuration: 0.5, animations: {
            self.leftPalm.alpha = 1
            self.leftPalm.transform = CGAffineTransform(translationX: -80, y: 0)

            self.rightPalm.alpha = 1
            self.rightPalm.transform = CGAffineTransform(translationX: 80, y: 0)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
                completion()
            })
        })
    }
}

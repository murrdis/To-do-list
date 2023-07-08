import UIKit

protocol SpectrumViewDelegate: AnyObject {
    func spectrumView(
        _ view: SpectrumView,
        didSelect color: UIColor
    )
}
class SpectrumView: UIView {
    weak var delegate: SpectrumViewDelegate?

    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: 100)
    }
    
    private lazy var gradientLayer = makeGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        CATransaction.commit()
    }
    
    private func setup() {
        layer.addSublayer(gradientLayer)
        translatesAutoresizingMaskIntoConstraints = false
        
        addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(onTap)
            )
        )
    }
 
    @objc func onTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard
            let color = gradientLayer.colorOfPoint(point: gestureRecognizer.location(in: self))
        else { return }

        delegate?.spectrumView(self, didSelect: color)
    }
    
    private func makeGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 1, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.frame = bounds
        return layer
    }
}

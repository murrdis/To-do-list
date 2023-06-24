import UIKit

protocol ColorPickerDelegate: AnyObject {
    func todoItemColorView(_ view: ColorPicker, didSelect color: UIColor)
}

final class ColorPicker: UIView {
    weak var delegate: ColorPickerDelegate?
    
    private lazy var spectrumView = makeSpectrumView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setup() {
        addSubview(spectrumView)
        
        
        setupConstraints()
    }

    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                spectrumView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                spectrumView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
                spectrumView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
                spectrumView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
            ]
        )
    }
    
    private func makeSpectrumView() -> SpectrumView {
        let view = SpectrumView()
        view.delegate = self
        return view
    }
}

extension ColorPicker: SpectrumViewDelegate {
    func spectrumView(_ view: SpectrumView, didSelect color: UIColor) {
        delegate?.todoItemColorView(self, didSelect: color)
    }
}

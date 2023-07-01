import UIKit
import TodoListPackage

class TodoItemColorPickerView: UIStackView {
    
    private var color: HEX = (Colors.labelPrimary?.hex)!
    private var alphaComponent: CGFloat = 1.0
    
    func getTaskColor() -> HEX {
        return color
    }
    
    func setTaskColor(color: HEX) {
        if color != (Colors.labelPrimary?.hex)! {
            self.color = color
            colorSwitch.isOn = true

            colorButton.setTitle(color, for: .normal)
            colorButton.setTitleColor(UIColor(hex: color), for: .normal)
        }
        else {
            colorSwitch.isOn = false
            colorButton.setTitle("", for: .normal)
        }
    }
    
    
    private let colorPicker: ColorPicker = {
        let colorPicker = ColorPicker()
        
        return colorPicker
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет текста"
        label.font = Fonts.body
        label.textColor = Colors.labelPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let colorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.titleLabel?.font = Fonts.footnote
        button.setTitleColor(Colors.colorBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(openColorPicker), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func openColorPicker() {
        guard colorSwitch.isOn else { return }
        UIView.animate(withDuration: 0.5) {
            self.colorPickerView.isHidden.toggle()
        }
    }
    
    private lazy var colorPickerView: UIStackView = {
        let bottomDivider = DividerView()
        let stack = UIStackView(arrangedSubviews: [
            DividerView(),
            colorPicker,
            bottomDivider,
            alphaPicker
        ])
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins.top = 10
        stack.isHidden = true
        stack.setCustomSpacing(15, after: bottomDivider)
        return stack
    }()
    
    private lazy var alphaPicker: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10.0
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Яркость"
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(slider)
        
        return stackView
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 1.0
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        return slider
    }()

    
    @objc
    private func sliderValueChanged(_ sender: UISlider) {
        alphaComponent = CGFloat(sender.value)
        self.color = UIColor(hex: color)!.withAlphaComponent(alphaComponent).hex!
        
        colorButton.setTitle(color, for: .normal)
        colorButton.setTitleColor(UIColor(hex: color), for: .normal)
    }
    
    private let colorSwitch: UISwitch = {
        let colorSwitch = UISwitch()
        colorSwitch.addTarget(self, action: #selector(didTapColorSwitch), for: .valueChanged)
        return colorSwitch
    }()
    
    
    @objc private func didTapColorSwitch(_ sender: UISwitch) {
        if colorSwitch.isOn {
            
            colorButton.setTitle(color, for: .normal)
        }
        else {
            color = (Colors.labelPrimary?.hex)!
            
            colorButton.setTitle("", for: .normal)
            colorButton.setTitleColor(UIColor(hex: color), for: .normal)
            UIView.animate(withDuration: 0.5) {
                self.colorPickerView.isHidden = true
            }
        }
    }
    
    
    private lazy var vColorStack: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                colorLabel,
                colorButton
            ]
        )
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var hColorStack: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                vColorStack,
                colorSwitch
            ]
        )
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        axis = .vertical
        backgroundColor = .clear
        spacing = 10
        
        addArrangedSubview(hColorStack)
        addArrangedSubview(colorPickerView)
        translatesAutoresizingMaskIntoConstraints = false
        colorPicker.delegate = self
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


extension TodoItemColorPickerView: ColorPickerDelegate {
    func todoItemColorView(_ view: ColorPicker, didSelect color: UIColor) {
        colorButton.setTitle(color.hex, for: .normal)
        colorButton.setTitleColor(color, for: .normal)
        self.color = color.withAlphaComponent(alphaComponent).hex!
    }
}

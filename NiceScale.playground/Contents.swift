import UIKit
import PlaygroundSupport

class ScaleView : UIView {
    required init?(coder aDecoder: NSCoder) { fatalError("not supported") }
    init() {
        super.init(frame: CGRect.zero)
        isOpaque = false
    }
    
    var minValue: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var maxValue: Double = 500.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        UIColor.black.setStroke()
        path.lineWidth = 2
        path.move(to: CGPoint(x: bounds.minX, y: 100))
        path.addLine(to: CGPoint(x: bounds.maxX, y: 100))
        path.close()
        path.stroke()
    }
}

class SliderView : UIView {
    weak var slider: UISlider?
    weak var valueLabel: UILabel?
    var onValueChanged: (Double) -> Void = { _ in }

    required init?(coder aDecoder: NSCoder) { fatalError("not supported") }
    init(name: String, initialValue: Double) {
        super.init(frame: CGRect.zero)

        let nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = name
        
        let slider = UISlider(frame: CGRect.zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 10000
        slider.value = Float(initialValue)
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        self.slider = slider
        
        let valueLabel = UILabel(frame: CGRect.zero)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = "\(initialValue)"
        self.valueLabel = valueLabel
        
        addSubview(nameLabel)
        addSubview(slider)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
            nameLabel.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
            slider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50),
            slider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -80),
            slider.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            slider.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
            valueLabel.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
        ])
    }
    
    @objc func valueChanged() {
        guard let valueLabel = valueLabel, let slider = slider else { return }
        
        valueLabel.text = "\(slider.value)"
        onValueChanged(Double(slider.value))
    }
}

class NiceScaleViewController : UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .white

        let scaleView = ScaleView()
        scaleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scaleView)

        let controlPanelView = UIStackView(frame: CGRect.zero)
        controlPanelView.axis = .vertical
        controlPanelView.alignment = .fill
        controlPanelView.distribution = .fillProportionally
        controlPanelView.spacing = 16
        controlPanelView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlPanelView)

        NSLayoutConstraint.activate([
            scaleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            scaleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            scaleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            scaleView.bottomAnchor.constraint(equalTo: controlPanelView.topAnchor, constant: -8),
            controlPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            controlPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            controlPanelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let minSliderView = SliderView(name: "min", initialValue: scaleView.minValue)
        minSliderView.onValueChanged = { scaleView.minValue = $0 }
        controlPanelView.addArrangedSubview(minSliderView)
        
        let maxSliderView = SliderView(name: "max", initialValue: scaleView.maxValue)
        maxSliderView.onValueChanged = { scaleView.maxValue = $0 }
        controlPanelView.addArrangedSubview(maxSliderView)
    }
}

PlaygroundPage.current.liveView = NiceScaleViewController()


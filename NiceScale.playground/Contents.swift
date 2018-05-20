import UIKit
import PlaygroundSupport

// This class is based written in https://stackoverflow.com/a/32226285/4313724
class NiceScale {
    private var minPoint: Double
    private var maxPoint: Double
    private var maxTicks = 10
    private(set) var tickSpacing: Double = 0
    private(set) var range: Double = 0
    private(set) var niceMin: Double = 0
    private(set) var niceMax: Double = 0
    
    init(min: Double, max: Double) {
        minPoint = min
        maxPoint = max
        calculate()
    }
    
    func setMinMaxPoints(min: Double, max: Double) {
        minPoint = min
        maxPoint = max
        calculate()
    }
    
    private func calculate() {
        range = niceNum(maxPoint - minPoint, round: false)
        tickSpacing = niceNum(range / Double((maxTicks - 1)), round: true)
        niceMin = floor(minPoint / tickSpacing) * tickSpacing
        niceMax = ceil(maxPoint / tickSpacing) * tickSpacing
    }
    
    private func niceNum(_ range: Double, round: Bool) -> Double {
        let exponent = floor(log10(range))
        let fraction = range / pow(10, exponent)
        let niceFraction: Double
        
        if round {
            if fraction <= 1.5 {
                niceFraction = 1
            } else if fraction <= 3 {
                niceFraction = 2
            } else if fraction <= 7 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
        } else {
            if fraction <= 1 {
                niceFraction = 1
            } else if fraction <= 2 {
                niceFraction = 2
            } else if fraction <= 5 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
        }
        
        return niceFraction * pow(10, exponent)
    }
}

class ScaleView : UIView {
    required init?(coder aDecoder: NSCoder) { fatalError("not supported") }
    init() {
        super.init(frame: CGRect.zero)
        isOpaque = false
    }
    
    var minValue: Double = 150.0 {
        didSet {
            update()
        }
    }
    var maxValue: Double = 500.0 {
        didSet {
            update()
        }
    }
    
    private var _isWaitingForUpdate = false
    private func update() {
        if !_isWaitingForUpdate {
            _isWaitingForUpdate = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { [weak self] in
                self?.setNeedsDisplay()
                self?._isWaitingForUpdate = false
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let area = CGRect(x: bounds.minX,
                          y: bounds.minY + 20.0,
                          width: bounds.width,
                          height: bounds.height - 40.0)
        
        UIColor.black.setStroke()
        drawLine(from: CGPoint(x: area.minX + 60.0, y: area.minY),
                 to: CGPoint(x: area.minX + 60.0, y: area.maxY),
                 width: 2)
        
        guard minValue < maxValue else { return }
        
        let niceScale = NiceScale(min: minValue, max: maxValue)
        let factor = Double(area.maxY - area.minY) / (niceScale.niceMax - niceScale.niceMin)
        drawTick(label: "\(niceScale.niceMin)", area: area, y: area.maxY)
        var index = 1
        while true {
            let value = niceScale.niceMin + niceScale.tickSpacing * Double(index)
            if value >= niceScale.niceMax {
                break
            }
            drawTick(label: "\(value)", area: area, y: area.maxY - CGFloat((value - niceScale.niceMin) * factor))
            index = index + 1
        }
        drawTick(label: "\(niceScale.niceMax)", area: area, y: area.minY)
    }
    
    private func drawTick(label: String, area: CGRect, y: CGFloat) {
        print("\(label) - \(y)")
        UIColor.gray.setStroke()
        drawLine(from: CGPoint(x: area.minX, y: y),
                 to: CGPoint(x: area.maxX, y: y),
                 width: 1)
        (label as NSString).draw(at: CGPoint(x: area.minX, y: y - UIFont.systemFontSize - 2),
                                 withAttributes: [
                                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
                                    NSAttributedStringKey.foregroundColor: UIColor.red,
                                 ])
    }

    private func drawLine(from startPoint: CGPoint, to endPoint: CGPoint, width: CGFloat) {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.close()
        path.lineWidth = width
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
        slider.maximumValue = 1000
        slider.value = Float(initialValue)
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        self.slider = slider
        
        let valueLabel = UILabel(frame: CGRect.zero)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = "\(Int(initialValue))"
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
        
        let value = floor(slider.value)
        
        valueLabel.text = "\(Int(value))"
        onValueChanged(Double(value))
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


//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension UICollectionViewCell {

    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

protocol Expandable {
    var expanded: Bool { get set }
    var overviewPercentage: CGFloat { get }
}

extension Expandable {

    var overviewPercentage: CGFloat { return 0.25 }
}

struct Item: Expandable {

    let title: String
    let texts: [String]

    var expanded: Bool
}

class MyViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let layout = CustomLayout()
    var items: [Item] = []

    init() {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {

        items = (0..<20).map {
            Item(title: "Item \($0)", texts: [], expanded: false)
        }

        collectionView?.register(CustomCell.self, forCellWithReuseIdentifier: CustomCell.reuseIdentifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCell.reuseIdentifier, for: indexPath) as! CustomCell

        let item = items[indexPath.row]
        cell.titleLabel.text = item.title
        cell.contentView.backgroundColor = UIColor.randomColor()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let item = items[indexPath.row]

        let height = CustomCell.height(for: item.title, width: collectionView.bounds.width)
        let percentage = item.expanded ? 1 : item.overviewPercentage

        return CGSize(width: collectionView.bounds.width, height: height * percentage)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        layout.selectedCellIndexPath = layout.selectedCellIndexPath == indexPath ? nil : indexPath

        UIView.animate(
            withDuration: 0.4,
            delay: 0.0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.5,
            options: UIViewAnimationOptions(),
            animations: {
                var item = self.items[indexPath.row]
                item.expanded = !item.expanded
                self.items[indexPath.row] = item

                self.collectionView?.collectionViewLayout.invalidateLayout()
                self.collectionView?.layoutIfNeeded()
        },
            completion: { _ in
        }
        )
    }
}

final class CustomCell: UICollectionViewCell {

    private static let shared = CustomCell(frame: .zero)

    static func height(for text: String, width: CGFloat) -> CGFloat {
        shared.titleLabel.text = text

        let fittingSize = CGSize(width: width, height: UILayoutFittingCompressedSize.height)
        let size = shared.containerView.systemLayoutSizeFitting(fittingSize,
                                                                withHorizontalFittingPriority: .defaultHigh,
                                                                verticalFittingPriority: .fittingSizeLevel)

        return size.height
    }

    private let containerView = UIView()
    let titleLabel = ViewFactory.label()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setUp() {

        contentView.clipsToBounds = true

        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 250)
            ])
    }

    private struct ViewFactory {

        static func label() -> UILabel {
            let label = UILabel()
            label.textAlignment = .center

            return label
        }
    }
}

extension UIColor {
    class func randomColor() -> UIColor {
        let red = CGFloat(Number.random(from: 0, to: 255)) / 255.0
        let green = CGFloat(Number.random(from: 0, to: 255)) / 255.0
        let blue = CGFloat(Number.random(from: 0, to: 255)) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

struct Number {
    static func random(from: Int, to: Int) -> Int {
        guard from < to else { fatalError("`from` MUST be less than `to`") }
        let delta = UInt32(to + 1 - from)

        return from + Int(arc4random_uniform(delta))
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

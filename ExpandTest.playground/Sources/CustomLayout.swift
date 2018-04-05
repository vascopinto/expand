import UIKit

public class CustomLayout: UICollectionViewLayout {

    private var previousAttributes: [UICollectionViewLayoutAttributes] = []
    private var currentAttributes: [UICollectionViewLayoutAttributes] = []

    private var contentSize = CGSize.zero
    public var selectedCellIndexPath: IndexPath?

    // MARK: - Preparation

    public override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        previousAttributes = currentAttributes

        contentSize = CGSize.zero
        currentAttributes = []

        let itemCount = collectionView.numberOfItems(inSection: 0)
        let width = collectionView.bounds.size.width
        var y: CGFloat = 0

        for itemIndex in 0..<itemCount {
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
            let delegateSize = delegate?.collectionView?(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
            let defaultSize = CGSize(
                    width: width,
                    height: itemIndex == selectedCellIndexPath?.item ? 300.0 : 100.0
                )

            let size = delegateSize ?? defaultSize

            let rect = CGRect(origin: CGPoint(x: 0, y: y),
                              size: size)
            attributes.frame = rect

            currentAttributes.append(attributes)

            y += size.height
        }

        contentSize = CGSize(width: width, height: y)
    }

    // MARK: - Layout Attributes

    public override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return previousAttributes[itemIndexPath.item]
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return currentAttributes[indexPath.item]
    }

    public override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return currentAttributes.filter { rect.intersects($0.frame) }
    }

    // MARK: - Invalidation

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldBounds = collectionView?.bounds, !oldBounds.size.equalTo(newBounds.size) {
            return true
        }

        return false
    }

    // MARK: - Collection View Info

    public override var collectionViewContentSize: CGSize {
        return contentSize
    }

    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {

        guard let selectedCellIndexPath = selectedCellIndexPath else { return proposedContentOffset }

        var finalContentOffset = proposedContentOffset

        if let frame = layoutAttributesForItem(at: selectedCellIndexPath)?.frame {
            let collectionViewHeight = collectionView?.bounds.size.height ?? 0

            let collectionViewTop = proposedContentOffset.y
            let collectionViewBottom = collectionViewTop + collectionViewHeight

            let cellTop = frame.origin.y
            let cellBottom = cellTop + frame.size.height

            if cellBottom > collectionViewBottom {
                finalContentOffset = CGPoint(x: 0.0, y: collectionViewTop + (cellBottom - collectionViewBottom))
            } else if cellTop < collectionViewTop {
                finalContentOffset = CGPoint(x: 0.0, y: collectionViewTop - (collectionViewTop - cellTop))
            }
        }

        return finalContentOffset
    }
}

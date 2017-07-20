//
//  GRCollectionViewLayoutManager.swift
//  GitReview
//
//  Created by Whitney Foster on 7/19/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import UIKit

@objc protocol GRCollectionViewLayoutManagerDelegate {
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
    func numberOfItems(inSection: Int) -> Int
}

class GRCollectionViewLayoutManager: UICollectionViewLayout {
    weak var delegate: GRCollectionViewLayoutManagerDelegate?
    var numberOfColumns: Int = 2
    var cellPadding: Float = 0
    private var yOffset = [CGFloat]()
    private var cache = [GRCollectionLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    lazy var contentWidth: CGFloat = {
        let insets = self.collectionView!.contentInset
        return max(UIScreen.main.bounds.width - (insets.left + insets.right), CGFloat(0))
    }()
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        self.cache.removeAll()
        self.contentHeight = 0
    }
    
    override func prepare() {
        if cache.isEmpty, let itemCount = self.delegate?.numberOfItems(inSection: 0), itemCount > 0 {
            let columnWidth = contentWidth/CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for c in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(c) * columnWidth)
            }
            
            var column = 0
            self.yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            for item in 0 ..< itemCount {
                let indexPath = IndexPath(item: item, section: 0)
                
                let width = columnWidth
                let annotationHeight = delegate?.collectionView(collectionView: collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width) ?? 0
                let height = CGFloat(cellPadding) + annotationHeight + CGFloat(cellPadding)
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: CGFloat(cellPadding), dy: CGFloat(cellPadding))
                
                let attributes = GRCollectionLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                column = column >= (numberOfColumns - 1) ? 0 : (column + 1)
            }
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.item < self.cache.count {
            return self.cache[indexPath.item]
        }
        return nil
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        let columnWidth = contentWidth/CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for c in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(c) * columnWidth)
        }
        var column = self.cache.count % 2 == 0 ? 0 : 1
        
        for i in updateItems {
            if i.indexPathBeforeUpdate == nil, let indexPath = i.indexPathAfterUpdate {
                let width = columnWidth - (CGFloat(cellPadding) * 2)
                let annotationHeight = delegate?.collectionView(collectionView: collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width) ?? 0
                let height = CGFloat(cellPadding) + annotationHeight + CGFloat(cellPadding)
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: CGFloat(cellPadding), dy: CGFloat(cellPadding))
                
                let attributes = GRCollectionLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                column = column >= (numberOfColumns - 1) ? 0 : (column + 1)
            }
        }
    }
    
    override var collectionViewContentSize: CGSize { return CGSize(width: contentWidth, height: contentHeight) }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override class var layoutAttributesClass: AnyClass { return GRCollectionLayoutAttributes.self }
}

class GRCollectionLayoutAttributes: UICollectionViewLayoutAttributes {
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! GRCollectionLayoutAttributes
        return copy
    }
}

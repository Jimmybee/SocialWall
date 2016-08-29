//
//  File.swift
//  SocialWall
//
//  Created by James Birtwell on 18/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit


class MosiacCollectionViewLayout: UICollectionViewLayout {
    
    var itemHeight = 0.0 as CGFloat
    var _layoutAttributes = Dictionary<String, UICollectionViewLayoutAttributes>()
    var gridSize:CGFloat = 0
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    var aspectRatio:CGFloat = 0
    var noOfSquares = CGFloat(8)
    var gridUsed = [gridSpaceUsed]()
    
    var cellAttributes = [NSIndexPath : UICollectionViewLayoutAttributes]()
    
    func addGridSpace(row: Int, toRow: Int, col: Int, toCol: Int) {
        for addRow in row...toRow {
            for addCol in col...toCol{
                let gridSpace = gridSpaceUsed(row: addRow, col: addCol)
                gridUsed.append(gridSpace)
            }
        }
 
    }
    
    func checkGridUsed(row: Int, toRow: Int, col: Int, toCol: Int) -> Bool {
        var gridUsed = false
        for checkRow in  row...toRow {
            for checkCol in col...toCol {
                if !isGridFree(checkRow, col: checkCol) {
                    gridUsed = true
                }
            }
        }
        return !gridUsed
    }
    
    func checkAnyGridFree(row: Int, toRow: Int, col: Int, toCol: Int) -> Bool {
        var gridFree = false
        for checkRow in  row...toRow {
            for checkCol in col...toCol {
                if isGridFree(checkRow, col: checkCol) {
                    gridFree = true
                }
            }
        }
        return gridFree
    }
        
    func isGridFree(row: Int, col: Int) -> Bool {
        var gridFound = true
        if let index = gridUsed.indexOf({ (grid) -> Bool in
          grid.gridRow == row && grid.gridCol == col
        
        }) {
            gridFound = false
        }
        
        return gridFound
    }
    
    
    override func prepareLayout() {
        super.prepareLayout()
        
        createGrid()
        

        var yOffset = CGFloat(0)
        var xOffset = CGFloat(0)
        var attributeFrame = CGRect()
        
        let section = self.collectionView!.numberOfSections() - 1
        var numberOfItems = 0
        
        numberOfItems = self.collectionView!.numberOfItemsInSection(section)
        if numberOfItems == 0 {return}
        
        let maxRow = Int(screenHeight / gridSize)
        let maxCol = Int(screenWidth / gridSize)
        
        gridUsed.removeAll()
        addGridSpace(maxRow, toRow: maxRow, col: 0, toCol: maxCol)
        addGridSpace(0, toRow: maxRow, col: maxCol, toCol: maxCol)
        
        let totalGridSquares = maxCol * maxRow
//        if totalGridSquares == 0 {return}
        
        let iterations = numberOfItems

        
        for item in 0...iterations - 1  {
            var itemSize = CGSizeZero
            

            var randomChoice = Int(arc4random_uniform(UInt32(1)))
            
            while itemSize == CGSizeZero {
                let colNum = Int(xOffset / gridSize)
                let rowNum = Int(yOffset / gridSize)
                
                if checkGridUsed(rowNum, toRow: rowNum+2, col: colNum, toCol: colNum+2) {
                    randomChoice = Int(arc4random_uniform(UInt32(3)))
                } else if checkGridUsed(rowNum, toRow: rowNum+1, col: colNum, toCol: colNum+1) {
                    randomChoice = Int(arc4random_uniform(UInt32(2)))
                }
                
                    switch randomChoice {
                    case 2:
                        addGridSpace(rowNum, toRow: rowNum+2, col: colNum, toCol: colNum+2)
                        itemSize = CGSizeMake(gridSize*3, gridSize*3)
                    case 1:
                        addGridSpace(rowNum, toRow: rowNum+1, col: colNum, toCol: colNum+1)
                        itemSize = CGSizeMake(gridSize*2, gridSize*2)
                    default:
                        if checkGridUsed(rowNum, toRow: rowNum, col: colNum, toCol: colNum) {
                            addGridSpace(rowNum, toRow: rowNum, col: colNum, toCol: colNum)
                            itemSize = CGSizeMake(gridSize, gridSize)
                        }
                    }
                
                 attributeFrame = CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height)
                
                xOffset += gridSize
                if xOffset >= screenWidth {
                    xOffset = 0
                    yOffset += gridSize
                }
            
            }
            
            let indexPath = NSIndexPath(forItem: item, inSection: section)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            cellAttributes[indexPath] = attributes
            attributes.frame = attributeFrame
           
        }
    }
    
    
    
    
    func layoutKeyForIndexPath(indexPath : NSIndexPath) -> String {
        return "\(indexPath.section)_\(indexPath.row)"
    }
    
    //MARK: Override Methods in subclasses
    
    func createGrid() {

    }
    
    
    override func collectionViewContentSize() -> CGSize {
        
        return UIScreen.screens().last!.bounds.size
    }
    
    
    // MARK: Required methods
    
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return !CGSizeEqualToSize(newBounds.size, self.collectionView!.frame.size)
    }
    
    
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        
        let key = layoutKeyForIndexPath(indexPath)
        return _layoutAttributes[key]
    }
    
    struct gridSpaceUsed {
        let gridString: String
        let gridRow: Int
        let gridCol: Int
        
        init(row: Int, col: Int) {
            gridString = String(row) + ":" + String(col)
            self.gridCol = col
            self.gridRow = row
        }
        
    }
    

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = [UICollectionViewLayoutAttributes](cellAttributes.values)
        return attributes
        
        
        if _layoutAttributes.count == 1{
            print(_layoutAttributes.count )
            return nil
        }
        
        let predicate = NSPredicate {  [unowned self] (evaluatedObject, bindings) -> Bool in
            let layoutAttribute = self._layoutAttributes[evaluatedObject as! String]
            return CGRectIntersectsRect(rect, layoutAttribute!.frame)
        }
        
        let dict = _layoutAttributes as NSDictionary
        let keys = dict.allKeys as NSArray
        let matchingKeys = keys.filteredArrayUsingPredicate(predicate)
        
        
        return dict.objectsForKeys(matchingKeys, notFoundMarker: NSNull()) as? [UICollectionViewLayoutAttributes]
    }
    
    
}
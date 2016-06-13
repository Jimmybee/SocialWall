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
    
    func addGridSpace(row: Int, col: Int) {
        let gridSpace = gridSpaceUsed(row: row, col: col)
        gridUsed.append(gridSpace)
    }
    
    func addLargeGridSpace(row: Int, col: Int) {
        addGridSpace(row, col: col)
        addGridSpace(row+1, col: col)
        addGridSpace(row, col: col+1)
        addGridSpace(row+1, col: col+1)
    }
    
    func checkLargeGridFree(row: Int, col: Int) -> Bool {
        if !checkSmallGridFree(row, col: col) {
            return false
        }
        if !checkSmallGridFree(row, col: col+1) {
            return false
        }
        if !checkSmallGridFree(row+1, col: col) {
            return false
        }
        if !checkSmallGridFree(row+1, col: col+1) {
            return false
        }
        return true
    }
    
    func checkSmallGridFree(row: Int, col: Int) -> Bool {
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
        
        let path = NSIndexPath(forItem: 0, inSection: 0)
        
        let section = self.collectionView!.numberOfSections() - 1
        var numberOfItems = 0
        
        numberOfItems = self.collectionView!.numberOfItemsInSection(section)
        if numberOfItems == 0 {return}
        
        let maxRow = Int(screenHeight / gridSize)
        let maxCol = Int(screenWidth / gridSize)

        for col in 0...maxCol {
            addGridSpace(maxRow, col: col)
        }
        
        for row in 0...maxRow {
            addGridSpace(row, col: maxCol)
        }
        
        let totalGridSquares = maxCol * maxRow
        var item = 0
        
        let iterations = min(totalGridSquares, numberOfItems)
        
        for _ in 0...iterations {
            
            let indexPath = NSIndexPath(forItem: item, inSection: section)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath) // 4
            
            var itemSize = CGSizeZero
            
            
            let colNum = Int(xOffset / gridSize)
            let rowNum = Int(yOffset / gridSize)
            
            if checkLargeGridFree(rowNum, col: colNum) {
                
                let randomChoice = Int(arc4random_uniform(UInt32(2)))
                
                if randomChoice == 1 {
                    itemSize.width = gridSize * 2
                    itemSize.height = gridSize * 2
                    addLargeGridSpace(rowNum, col: colNum)
                    item += 1
                    
                    
                    // 4.4.3: Generate and store layout attributes for the cell
                    let cellIndexPath = NSIndexPath(forItem: item, inSection: section)
                    let sigleCellAttributes =
                        UICollectionViewLayoutAttributes(forCellWithIndexPath: cellIndexPath)
                    
                    cellAttributes[cellIndexPath] = sigleCellAttributes
                    sigleCellAttributes.frame = CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height)
                    
                    

                
                } else {
                    itemSize.width = gridSize
                    itemSize.height = gridSize
                    addGridSpace(rowNum, col: colNum)
                    item += 1
                    
                    
                    // 4.4.3: Generate and store layout attributes for the cell
                    let cellIndexPath = NSIndexPath(forItem: item, inSection: section)
                    let sigleCellAttributes =
                        UICollectionViewLayoutAttributes(forCellWithIndexPath: cellIndexPath)
                    
                    cellAttributes[cellIndexPath] = sigleCellAttributes
                    sigleCellAttributes.frame = CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height)
                    
                    


                }
            } else if checkSmallGridFree(rowNum, col: colNum) {
                itemSize.width = gridSize
                itemSize.height = gridSize
                addGridSpace(rowNum, col: colNum)

                item += 1
                
                
                // 4.4.3: Generate and store layout attributes for the cell
                let cellIndexPath = NSIndexPath(forItem: item, inSection: section)
                let sigleCellAttributes =
                    UICollectionViewLayoutAttributes(forCellWithIndexPath: cellIndexPath)
                
                cellAttributes[cellIndexPath] = sigleCellAttributes
                sigleCellAttributes.frame = CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height)
                
                

            }
   
            xOffset += gridSize
            if xOffset >= screenWidth {
                xOffset = 0
                yOffset += gridSize
            }
            
  
            
            
            //            attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height))
            //            let key = layoutKeyForIndexPath(indexPath)
            //            _layoutAttributes[key] = attributes
            //            print(key)
            //            print(_layoutAttributes[key])
            
         
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
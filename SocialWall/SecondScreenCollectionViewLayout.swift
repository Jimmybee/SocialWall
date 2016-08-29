//
//  SecondScreenCollectionViewLayout.swift
//  SocialWall
//
//  Created by James Birtwell on 15/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit

class SecondScreenCollectionViewLayout : MosiacCollectionViewLayout {
    
    override func createGrid() {
        screenHeight = UIScreen.screens().last!.bounds.size.height
        screenWidth = UIScreen.screens().last!.bounds.size.width
        
        if screenWidth != 0 {
            gridSize = HelperFunctions.gcd(screenHeight, screenWidth)
        }
        noOfSquares = screenWidth/gridSize

        if noOfSquares < 7 {
            gridSize = gridSize / 2
        }
        
        aspectRatio = screenWidth/screenHeight
    
    }

    override func collectionViewContentSize() -> CGSize {
        
        return UIScreen.screens().last!.bounds.size
    }
    
}

class PresenterScreenCollectionViewLayout : MosiacCollectionViewLayout {
    
    
    override func createGrid() {

        screenHeight = UIScreen.screens().first!.bounds.size.height
        screenWidth = UIScreen.screens().first!.bounds.size.width
        
//        screenHeight =  self.collectionView!.bounds.height
//        screenWidth = self.collectionView!.bounds.width
        
        gridSize = HelperFunctions.gcd(screenHeight, screenWidth)
        noOfSquares = screenWidth/gridSize
        aspectRatio = screenWidth/screenHeight
        
    }
    
    override func collectionViewContentSize() -> CGSize {
        
        return UIScreen.screens().first!.bounds.size
//        return self.collectionView!.bounds.size
    }
    
}

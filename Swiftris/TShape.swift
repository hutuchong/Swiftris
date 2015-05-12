//
//  TShape.swift
//  Swiftris
//
//  Created by Mike Dobrowolski on 5/11/15.
//  Copyright (c) 2015 Mike Dobrowolski. All rights reserved.
//

class TShape:Shape {
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff:Int, rowDiff:Int)>] {
        return [
            Orientation.Zero: [(0,1),(1,1),(2,1),(1,0)],
            Orientation.Ninety: [(1,0),(1,1),(1,2),(2,1)],
            Orientation.OneEighty: [(0,1),(1,1),(2,1),(1,2)],
            Orientation.TwoSeventy: [(1,0),(1,1),(1,2),(0,1)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[ThirdBlockIdx]],
            Orientation.Ninety:     [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[FourthBlockIdx], blocks[FirstBlockIdx], blocks[ThirdBlockIdx]],
            Orientation.TwoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}

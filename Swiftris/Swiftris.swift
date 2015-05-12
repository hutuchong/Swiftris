//
//  Swiftris.swift
//  Swiftris
//
//  Created by Mike Dobrowolski on 5/11/15.
//  Copyright (c) 2015 Mike Dobrowolski. All rights reserved.
//

let NumColumns = 10
let NumRows = 20

let StartingCol = 4
let StartingRow = 0

let PreviewCol = 12
let PreviewRow = 1

let PointsPerLine = 10
let LevelThreshold = 1000

protocol SwiftrisDelegate {
    //when current round ends
    func gameDidEnd(swiftris: Swiftris)
    
    //when new game begins
    func gameDidBegin(swiftris:Swiftris)
    
    //when falling shape hits gameboard
    func gameShapeDidLand(swiftris:Swiftris)
    
    //when falling shape changes location
    func gameShapeDidMove(swiftris:Swiftris)
    
    //when falling shape has changed it location after being dropped
    func gameShapeDidDrop(swiftris:Swiftris)
    
    //level up
    func gameDidLevelUp(swiftris:Swiftris)
}

class Swiftris {
    var blockArray: Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:SwiftrisDelegate?
    var score:Int
    var level:Int
    
    init() {
        score = 0
        level = 1
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil){
            nextShape = Shape.random(PreviewCol, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(self)
    }
    
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(PreviewCol, startingRow: PreviewRow)
        fallingShape?.moveTo(StartingCol, row: StartingRow)
        
        if detectIllegalPlacement() {
            nextShape = fallingShape
            nextShape!.moveTo(PreviewCol, row: PreviewRow)
            endGame()
            return (nil,nil)
        }
        return (fallingShape, nextShape)
    }
    
    func detectIllegalPlacement() -> Bool {
        if let shape = fallingShape {
            for block in shape.blocks {
                if block.column < 0 || block.column >= NumColumns || block.row < 0 || block.row >= NumRows {
                    return true
                }
                else if blockArray[block.column, block.row] != nil {
                    return true
                }
            }
        }
        return false
    }
    
    func settleShape() {
        if let shape = fallingShape {
            for block in shape.blocks {
                blockArray[block.column, block.row] = block
            }
            fallingShape = nil
            delegate?.gameShapeDidLand(self)
        }
    }
    
    func detectTouch() -> Bool {
        if let shape = fallingShape {
            for bottomBlock in shape.bottomBlocks {
                if bottomBlock.row == NumRows - 1 || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                    return true
                }
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(self)
    }
    
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        for var row = NumRows - 1; row > 0; row-- {
            var rowOfBlocks = Array<Block>()
            
            for column in 0..<NumColumns {
                if let block = blockArray[column,row] {
                    rowOfBlocks.append(block)
                }
            }
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        if removedLines.count == 0 {
            return ([], [])
        }
        
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        
        for column in 0..<NumColumns {
            var fallenBlocksArray = Array<Block>()
            
            for var row = removedLines[0][0].row - 1; row > 0; row-- {
                if let block = blockArray[column, row] {
                    var newRow = row
                    while newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil {
                        newRow++
                    }
                    block.row = newRow
                    blockArray[column,row] = nil
                    blockArray[column, newRow] = block
                    fallenBlocksArray.append(block)
                }
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            for col in 0..<NumColumns {
                if let block = blockArray[col, row] {
                    rowOfBlocks.append(block)
                    blockArray[col, row] = nil
                }
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
    
    func dropShape() {
        if let shape = fallingShape {
            while detectIllegalPlacement() == false {
                shape.lowerShapeByOneRow()
            }
            shape.raiseShapeByOneRow()
            delegate?.gameShapeDidDrop(self)
        }
    }
    
    func letShapeFall() {
        if let shape = fallingShape {
            shape.lowerShapeByOneRow()
            if detectIllegalPlacement() {
                shape.raiseShapeByOneRow()
                if detectIllegalPlacement() {
                    endGame()
                }
                else {
                    settleShape()
                }
            }
            else {
                delegate?.gameShapeDidMove(self)
                if detectTouch() {
                    settleShape()
                }
            }
        }
    }
    
    func rotateShape() {
        if let shape = fallingShape {
            shape.rotateClockwise()
            if detectIllegalPlacement() {
                shape.rotateCounterClockwise()
            }
            else {
                delegate?.gameShapeDidMove(self)
            }
        }
    }
    
    func moveShapeLeft() {
        if let shape = fallingShape {
            shape.shiftLeftByOneCol()
            if detectIllegalPlacement() {
                shape.shiftRightByOneCol()
                return
            }
            delegate?.gameShapeDidMove(self)
        }
    }
    
    func moveShapeRight() {
        if let shape = fallingShape {
            shape.shiftRightByOneCol()
            if detectIllegalPlacement() {
                shape.shiftLeftByOneCol()
                return
            }
            delegate?.gameShapeDidMove(self)
        }
    }
    
}
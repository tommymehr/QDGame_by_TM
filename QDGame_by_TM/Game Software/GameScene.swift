//
//  GameScene.swift
//  QDGame_by_TM
//
//  Created by Tommy on 04.07.18.
//  Copyright © 2018 Tommy. All rights reserved.
//


import SpriteKit



class GameScene: SKScene {
    
    //-----------------------------------------------------------------------------------------------------
    //-- floor is a array of sprites. Those nodes are the floor-tiles of the world
    //-- stickBoy is the sprite of the avatar
    //-- score is a simple lable
    //-----------------------------------------------------------------------------------------------------
    var floor: Array <SKSpriteNode> = Array()
    var stickBoy: SKSpriteNode!
    let score = SKLabelNode(fontNamed: "Helvetica")
    
    //-----------------------------------------------------------------------------------------------------
    //-- floorHeight describes the height of the new spawning tiles
    //-- positionCount always adresses the tile, witch is going out of frame
    //-- touchEvent is a trigger to limit the number of 'Air-Jumps'
    //-- scoreCount is the score ;-)
    //-- healthCount ...
    //-----------------------------------------------------------------------------------------------------
    var floorHeight: CGFloat!
    var positionCount = 0
    var touchEvent = true
    var scoreCount = 0.0
    var healthCount: CGFloat = 1.0
    var startPosition: CGFloat!
    
    
   
    override func didMove(to view: SKView) {
        worldSetup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        jumpMan()
    }
    
    override func update(_ currentTime: TimeInterval) {
        tileLoop()
        jumpPermission()
        gameOver()
        updateHealth()
    }

    func worldSetup () {
        
        backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        
        startPosition = (9*frame.size.width/10)
        
        player()
        initFloorAr()
        
    }
    
    //-----------------------------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------------
    //-------------------------------- CODE FOR THE WORLD GENERATION --------------------------------------
    //-----------------------------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------------------------
    //-- Initialising the floor array with tiles.
    //-----------------------------------------------------------------------------------------------------
    func initFloorAr () {
        var i: CGFloat = 0.0
        var j = 0
        //setting the initial floor height
        floorHeight = frame.midY-(stickBoy.size.height/2)
        
        //exit condition is achived when the frame is length wie full
        while i < frame.maxX {
            //Setting the image
            let floorTile = SKSpriteNode(imageNamed: "floorBar")
            //Size is dependent on the Avatar Size
            floorTile.size = CGSize(width: stickBoy.size.width, height: stickBoy.size.height/8)
            //initializing floor height and setting each tile behind another
            floorTile.position = CGPoint(x: i, y: floorHeight)
            //setting the physics of each tile
            floorTile.physicsBody = SKPhysicsBody(rectangleOf: floorTile.size)
            floorTile.physicsBody?.affectedByGravity = false
            floorTile.physicsBody?.isDynamic = false
            //movment is done by an action instead of physics, due to glitches
            floorTile.run(SKAction.repeatForever(SKAction.moveBy(x: -80, y: 0, duration: 0.2)))
            
            floor.append(floorTile)
            
            i += floorTile.size.width
            j += 1
        }
        
        //adding each tile to the scene
        for tile in floor {
            addChild(tile)
        }
    }
  
    //-----------------------------------------------------------------------------------------------------
    //-- Procedual Map Generation
    //-----------------------------------------------------------------------------------------------------
    func worldLayout () {
        
        var rNum = CGFloat(arc4random_uniform(100))
        rNum = rNum/100
        
        //20% chance of hight change
        if rNum < 0.2 {
            rNum = CGFloat(arc4random_uniform(100))
            rNum = rNum/100
            
            //50% chance of getting higher
            if (rNum < 0.5 && floorHeight < frame.height-stickBoy.size.height-40){
                
                //heigth change is between 10 and 40 units
                rNum = CGFloat(arc4random_uniform(30))
                rNum = rNum+10
                floorHeight = floorHeight + rNum
                
            } else if (floorHeight > 40) {
                
                //same like above, just getting lower
                rNum = CGFloat(arc4random_uniform(30))
                rNum = rNum+10
                floorHeight = floorHeight - rNum
            }
        }
    }
    
    //-----------------------------------------------------------------------------------------------------
    //-- Looping the tiles
    //-----------------------------------------------------------------------------------------------------
    func tileLoop () {
        //getting the right edge position of the left tile
        let position = floor[positionCount].position.x+floor[positionCount].size.width/2
        //if the left tile is ot of the frame
        if (position<=0){
            //getting the right edge of the righter most tile, plus half a tile distanze
            let xPosition = floor[(positionCount+floor.count-1)%floor.count].position.x + floor[(positionCount+floor.count-1)%floor.count].size.width
            //moving the left tile to the right end
            floor[positionCount].position = CGPoint(x: xPosition, y: floorHeight)
            
            positionCount += 1
            positionCount = positionCount%floor.count
            
            //updating the to the next floorHeight
            worldLayout()
            
            //--------------------------
            //--- Score calculation ----
            scoreCount += 3
            score.removeFromParent()
            updateScore()
            //--------------------------
        }
    }
    
    //-----------------------------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------------
    //-------------------------------------- CODE FOR THE PLAYER ------------------------------------------
    //-----------------------------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------------------------
    //-- Constructing the player model
    //-----------------------------------------------------------------------------------------------------
    func player () {
        //Assining PNG graphics to the basic SpriteNode
        stickBoy = SKSpriteNode(imageNamed: "stickMan")
        //--------------------------------------------------------------------------------------
        
        //Setting the global size of the _stickBoy_
        //every other scale is in dependence of the _stickBoy_
        stickBoy.size = CGSize(width: frame.size.width/10, height: frame.size.width/10)
        stickBoy.position = CGPoint(x: startPosition, y: frame.maxY)
        //--------------------------------------------------------------------------------------
        
        //Setting the physicsmodel of the player
        stickBoy.physicsBody = SKPhysicsBody(rectangleOf: stickBoy.size)
        stickBoy.physicsBody?.affectedByGravity = true
        stickBoy.physicsBody?.allowsRotation = false
        stickBoy.physicsBody?.friction = 0.0
        stickBoy.physicsBody?.restitution = 0
        //--------------------------------------------------------------------------------------
        
        addChild(stickBoy)
        
    }
    
    //-----------------------------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------------
    //--------------------------------- CODE FOR THE GAME MECHANICS ---------------------------------------
    //-----------------------------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------------
    
    
    //-----------------------------------------------------------------------------------------------------
    //-- Score update
    //-----------------------------------------------------------------------------------------------------
    func updateScore () {
        
        
        score.fontSize = 23
        score.position = CGPoint(x: frame.midX, y: frame.maxY-40)
        score.text = "--- SCORE: \(scoreCount/10) ---"
        
        addChild(score)
        
    }
    
    //-----------------------------------------------------------------------------------------------------
    //-- Health update
    //-----------------------------------------------------------------------------------------------------
    func updateHealth () {
        
        healthCount = stickBoy.position.x/startPosition
        backgroundColor = UIColor(red: (1-healthCount)*200/255, green: healthCount*200/255, blue: healthCount*200/255, alpha: 1.0)
        
    }
    
    
    //-----------------------------------------------------------------------------------------------------
    //-- Jump system
    //-----------------------------------------------------------------------------------------------------
    func jumpMan () {
        if touchEvent {
            stickBoy.physicsBody?.velocity.dy = 400
            touchEvent = false
        }
    }
    
    
    //-----------------------------------------------------------------------------------------------------
    //-- Permission to Jump
    //-----------------------------------------------------------------------------------------------------
    func jumpPermission () {
        //Saving the tile size in a lokal konstant
        let tileHalfSize = floor[0].size.width
        //going through every tile in the floor
        for tile in floor {
            //is true when tile is right underneath the avatar
            if (tile.position.x - tileHalfSize < stickBoy.position.x && tile.position.x + tileHalfSize > stickBoy.position.x ){
                //saving the tile hight, plus half tile thinkness, plus half of character hight
                // in a lokal konstant
                let floorH = tile.position.y + tile.size.height/2 + stickBoy.size.height/2
                // if the the charakter is on a tile, it can jump again.
                if (floorH>stickBoy.position.y){
                    touchEvent=true
                }
                //print("PosY \(stickBoy.position.y) floorH \(floorH) \n")
            }
        }
    }
    
    
    //-----------------------------------------------------------------------------------------------------
    //-- GameOver stratigie
    //-----------------------------------------------------------------------------------------------------
    func gameOver () {
        //Saving the right end of the bounderyBox in da constant
        let stickBoyRightBorder = stickBoy.position.x + stickBoy.size.width/2
        //Saving the upper end of the bounderyBox in da constant
        let stickBoyUpperBorder = stickBoy.position.y + stickBoy.size.height/2
        //when the upper or right end of the box left the frame
        if (stickBoyRightBorder < 0 || stickBoyUpperBorder < 0) {
            //removing of the Player node
            stickBoy.removeFromParent()
            //resetting the score
            scoreCount = 0.0
            //creat a new player
            player()
        }
    }
}

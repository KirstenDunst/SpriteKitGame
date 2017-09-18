//
//  AirplaneGame.m
//  SpriteKitGame
//
//  Created by CSX on 2017/9/15.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "AirplaneGame.h"

@interface AirplaneGame ()<SKPhysicsContactDelegate>

@end

@implementation AirplaneGame
-(instancetype)initWithSize:(CGSize)size{
    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor whiteColor];
        
        //设置重力加速度
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        self.physicsWorld.contactDelegate = self;
        
    }
    
    return self;
    
}

-(void)didMoveToView:(SKView *)view{
    
    [super didMoveToView:view];
    
    [self backgroundNode];
    
    [self planeNode];
    
    
}

#pragma mark ----创建背景----

-(void)backgroundNode{
    
    SKSpriteNode *backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"bg_02.jpg"];
    
    backgroundNode.position = CGPointZero;
    
    backgroundNode.zPosition = 0;
    
    backgroundNode.anchorPoint = CGPointZero;
    
    backgroundNode.size = self.size;
    
    [self addChild:backgroundNode];
    
}

#pragma mark ---- 创建静止 ----

-(void)planeNode{
    
    SKSpriteNode *planeNode = [SKSpriteNode spriteNodeWithImageNamed:@"airplne.png"];
//    坐标是从左下角开始的
    planeNode.position = CGPointMake(self.size.width/2, self.size.height*1/5);
    
    planeNode.anchorPoint = CGPointMake(0.5, 0.5);
    
    planeNode.zPosition = 1;
    
    planeNode.name = @"plane";
    
    [self addChild:planeNode];
    
    planeNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:planeNode.size];
    
    //物理体是否受力
    planeNode.physicsBody.dynamic = YES;
    
    //设置物理体的标识符
    planeNode.physicsBody.categoryBitMask = 1;
    
    //设置可与哪一类的物理体发生碰撞
    planeNode.physicsBody.contactTestBitMask = 2;
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    SKSpriteNode *enemyNode = [SKSpriteNode spriteNodeWithImageNamed:@"enemy.png"];
    
    enemyNode.position = CGPointMake(self.size.width/2, self.size.height);
    
    enemyNode.anchorPoint = CGPointMake(0.5, 1);
    
    enemyNode.zPosition = 1;
    
    enemyNode.name = @"enemy";
    
    [self addChild:enemyNode];
    
    //添加动作
    [enemyNode runAction:[SKAction moveToY:0 duration:2]];
    
    enemyNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemyNode.size];
    
    //物理体是否受力
    enemyNode.physicsBody.dynamic = YES;
    
    //设置物理体的标识符
    enemyNode.physicsBody.categoryBitMask = 2;
    
    //设置可与哪一类的物理体发生碰撞
    enemyNode.physicsBody.contactTestBitMask = 1;

}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    SKSpriteNode *planeNode;
    SKSpriteNode *enemyNode;
//     判断碰撞的两个是  飞机和敌机。
    if (contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2) {
//        飞机的节点
        planeNode = (SKSpriteNode *)[contact.bodyA node];
//        敌机的节点
        enemyNode = (SKSpriteNode *)[contact.bodyB node];
        
        //去除敌机
        [enemyNode removeAllActions];
        [enemyNode removeFromParent];
        
    }else{
//        飞机的节点
        planeNode = (SKSpriteNode *)[contact.bodyB node];
//        敌机的节点
        enemyNode = (SKSpriteNode *)[contact.bodyA node];
        
        //去除敌机
        [enemyNode removeAllActions];
        [enemyNode removeFromParent];
        
    }
    
}

@end

//
//  StampBlackBlockScene.m
//  SpriteKitGame
//
//  Created by CSX on 2017/9/19.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "StampBlackBlockScene.h"
#import "GameOverScene.h"

#define MAXNumber 30

@interface StampBlackBlockScene ()
{
//    产生白块的速度
    int speed;
}
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end

@implementation StampBlackBlockScene

- (instancetype)initWithSize:(CGSize)size{
    self = [super initWithSize:size];
    if (self) {
//        默认是一秒产生一块白块
        speed = 1;
        self.backgroundColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
//        [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(getFrameCreate) userInfo:nil repeats:YES];
    }
    return self;
}
//创建基本框架模型
- (void)getFrameCreate{
    static int index = 0;
    index++;
    if (index > MAXNumber) {
        return;
    }
    int a = arc4random()%4;
    SKSpriteNode*whiteNode = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(self.view.frame.size.width/4, self.frame.size.height/5)];
    whiteNode.position = CGPointMake(self.view.frame.size.width/8+(self.view.frame.size.width/4)*a, self.frame.size.height+self.frame.size.height/10);
    whiteNode.name = [NSString stringWithFormat:@"heroNode%d",index];
    [self addChild:whiteNode];
//    时间限制保证下落的速度能够和白块之间连接起来
    SKAction *actionMove = [SKAction moveTo:CGPointMake(self.view.frame.size.width/8+(self.view.frame.size.width/4)*a, -self.frame.size.height/10) duration:6*speed];
    SKAction *actionDone = [SKAction removeFromParent];
    
    [whiteNode runAction:[SKAction sequence:@[actionMove,actionDone]]];
}

//时间更新，一微秒调一次
- (void)update:(NSTimeInterval)currentTime{
    NSLog(@">>>>>>>>>>>>>%f",currentTime);
//    距离上次的时间间隔
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast >= speed) {
//        一微妙
        timeSinceLast = 1.0/60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    //保证调用一次这个方法传进去的参数小于等于1.0/60.0；
    [self updateWithSinceLastUpdate:timeSinceLast];
}

- (void)updateWithSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval >= speed) {
        self.lastSpawnTimeInterval = 0;
        [self getFrameCreate];
    }
}

- (void)remove:(SKSpriteNode *)node{
    [node removeFromParent];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    static int index = 0;
    index++;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    if (YES) NSLog(@"Node name where touch began: %@  index=%d", node.name,index);
    
    //if hero touched set BOOL
    if ([node.name isEqualToString:[NSString stringWithFormat:@"heroNode%d",index]]) {
        [node removeFromParent];
        if (index == MAXNumber) {
            //        反转动画效果时间设置
            SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
            SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
            [self.view presentScene:gameOverScene transition:reveal];
        }
    }else{
        //        反转动画效果时间设置
        SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
        SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition:reveal];
    }
}


@end


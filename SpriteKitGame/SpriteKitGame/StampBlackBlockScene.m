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
@property (nonatomic, strong)NSMutableArray *dataArr;

@property (nonatomic, strong)NSMutableArray *actionArr;

@end

@implementation StampBlackBlockScene

- (NSMutableArray *)actionArr{
    if (!_actionArr) {
        _actionArr = [NSMutableArray array];
    }
    return _actionArr;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
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
    
    SKSpriteNode *whiteNode;
    if (self.dataArr.count>0) {
        whiteNode = self.dataArr[0];
        [self.dataArr removeObjectAtIndex:0];
    }else{
        whiteNode = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(self.view.frame.size.width/4, self.frame.size.height/5)];
        [self addChild:whiteNode];
    }
    whiteNode.position = CGPointMake(self.view.frame.size.width/8+(self.view.frame.size.width/4)*a, self.frame.size.height+self.frame.size.height/10);
    whiteNode.name = [NSString stringWithFormat:@"heroNode%d",index];
   
//    时间限制保证下落的速度能够和白块之间连接起来
    SKAction *actionMove = [SKAction moveTo:CGPointMake(whiteNode.position.x, -self.frame.size.height/10) duration:6*speed];
    SKAction *loseAction = [SKAction runBlock:^{
    //        反转动画效果时间设置
        SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
        SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition:reveal];
    }];
    SKAction *actionDone = [SKAction runBlock:^{
        [self.dataArr addObject:whiteNode];
    }];
    
    [whiteNode runAction:[SKAction sequence:@[actionMove,loseAction,actionDone]]];
}

// 获取时间增量
//姐，你家里面的地址给我发一个吧，我想给你和俺大姨带点这边的特产邮回去。主要是这次要先到可可家里一趟，我带这些不方便，要不是我都自己带回去了。
// 如果我们运行的每秒帧数低于60，我们依然希望一切和每秒60帧移动的位移相同
- (void)update:(NSTimeInterval)currentTime{
    NSLog(@">>>>>>>>>>>>>%f",currentTime);
//    距离上次的时间间隔
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
//    原来。timeSinceLast >1       // 如果上次更新后得时间增量大于1秒
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


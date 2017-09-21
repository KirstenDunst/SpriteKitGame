//
//  KillMonster.m
//  SpriteKitGame
//
//  Created by CSX on 2017/9/18.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "KillMonster.h"
#import "GameOverScene.h"

//0x是十六进制的前缀   <<移位标志符。       16进制的1（0001）左移0位或1位
static const uint32_t projectileCategory = 0x1 << 0;  //(0001)。即1；
static const uint32_t monsterCategory = 0x1 << 1;   //(0010).即2；

@interface KillMonster ()<SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int monstersDestroyed;
@end

//规划位置相加
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

//计算相关的位移向量
static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

//放大距离的方位
static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

//计算距离的长度
static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}


@implementation KillMonster

- (instancetype)initWithSize:(CGSize)size{
    self = [super initWithSize:size];
    if (self) {
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // 3
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 4
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        [self addChild:self.player];
        //        设置物理重力感应
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

//自动获取时间参数，这里设置每秒触发创建一个monster
- (void)update:(NSTimeInterval)currentTime{
    static int i = 0;
    i++;
    NSLog(@">>>>>>>>>>>%d",i);
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0/60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithSinceLastUpdate:timeSinceLast];
}
- (void)updateWithSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}
//创建monster
- (void)addMonster{
    NSLog(@"发送了monster");
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
//    设置monster的物理受理范围
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
//    打开受力开关
    monster.physicsBody.dynamic = YES;
//    设置物理标记特征
    monster.physicsBody.categoryBitMask = monsterCategory;
//    设置可以碰撞的身份标记
    monster.physicsBody.contactTestBitMask = projectileCategory;
//    定义这个身体对与之碰撞的物体的逻辑“类别”。所有位集的默认值(所有类别)。
    monster.physicsBody.collisionBitMask = 0;
    
//    计算monster可以出现的位置y轴方向的位置
    int minY = monster.size.height/2;
    int maxY = self.frame.size.height - monster.size.height/2;
    int rangeY = maxY-minY;
    int actualY = (arc4random()%rangeY) + minY;
    
//    添加节点并添加到当前界面上面
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    [self addChild:monster];
    
//    给定一个一定范围内的随机移动速度
    int minDuction = 2.0;
    int maxDuction = 4.0;
    int rangeDuraction = maxDuction-minDuction;
    int actualDuction = (arc4random()%rangeDuraction) + minDuction;
    
//    创建动画效果，移动monster实现
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuction];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    SKAction *loseAction = [SKAction runBlock:^{
//        反转动画效果时间设置
        SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
        SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition:reveal];
    }];
//    执行一连串的动作效果
    [monster runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    
//    获取到当前的点击位置
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
//    创建飞镖的节点
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = self.player.position;
//    设置物理身躯为旋转的body
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
//    设置添加动力
    projectile.physicsBody.dynamic = YES;
//    设置物理标记符
    projectile.physicsBody.categoryBitMask = projectileCategory;
//    设置撞击产生效果的标记符
    projectile.physicsBody.contactTestBitMask = monsterCategory;
//    碰撞位元遮罩
    projectile.physicsBody.collisionBitMask = 0;
//    使用精确的碰撞检测
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
//    确定射弹位置的偏移位置
    CGPoint offset = rwSub(location, projectile.position);
    
    if (offset.x <= 0) {
//        当你向下或向后射击时，将其保释出来
        return;
    }
    [self addChild:projectile];
    
//    获取射击的方向
    CGPoint direction = rwNormalize(offset);
//    确保设计的目的地超出屏幕显示的范围。
    CGPoint shootAmount = rwMult(direction, 1000);
//    给当前的量添加上射击的方向的量
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    
//    创建动画效果
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width/velocity;
    SKAction *actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster{
    NSLog(@"Hit");
    [projectile removeFromParent];
    [monster removeFromParent];
    self.monstersDestroyed++;
//    设置游戏一局出现的monster的总数量
    if (self.monstersDestroyed >30) {
        SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
        SKScene *gameOverScene = [[GameOverScene alloc]initWithSize:self.size won:YES];
        [self.view presentScene:gameOverScene transition:reveal];
    }
}

//撞击效果展示
- (void)didBeginContact:(SKPhysicsContact *)contact{
    SKPhysicsBody *firstBody, *secongBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secongBody = contact.bodyB;
    }else{
        firstBody = contact.bodyB;
        secongBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&(secongBody.categoryBitMask & monsterCategory) != 0) {
        [self projectile:(SKSpriteNode *)firstBody.node didCollideWithMonster:(SKSpriteNode *) secongBody.node];
    }
}









@end

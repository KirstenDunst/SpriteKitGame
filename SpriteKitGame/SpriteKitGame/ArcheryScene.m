//
//  ArcheryScene.m
//  SpriteKitGame
//
//  Created by CSX on 2017/9/14.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "ArcheryScene.h"
#import "MyGameScene.h"

#define NodeName @"archrNode"

@interface ArcheryScene ()<SKPhysicsContactDelegate>
{
    uint32_t ballCategory ;
    uint32_t arrowCategory;
}
@property (nonatomic , assign) int score;
@property (nonatomic , assign) int ballcount;
@property (nonatomic , strong) NSMutableArray *archerAnimation;

@end


@implementation ArcheryScene
- (NSMutableArray *)archerAnimation{
    if (!_archerAnimation) {
        _archerAnimation = [NSMutableArray array];
    }
    return _archerAnimation;
}
//首先执行
- (void)didMoveToView:(SKView *)view{
    [super didMoveToView:view];
    ballCategory = 1;
//    创建背景
    [self backgroundNode];
//        进行初始化操作
        self.score = 0;
        self.ballcount = 10;
//        设置重力模型的标准，gravity的默认值是0.0，-9.8
        self.physicsWorld.gravity = CGVectorMake(0, -1.0);
//        设置物理碰撞模型代理。为以后的物理撞击做准备
        self.physicsWorld.contactDelegate = (id)self;
        [self initArcheryScene];
}
#pragma mark ----创建背景----
-(void)backgroundNode{
    
    SKSpriteNode *backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"59a4cfe2550cc.jpg"];
    
    backgroundNode.position = CGPointZero;
    
    backgroundNode.zPosition = 0;
    
    backgroundNode.anchorPoint = CGPointZero;
    
    backgroundNode.size = self.size;
    
    [self addChild:backgroundNode];
}

- (void)initArcheryScene{
//    设置该场景的一些参数
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
//    给场景中添加一个节点
    SKSpriteNode *archerNode = [self createArcherNode];
    archerNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame));
    [self addChild:archerNode];
    
//    下面这段代码是为了实现将多个图片顺序播放。（给人一种动画的感觉）；这里只是将图片按照TextureAtlas的方式存储到一个数组archerAnimation里面
    NSMutableArray *archerFrames = [NSMutableArray array];
//    读取atlas文件。（atlas文件是有多个图像文件生成的一个大的图像文件，在程序中可以直接调用生成动画效果）
//    注意：必须将这一系列的图像放在一个文件夹下。（文件夹以“.atlas”结尾）,下面就是读取archer.atlates的大图像。
    SKTextureAtlas *archerAtlas = [SKTextureAtlas atlasNamed:@"archer"];
    for (int i = 0; i<archerAtlas.textureNames.count; ++i) {
        NSString *texture = [NSString stringWithFormat:@"archer%03d",i];
        [archerFrames addObject:[archerAtlas textureNamed:texture]];
    }
    self.archerAnimation = archerFrames;
    
//    实现小球不断从顶部掉下的动作。循环制定次数。循环结束的时候执行gameover方法。
    SKAction *releaseBall = [SKAction sequence:@[
                                                 [SKAction performSelector:@selector(createBallNote) onTarget:self],[SKAction waitForDuration:1.0]]];
    
    [self runAction:[SKAction repeatAction:releaseBall count:self.ballcount] completion:^{
        [self gameOver];
    }];
}

- (SKSpriteNode *)createArcherNode{
    SKSpriteNode *archerNode = [[SKSpriteNode alloc]initWithImageNamed:@"archer001.png"];
    archerNode.name = NodeName;
    return archerNode;
}
//初始化小球node的代码
- (void)createBallNote{
    SKSpriteNode *ball = [[SKSpriteNode alloc]initWithImageNamed:@"BallTexture.png"];
    ball.name = @"ballNode";
    ball.position = CGPointMake(200+((int)arc4random()%((int)self.size.width-200)), self.size.height-50);
    
//    给每个小球都赋予物理模型，这样小球就有了重力，自动下降。
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(ball.size.width/2)-7];
    ball.physicsBody.usesPreciseCollisionDetection = YES;
//    物体是否受力
    ball.physicsBody.dynamic = YES;
//    设置这个球的种类掩码（用于决定是否能够发生碰撞反应）
    ball.physicsBody.categoryBitMask = ballCategory;
    
    [self  addChild:ball];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    SKNode *archerNode = [self childNodeWithName:NodeName];
    if (archerNode != nil) {
        SKAction *animation = [SKAction animateWithTextures:self.archerAnimation timePerFrame:0.05];
        SKAction *shootAction = [SKAction runBlock:^{
            SKNode *arrowNode = [self createArrowNode];
            [self addChild:arrowNode];
//            给arrow赋予一个水平推动力
            [arrowNode.physicsBody applyImpulse:CGVectorMake(35.0, 0)];
        }];
//        合并两个action，以此顺序执行
        SKAction *sequence = [SKAction sequence:@[animation,shootAction]];
        [archerNode runAction:sequence];
    }
    
}

- (SKSpriteNode *)createArrowNode{
    SKSpriteNode *arrow = [[SKSpriteNode alloc]initWithImageNamed:@"ArrowTexture.png"];
    arrow.position = CGPointMake(CGRectGetMinX(self.frame)+100, CGRectGetMinY(self.frame));
    arrow.name = @"arrowNode";
    arrow.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:arrow.frame.size];
    arrow.physicsBody.usesPreciseCollisionDetection = YES;
    
//    设置箭这个node的种类掩码（用于决定是否能够触发碰撞反应）
    arrow.physicsBody.categoryBitMask = arrowCategory;
    arrow.physicsBody.collisionBitMask = arrowCategory | ballCategory;
    arrow.physicsBody.contactTestBitMask = arrowCategory | ballCategory;
    return arrow;
}
//这是个物理碰撞   SKPhysicsContactDelegate 协议的 方法 （如果判断发生了碰撞，就会触发）
- (void)didBeginContact:(SKPhysicsContact *)contact{
    SKSpriteNode *firstNode, *secondNode;
//    获取发生碰撞的两个物体node
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *)contact.bodyB.node;
    
//    判断碰撞a物体为箭，b物体为球
    if ((contact.bodyA.categoryBitMask == arrowCategory) && (contact.bodyB.categoryBitMask == ballCategory)) {
        CGPoint contactPoint = contact.contactPoint;
        float contact_x = contactPoint.x;
        float contact_y = contactPoint.y;
        float target_y = secondNode.position.y;
        float margin = secondNode.frame.size.height/2-25;
//        判断碰撞的位置在规定的范围内，执行相应的动作
        if ((contact_y > (target_y - margin))&& (contact_y<(target_y+margin))) {
            NSLog(@"HIt");
            
//            创建一个碰撞结合处
            SKPhysicsJointFixed *joint = [SKPhysicsJointFixed jointWithBodyA:contact.bodyA bodyB:contact.bodyB anchor:CGPointMake(contact_x, contact_y)];
            [self.physicsWorld addJoint:joint];
//            获取新的图片
            SKTexture *texture = [SKTexture textureWithImageNamed:@"ArrowHitTexture.png"];
            firstNode.texture = texture;
            
            self.score++;
        }
    }
}




//游戏结束
- (void)gameOver{
    [self runAction:[SKAction waitForDuration:5.0]];
//    SKLabelNode *scoreNode = [self createScoreNode];
//    [self addChild:scoreNode];
    SKAction *fadeout = [SKAction sequence:@[[SKAction waitForDuration:3.0],[SKAction fadeOutWithDuration:3.0]]];
    SKAction *welcomeReturn = [SKAction runBlock:^{
        SKTransition *transition = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
        MyGameScene *welcomeScene = [[MyGameScene alloc]initWithSize:self.size];
        [self.scene.view presentScene:welcomeScene transition:transition];
    }];
    SKAction *sequeue = [SKAction sequence:@[fadeout,welcomeReturn]];
    [self runAction:sequeue];
}



@end

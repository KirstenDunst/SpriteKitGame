//
//  MyGameScene.m
//  SpriteKitGame
//
//  Created by CSX on 2017/9/14.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "MyGameScene.h"
#import "ArcheryScene.h"

#define nodeName @"welcomeNote"

@implementation MyGameScene

//这个方法会在当前场景展示之前，自动调用
//重载这个方法，当游戏加载到这个场景的时候，会自动调用这个方法
- (void)didMoveToView:(SKView *)view{
    [super didMoveToView:view];
    self.backgroundColor = [SKColor lightGrayColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    [self addChild:[self createWelecomeNote]];
}
- (SKLabelNode *)createWelecomeNote{
    SKLabelNode *welcomeNote = [SKLabelNode labelNodeWithFontNamed:@"Bradley Hand"];
    welcomeNote.name = nodeName;
    welcomeNote.text = @"welcome here";
    welcomeNote.fontSize = 44;
    welcomeNote.fontColor = [SKColor blackColor];
    welcomeNote.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame));
    return welcomeNote;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    SKNode *welcomeNote = [self childNodeWithName:nodeName];
//    判断当前正处于欢迎界面
    if (welcomeNote != nil) {
//        定义一个fadeout的action动作
        SKAction *fadeAway = [SKAction fadeOutWithDuration:1.0];
//        在欢迎界面执行fadeout的动作效果，动作完成之后执行complet的block之后的代码
        [welcomeNote runAction:fadeAway completion:^{
//            初始化一个新的场景
            SKScene *archeryScene = [[ArcheryScene alloc]initWithSize:self.size];
//            新建一个场景的过渡场景的变量（以开门的方式）
            SKTransition *door = [SKTransition doorwayWithDuration:1.0];
//            执行过渡，跳转到下一个场景
            [self.view presentScene:archeryScene transition:door];
        }];
    }
}
@end

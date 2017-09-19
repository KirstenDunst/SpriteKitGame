//
//  GameOverScene.m
//  SpriteKitGame
//
//  Created by CSX on 2017/9/18.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "GameOverScene.h"
#import "KillMonster.h"

@implementation GameOverScene

-(instancetype)initWithSize:(CGSize)size won:(BOOL)won{
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        NSString *message;
        if (won) {
            message = @"你赢了";
        }else{
            message = @"你失败了！";
        }
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        [self runAction:
         [SKAction sequence:
           @[[SKAction waitForDuration:3.0],
             [SKAction runBlock:^{
            SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
            SKScene *myScene = [[KillMonster alloc]initWithSize:self.size];
            [self.view presentScene:myScene transition:reveal];
             }]
             ]
          ]
         ];
        
        
    }
    return self;
}


@end

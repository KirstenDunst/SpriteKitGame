//
//  GameViewController.m
//  SpriteKitGame
//
//  Created by CSX on 2017/9/14.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "GameViewController.h"
//#import "GameScene.h"

#import "MyGameScene.h"
#import "AirplaneGame.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//工程创建的时候，带的基本demo
//    // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
//    // including entities and graphs.
//    GKScene *scene = [GKScene sceneWithFileNamed:@"GameScene"];
//    
//    // Get the SKScene from the loaded GKScene
//    GameScene *sceneNode = (GameScene *)scene.rootNode;
//    
//    // Copy gameplay related content over to the scene
////    复制游戏相关内容到现场
//    sceneNode.entities = [scene.entities mutableCopy];
//    sceneNode.graphs = [scene.graphs mutableCopy];
//    
//    // Set the scale mode to scale to fit the window
////这里SKSceneScaleModeAspectFill表示按比例放大SKView，同时保持场景的纵横比。如果视图有不同的纵横比，可能会出现一些裁剪。
////设置scenennode在窗口上展示的样式
//    sceneNode.scaleMode = SKSceneScaleModeAspectFill;
//    
//    SKView *skView = (SKView *)self.view;
//    
//    // Present the scene
//    [skView presentScene:sceneNode];
//    
////    FPS是图像领域中的定义，是指画面每秒传输帧数，通俗来讲就是指动画或视频的画面数.右下角的第一个参数以及值
//    skView.showsFPS = YES;
////    屏幕右下角第二个参数以及值，（node：2）（nodecount表示节点的数量）（个人可以理解为：这个view上面有在某一时刻多少元素存在）
//    skView.showsNodeCount = YES;
    
//    我自己创建的基本控件
    [self frameViewCreateViews];
    
}
- (void)frameViewCreateViews{
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
//    测试1
    MyGameScene *gameScane = [[MyGameScene alloc]initWithSize:self.view.frame.size];
//    测试2
//    AirplaneGame *gameScane = [[AirplaneGame alloc]initWithSize:self.view.frame.size];
    [skView presentScene:gameScane];
}






//允许设备自动调整横竖设备的状体
- (BOOL)shouldAutorotate {
    return YES;
}
//根据设备的状态调整状态的旋转样式。
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

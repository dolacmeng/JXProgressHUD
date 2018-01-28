//
//  ViewController.m
//  JXProgressHUD
//
//  Created by pconline on 2018/1/16.
//  Copyright © 2018年 tianguo. All rights reserved.
//

#import "ViewController.h"
#import "JXProgressHud.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载-成功
    [[JXProgressHud hud] showWithType:JXProgressTypeLodaing inView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[JXProgressHud hud] showWithType:JXProgressTypeSuccess inView:self.view];
    });
    
    //加载-失败
    [self performSelector:@selector(fail) withObject:nil afterDelay:8];
}


-(void)fail{
    [[JXProgressHud hud] showWithType:JXProgressTypeLodaing text:@"努力加载中..." inView:self.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[JXProgressHud hud] showWithType:JXProgressTypeFail text:@"加载失败！" inView:self.view];
    });
}



@end

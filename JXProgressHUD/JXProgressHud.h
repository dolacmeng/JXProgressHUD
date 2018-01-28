//
//  JXProgressHud.h
//  JXProgressHUD
//
//  Created by pconline on 2018/1/16.
//  Copyright © 2018年 tianguo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,JXProgressType){
    JXProgressTypeLodaing,
    JXProgressTypeSuccess,
    JXProgressTypeFail
};

@interface JXProgressHud : UIView

+(instancetype)hud;

- (void)showWithType:(JXProgressType)type inView:(UIView*)view;
- (void)showWithType:(JXProgressType)type text:(NSString*)text inView:(UIView*)view;

@end

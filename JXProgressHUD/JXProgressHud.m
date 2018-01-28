//
//  JXProgressHud.m
//  JXProgressHUD
//
//  Created by pconline on 2018/1/16.
//  Copyright © 2018年 tianguo. All rights reserved.
//

#import "JXProgressHud.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define ThemeColor [UIColor colorWithRed:245.0/255.0 green:93.0/255.0 blue:84.0/255.0 alpha:1]
#define FailColor [UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1]
#define angle2Rad(angle) ((angle) / 180.0 * M_PI)

@interface JXProgressHud()

@property(nonatomic,assign) JXProgressType type;
@property(nonatomic,weak) UIView *hudView;
@property(nonatomic,weak) UILabel *textLabel;

@property(nonatomic,strong) CAShapeLayer *loadingLayer;//圆环
@property(nonatomic,strong) CAShapeLayer *successLayer;//勾
@property(nonatomic,strong) CADisplayLink *link;
@property(nonatomic,assign) CGFloat progress;
@property(nonatomic,assign) CGFloat startAngle;
@property(nonatomic,assign) CGFloat endAngle;
@end

@implementation JXProgressHud

static JXProgressHud *_hud = nil;
+(instancetype)hud{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hud = [[JXProgressHud alloc] init];
        _hud.tag = [@"JXProgressHud" hash];
    });
    return _hud;
}

-(instancetype)init{
    if (self = [super init]) {
        [self setUpView];
    }
    return self;
}

-(void)setUpView{
    
    self.tag = [@"JXProgressHud" hash];

    UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 116, 116)];
    hudView.frame = CGRectMake(0, 0, 116, 116);
    hudView.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    hudView.layer.cornerRadius = 5;
    hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    hudView.layer.shadowColor  = [UIColor darkGrayColor].CGColor;
    hudView.layer.shadowOffset = CGSizeMake(1, 1);
    [self addSubview:hudView];
    self.hudView = hudView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 95, 116, 16)];
    label.text = @"正在加载";
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.hudView addSubview:label];
    self.textLabel = label;
}

- (void)showWithType:(JXProgressType)type text:(NSString*)text inView:(UIView*)view{
    _type = type;
    if(type == JXProgressTypeLodaing){
        [self clearLayer];
        [self addHudInView:view];
        [self.textLabel setText:text?:@""];
        self.link.paused = NO;
    }else if(type == JXProgressTypeSuccess){
        [self clearLayer];
        [self addHudInView:view];
        [self.textLabel setText:text?:@""];
        [self circleAnimation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkAnimation];
        });
        [self hideInSecond:1.5];
    }else if(type == JXProgressTypeFail){
        [self clearLayer];
        [self addHudInView:view];
        [self.textLabel setText:text?:@""];
        [self circleAnimation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self failAnimation];
        });
        [self hideInSecond:1.5];
    }
}


- (void)showWithType:(JXProgressType)type inView:(UIView*)view{
    [self showWithType:type text:@"" inView:view];
}



#pragma mark - loading

-(CAShapeLayer*)loadingLayer{
    if (_loadingLayer == nil) {
        _loadingLayer = [CAShapeLayer layer];
        _loadingLayer.frame = CGRectMake(0, 0, 60, 60);
        _loadingLayer.position = CGPointMake(self.hudView.bounds.size.width/2.0f, self.hudView.bounds.size.height/2.0);
        _loadingLayer.fillColor = [UIColor clearColor].CGColor;
        _loadingLayer.strokeColor = ThemeColor.CGColor;
        _loadingLayer.lineWidth = 2.f;
        _loadingLayer.lineCap = kCALineCapRound;
        [self.hudView.layer addSublayer:_loadingLayer];
    }
    return _loadingLayer;
}

-(CADisplayLink*)link{
    if (_link == nil) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _link.paused = YES;
    }
    return _link;
}

-(void)displayLinkAction{
    self.progress += [self speed];
    if (self.progress >= 1) {
        self.progress = 0;
    }
    [self updateProgressAnimationLayer];
}

-(CGFloat)speed{
    if (self.endAngle > M_PI) {
        return 0.3/60;
    }else{
        return 2.0/60;
    }
}

-(void)updateProgressAnimationLayer{
    self.endAngle = -M_PI/2 + _progress * M_PI * 2;
    
    //前半段
    if (self.endAngle < M_PI) {
        self.startAngle = -M_PI/2;
    }
    //后半段
    else{
        CGFloat progress = 1-(1-self.progress)/0.25;
        self.startAngle = -M_PI/2 + progress * M_PI *2;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.loadingLayer.bounds.size.width/2,self.loadingLayer.bounds.size.height/2) radius:30 startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    self.loadingLayer.path = path.CGPath;
    
}


#pragma mark - success

-(void)circleAnimation{
    self.link.paused = YES;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.loadingLayer.bounds.size.width/2,self.loadingLayer.bounds.size.height/2) radius:30 startAngle:-M_PI/2 endAngle:M_PI*3/2 clockwise:YES];
    self.loadingLayer.path = path.CGPath;
    self.loadingLayer.strokeColor = (_type==JXProgressTypeSuccess)?ThemeColor.CGColor:FailColor.CGColor;
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleAnimation.fromValue = @(0.);
    circleAnimation.toValue = @(1.);
    circleAnimation.duration = .5;
    [self.loadingLayer addAnimation:circleAnimation forKey:nil];
}

-(void)checkAnimation{
    //外切圆的边长
    CGFloat a = self.loadingLayer.bounds.size.width;
    //设置三个点 A、B、C
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*2.7/10,a*5.4/10)];
    [path addLineToPoint:CGPointMake(a*4.5/10,a*7/10)];
    [path addLineToPoint:CGPointMake(a*7.8/10,a*3.8/10)];
    
    CAShapeLayer *checkLayer = [CAShapeLayer layer];
    checkLayer.path = path.CGPath;
    checkLayer.fillColor = [UIColor clearColor].CGColor;
    checkLayer.strokeColor = ThemeColor.CGColor;
    checkLayer.lineWidth = 2.0;
    checkLayer.lineCap = kCALineCapRound;
    checkLayer.lineJoin = kCALineJoinRound;
    [self.loadingLayer addSublayer:checkLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = .5;
    animation.fromValue = @(0.);
    animation.toValue = @(1.);
    [checkLayer addAnimation:animation forKey:nil];

}

#pragma mark - fail

-(void)failAnimation{
    
    CGFloat a = 60;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(18, 18)];
    [path addLineToPoint:CGPointMake(a-18, a-18)];
    [path moveToPoint:CGPointMake(a-18, 18)];
    [path addLineToPoint:CGPointMake(18, a-18)];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = FailColor.CGColor;
    layer.lineWidth = 3.0;
    layer.lineCap = kCALineCapRound;
    layer.anchorPoint = CGPointMake(1, 1);
    [self.loadingLayer addSublayer:layer];
    
    //抖动动画
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
//    animation.values = @[@(angle2Rad(-6)),@(angle2Rad(6)),@(angle2Rad(-6))];
//    animation.repeatCount = MAXFLOAT;
//    animation.duration = 0.3;
//
//    [layer addAnimation:animation forKey:nil];
//    UIBezierPath *leftPath = [UIBezierPath bezierPath];
//    [leftPath moveToPoint:CGPointMake(18, 18)];
//    [leftPath addLineToPoint:CGPointMake(a-18, a-18)];

    
      //绘制动画
//    CAShapeLayer *leftLayer = [CAShapeLayer layer];
//    leftLayer.path = leftPath.CGPath;
//    leftLayer.fillColor = [UIColor clearColor].CGColor;
//    leftLayer.strokeColor = FailColor.CGColor;
//    leftLayer.lineWidth = 2.0;
//    leftLayer.lineCap = kCALineCapRound;
//    [self.loadingLayer addSublayer:leftLayer];
//
//    UIBezierPath *rightPath = [UIBezierPath bezierPath];
//    [rightPath moveToPoint:CGPointMake(a-18, 18)];
//    [rightPath addLineToPoint:CGPointMake(18, a-18)];
//
//    CAShapeLayer *rightLayer = [CAShapeLayer layer];
//    rightLayer.path = rightPath.CGPath;
//    rightLayer.lineWidth = 2.0;
//    rightLayer.fillColor = [UIColor clearColor].CGColor;
//    rightLayer.strokeColor = FailColor.CGColor;
//    rightLayer.lineCap = kCALineCapRound;
//    [self.loadingLayer addSublayer:rightLayer];
//
//    CABasicAnimation *leftAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    leftAnimation.duration = .3;
//    leftAnimation.fromValue = @(0.);
//    leftAnimation.toValue = @(1.);
//    [leftLayer addAnimation:leftAnimation forKey:nil];
//
//    CABasicAnimation *rightAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    rightAnimation.duration = .3;
//    rightAnimation.fromValue = @(0.);
//    rightAnimation.toValue = @(1.);
//    [rightLayer addAnimation:rightAnimation forKey:nil];
    
}

-(void)clearLayer{
    for (CALayer *layer in self.loadingLayer.sublayers) {
        [layer removeFromSuperlayer];
    }
}

-(void)hideInSecond:(CGFloat)second{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hud removeFromSuperview];
        [self clearLayer];
    });
}

-(void)addHudInView:(UIView*)view{
    if([view viewWithTag:[@"JXProgressHud" hash]] == nil){
        _hud.frame = view.bounds;
        [view addSubview:_hud];
    }
}

@end

//
//  CCPCameraView.m
//  CCPCustomCamera
//
//  Created by CCP on 2016/10/26.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import "CCPCameraView.h"
#define CCPDisplayLink 60
@interface CCPCameraView ()

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) CGPoint point;
@property (assign, nonatomic) BOOL isFoucsEnd;

@end

@implementation CCPCameraView

- (instancetype)init {
    
    if (self = [super init]) {
        //添加点击手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGesture];

    }
    
    return self;
}

- (void)tap:(UIGestureRecognizer *)tap {
    
    if (self.isFoucsEnd) return;
    
    self.isFoucsEnd = YES;
    
    CGPoint point = [tap locationInView:self];
    
    self.point = point;
    
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if ([self.delegate respondsToSelector:@selector(cameraDidSelected:)]) {
        [self.delegate cameraDidSelected:self];
    }
    
}

- (CADisplayLink *)displayLink{
    if (!_displayLink) {
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshView:)];
    }
    return _displayLink;
}

- (void) refreshView : (CADisplayLink *) link{
    [self setNeedsDisplay];
    self.count++;
}

//对焦框的绘制
- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    if (self.isFoucsEnd) {
        CGFloat rectValue = CCPDisplayLink - self.count % CCPDisplayLink;
        CGRect rectangle = CGRectMake(self.point.x - rectValue / 2.0, self.point.y - rectValue / 2.0, rectValue * 1.3, rectValue * 1.3);
        //获得上下文句柄
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        if (rectValue <= 25) {
            self.isFoucsEnd = NO;
            [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [self.displayLink invalidate];
            self.displayLink = nil;
            self.count = 0;
            CGContextClearRect(currentContext, rectangle);
        }else{
            //创建图形路径句柄
            CGMutablePathRef path = CGPathCreateMutable();
            //设置矩形的边界
            //添加矩形到路径中
            CGPathAddRect(path,NULL, rectangle);
            //添加路径到上下文中
            CGContextAddPath(currentContext, path);
            //填充颜色
            [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0] setFill];
            //设置画笔颜色
            [[UIColor yellowColor] setStroke];
            //设置边框线条宽度
            CGContextSetLineWidth(currentContext,1.0f);
            //画图
            CGContextDrawPath(currentContext, kCGPathFillStroke);
            /* 释放路径 */
            CGPathRelease(path);
        }
    }
}

@end

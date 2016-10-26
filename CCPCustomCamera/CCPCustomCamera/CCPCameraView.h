//
//  CCPCameraView.h
//  CCPCustomCamera
//
//  Created by CCP on 2016/10/26.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCPCameraView;

@protocol CCPCameraViewDelegate <NSObject>

//点击的代理方法
- (void) cameraDidSelected:(CCPCameraView *) CCPCamera;

@end

@interface CCPCameraView : UIView

@property (nonatomic,weak) id <CCPCameraViewDelegate> delegate;

@end

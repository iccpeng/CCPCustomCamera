//
//  CCPShowPhotoVC.h
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/15.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@interface CCPShowPhotoVC : UIViewController

@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) PHFetchResult *fetchResult;
@property (nonatomic,assign) BOOL isIOS8;
@end

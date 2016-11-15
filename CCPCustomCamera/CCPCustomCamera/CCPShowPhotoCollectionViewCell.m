//
//  CCPShowPhotoCollectionViewCell.m
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/15.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import "CCPShowPhotoCollectionViewCell.h"

@implementation CCPShowPhotoCollectionViewCell

#pragma mark - 直接写这个方法
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self makeUI];
        
    }
    return self;
}

- (void)makeUI{
    self.contentView.backgroundColor = [UIColor whiteColor];

}

- (void)layoutSubviews {
    
}

@end

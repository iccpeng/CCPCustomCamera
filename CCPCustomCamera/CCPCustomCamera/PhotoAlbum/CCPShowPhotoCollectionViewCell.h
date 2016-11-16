//
//  CCPShowPhotoCollectionViewCell.h
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/15.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^clickSelectedBtnBlock)(NSInteger btnTag);
typedef void(^clickUnselectedBtnBlock)(NSInteger btnTag);

@interface CCPShowPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImage *showImage;
@property (nonatomic,assign) NSInteger btnTag;

@property (nonatomic,copy) clickSelectedBtnBlock selectedBtnBlock;
@property (nonatomic,copy) clickUnselectedBtnBlock unselectedBtnBlock;

@end

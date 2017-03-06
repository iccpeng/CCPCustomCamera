//
//  CCPShowPhotoCollectionViewCell.h
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/15.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^clickSelectedBtnBlock)(UIButton* btn);
typedef void(^clickUnselectedBtnBlock)(UIButton* btn);

@interface CCPShowPhotoCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) UIImage *showImage;
@property (nonatomic,weak) UIButton *selectBtn;
@property (nonatomic,copy) clickSelectedBtnBlock selectedBtnBlock;
@property (nonatomic,copy) clickUnselectedBtnBlock unselectedBtnBlock;

@end

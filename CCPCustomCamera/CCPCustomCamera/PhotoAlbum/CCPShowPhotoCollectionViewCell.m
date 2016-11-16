//
//  CCPShowPhotoCollectionViewCell.m
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/15.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import "CCPShowPhotoCollectionViewCell.h"

@interface CCPShowPhotoCollectionViewCell ()

@property (nonatomic,weak) UIImageView *showImageView;
@property (nonatomic,weak) UIButton *selectBtn;

@end

@implementation CCPShowPhotoCollectionViewCell

#pragma mark - 直接写这个方法
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self makeUI];
        
    }
    return self;
}

- (void)setShowImage:(UIImage *)showImage {
    
    _showImage = showImage;
    
    self.showImageView.image = showImage;
    
}

- (void)setBtnTag:(NSInteger)btnTag {
    _btnTag = btnTag;
    self.selectBtn.tag = btnTag + 100;
}


- (void)makeUI{
    self.contentView.backgroundColor = [UIColor redColor];
    UIImageView *showImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:showImageView];
    self.showImageView = showImageView;
    UIButton *selectBtn = [[UIButton alloc] init];
    [selectBtn setImage:[UIImage imageNamed:@"weiXuanZhong"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:selectBtn];
    self.selectBtn = selectBtn;
}

- (void) clickSelectBtn:(UIButton *)sender {
   
    sender.selected = !sender.selected;
    if (sender.selected) {
        
        [sender setImage:[UIImage imageNamed:@"xuanzhong"] forState:UIControlStateNormal];
        
        if (self.selectedBtnBlock) {
            
            self.selectedBtnBlock(sender.tag - 100);
        }
        
    } else {
         [sender setImage:[UIImage imageNamed:@"weiXuanZhong"] forState:UIControlStateNormal];
        
        if (self.unselectedBtnBlock) {
            
            self.unselectedBtnBlock(sender.tag - 100);
        }
        
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.showImageView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    self.selectBtn.frame = CGRectMake(self.contentView.frame.size.width - 25, 0, 25, 25);
}

@end

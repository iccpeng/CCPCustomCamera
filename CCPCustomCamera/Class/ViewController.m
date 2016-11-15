//
//  ViewController.m
//  CCPCustomCamera
//
//  Created by C CP on 16/9/21.
//  Copyright © 2016年 C CP. All rights reserved.
//


#import "ViewController.h"
#import "CCPTakePicturesController.h"
#import "CCPPhotoAlbumViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *englishNameLabel;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.iconImageView.layer.cornerRadius = 12;
    
    self.iconImageView.layer.masksToBounds = YES;
    
    self.iconImageView.alpha = 0.9f;

    //设置字体样式
    self.englishNameLabel.font = [UIFont fontWithName:@"Zapfino" size:16];
    
    //UIKIT_EXTERN const CGFloat UIFontWeightThin NS_AVAILABLE_IOS(8_2); 字体变细
    self.appNameLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightThin];
}

- (IBAction)takeApictures:(UIButton *)sender {
    
    CCPTakePicturesController *picturesVC = [[CCPTakePicturesController alloc] init];
    __weak typeof(self) weakSelf = self;
    //获取截图
    picturesVC.iconImage = ^(UIImage *iconImage) {
        
        weakSelf.iconImageView.image = iconImage;
        
    };
    
    [self presentViewController:picturesVC animated:YES completion:nil];
}

- (IBAction)clickPhotoAlbumBtn:(UIButton *)sender {
    
    CCPPhotoAlbumViewController *photoAlbumVC = [[CCPPhotoAlbumViewController alloc] init];
    
    [self presentViewController:photoAlbumVC animated:YES completion:nil];
    
}


@end

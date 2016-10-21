//
//  ViewController.m
//  CCPCustomCamera
//
//  Created by C CP on 16/9/21.
//  Copyright © 2016年 C CP. All rights reserved.
//


#import "ViewController.h"
#import "CCPTakePicturesController.h"

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
    
    self.iconImageView.alpha = 0.8;
    
    self.appNameLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size:24];
    
    //UIKIT_EXTERN const CGFloat UIFontWeightThin NS_AVAILABLE_IOS(8_2); 字体变细
    self.appNameLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightThin];
    //
    self.englishNameLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightHeavy];
}

- (IBAction)takeApictures:(UIButton *)sender {
    
    CCPTakePicturesController *picturesVC = [[CCPTakePicturesController alloc] init];
    
    [self presentViewController:picturesVC animated:YES completion:nil];
}



@end

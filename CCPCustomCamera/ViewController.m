//
//  ViewController.m
//  CCPCustomCamera
//
//  Created by DR on 16/9/21.
//  Copyright © 2016年 CCP. All rights reserved.
//


#import "ViewController.h"
#import "CCPTakePicturesController.h"

@interface ViewController ()


@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)takeApictures:(UIButton *)sender {
    
    CCPTakePicturesController *picturesVC = [[CCPTakePicturesController alloc] init];
    
    [self.view.window.rootViewController presentViewController:picturesVC animated:YES completion:nil];
}



@end

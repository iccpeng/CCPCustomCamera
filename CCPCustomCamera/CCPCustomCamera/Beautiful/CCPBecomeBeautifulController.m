//
//  CCPBecomeBeautifulController.m
//  CCPCustomCamera
//
//  Created by CCP on 2017/3/6.
//  Copyright © 2017年 CCP. All rights reserved.
//

#import "CCPBecomeBeautifulController.h"
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"

@interface CCPBecomeBeautifulController ()
@property (weak, nonatomic) IBOutlet UIImageView *becomeImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *becomeScrollview;

@end

@implementation CCPBecomeBeautifulController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
    //设置滤镜的效果
    GPUImageBeautifyFilter *passthroughFilter = [[GPUImageBeautifyFilter alloc] init];
    //设置要渲染的区域
    [passthroughFilter forceProcessingAtSize:self.becomeImageView.image.size];
    [passthroughFilter useNextFrameForImageCapture];
    //获取数据源
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:self.becomeImageView.image];
    //加上滤镜
    [stillImageSource addTarget:passthroughFilter];
    //开始渲染
    [stillImageSource processImage];
    //获取渲染后的图片
    UIImage *newImage = [passthroughFilter imageFromCurrentFramebuffer];
    self.becomeImageView.image = newImage;
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
}

- (void)makeUI {
    self.becomeScrollview.contentSize = CGSizeMake(530, 0);
    self.becomeScrollview.showsVerticalScrollIndicator = YES;
    self.becomeScrollview.backgroundColor = [UIColor redColor];
    for (int i = 0; i < 5; i++) {
        UIButton *becomeButton = [[UIButton alloc] init];
        becomeButton.frame = CGRectMake(5 + 105 * i, 0, 100, 100);
        [becomeButton setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        [becomeButton setBackgroundColor:[UIColor orangeColor]];
        becomeButton.tag = 100 + i;
        [becomeButton addTarget:self action:@selector(clickTheBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.becomeScrollview addSubview:becomeButton];
        
    }
    
}

- (void)clickTheBtn:(UIButton *)btn {
    
    NSLog(@"%@--%ld",btn,btn.tag);
}

- (void) becomeBeautiful {
    
    
}


- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

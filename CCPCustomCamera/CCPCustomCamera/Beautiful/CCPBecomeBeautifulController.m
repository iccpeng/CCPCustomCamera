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
@property (nonatomic,strong) GPUImagePicture *imagePicture;
@property (nonatomic,strong) NSMutableArray *filterNameArray;
@property (nonatomic,strong) NSMutableArray *filterStyleArray;

@end

@implementation CCPBecomeBeautifulController

- (NSMutableArray *)filterNameArray {
    
    if (_filterNameArray == nil) {
        
        _filterNameArray = [NSMutableArray arrayWithObjects:@"原图",@"美白",@"高亮",@"怀旧",@"模糊", nil];
    }
    return _filterNameArray;
}

- (NSMutableArray *)filterStyleArray {
    
    if (_filterStyleArray == nil) {
        GPUImageSepiaFilter *passthroughFilter = [[GPUImageSepiaFilter alloc] init];
        _filterStyleArray = [NSMutableArray arrayWithObjects:@"",passthroughFilter,passthroughFilter,passthroughFilter,passthroughFilter, nil];
    }
    return _filterStyleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
}

- (void)makeUI {
    self.becomeScrollview.contentSize = CGSizeMake(530, 0);
    self.becomeScrollview.showsHorizontalScrollIndicator = NO;
    UIImage *image = [UIImage imageNamed:@"tongliya"];
    for (int i = 0; i < 5; i++) {
        UIImage *newImage = [self becomeBeautiful:i image:image];
        UIButton *becomeButton = [[UIButton alloc] init];
        becomeButton.frame = CGRectMake(5 + 105 * i, 0, 100, 100);
        [becomeButton setTitle:[NSString stringWithFormat:@"%@",self.filterNameArray[i]] forState:UIControlStateNormal];
        becomeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -70, 0);
        [becomeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [becomeButton setBackgroundImage:newImage forState:UIControlStateNormal];
        becomeButton.tag = 100 + i;
        [becomeButton addTarget:self action:@selector(clickTheBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.becomeScrollview addSubview:becomeButton];
    }
}

- (void)clickTheBtn:(UIButton *)btn {
    UIImage *imageTest = [UIImage imageNamed:@"tongliya"];
    UIImage *newImage = [self becomeBeautiful:btn.tag - 100 image:imageTest];
    self.becomeImageView.image = newImage;
}

- (UIImage *) becomeBeautiful:(NSInteger)tag image:(UIImage *)image {
    
    switch (tag) {
        case 0:
            return image;
        case 1:{
            //美颜
            GPUImageBeautifyFilter *filter = [[GPUImageBeautifyFilter alloc] init];
            [filter forceProcessingAtSize:image.size];
            [filter useNextFrameForImageCapture];
            self.imagePicture = [[GPUImagePicture alloc] initWithImage:image];
            [self.imagePicture addTarget:filter];
            [self.imagePicture processImage];
            UIImage *newImage = [filter imageFromCurrentFramebuffer];
            return newImage;
        }
            break;
        case 2:{
            //高亮
            GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
            filter.brightness = 0.3;
            //设置要渲染的区域
            [filter forceProcessingAtSize:image.size];
            //捕获图片效果
            [filter useNextFrameForImageCapture];
            self.imagePicture = [[GPUImagePicture alloc] initWithImage:image];
            //加上滤镜
            [self.imagePicture addTarget:filter];
            //开始渲染
            [self.imagePicture processImage];
            //获取渲染后的图片
            UIImage *newImage = [filter imageFromCurrentFramebuffer];
            return newImage;
            
        }
            break;
        case 3:{
            //怀旧
            GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
            [filter forceProcessingAtSize:image.size];
            [filter useNextFrameForImageCapture];
            self.imagePicture = [[GPUImagePicture alloc] initWithImage:image];
            [self.imagePicture addTarget:filter];
            [self.imagePicture processImage];
            UIImage *newImage = [filter imageFromCurrentFramebuffer];
            return newImage;
         }
            break;
        case 4:{
            //高斯模糊
            GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
            [filter forceProcessingAtSize:image.size];
            [filter useNextFrameForImageCapture];
            self.imagePicture = [[GPUImagePicture alloc] initWithImage:image];
            [self.imagePicture addTarget:filter];
            [self.imagePicture processImage];
            UIImage *newImage = [filter imageFromCurrentFramebuffer];
            return newImage;
        }
            break;
        default:
            break;
    }
    return image;
}


- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

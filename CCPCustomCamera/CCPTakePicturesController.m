//
//  CCPTakePicturesController.m
//  CCPCustomCamera
//
//  Created by DR on 16/9/22.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import "CCPTakePicturesController.h"

#import <AVFoundation/AVFoundation.h>
//处理相册的系统框架
#import <AssetsLibrary/AssetsLibrary.h>

@interface CCPTakePicturesController ()

//创建相机相关的属性

/**
 *  用来获取相机设备的一些属性
 */
@property (nonatomic,strong)AVCaptureDevice *device;

/**
 *  用来执行输入设备和输出设备之间的数据交换
 */
@property(nonatomic,strong)AVCaptureSession * session;

/**
 *  输入设备，调用所有的输入硬件，例如摄像头、麦克风
 */
@property (nonatomic,strong)AVCaptureDeviceInput *deviceInput;
/**
 *  照片流输出，用于输出图像
 */

@property (nonatomic,strong)AVCaptureStillImageOutput *imageOutput;

/**
 *  镜头扑捉到的预览图层
 */
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation CCPTakePicturesController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self makeUI];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    if (self.session) {
        
        [self.session startRunning];
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
    if (self.session) {
        
        [self.session stopRunning];
    }
}

//UI界面布局及对象的初始化
- (void) makeUI {
    NSError *error;
    //创建会话层
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //初始化session
    self.session = [[AVCaptureSession alloc] init];
    //初始化输入设备
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    //初始化照片输出对象
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置,AVVideoCodecJPEG 输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.imageOutput setOutputSettings:outputSettings];
    //判断输入输出设备是否可用
    if ([self.session canAddInput:self.deviceInput]) {
        
        [self.session addInput:self.deviceInput];
        
    }
    
    if ([self.session canAddOutput:self.imageOutput]) {
        
        [self.session addOutput:self.imageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    //设置图层的显示样式
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //设置图层的frame
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height - 64;
    self.previewLayer.frame = CGRectMake(0, 0,viewWidth, viewHeight);
    [self.view.layer addSublayer:self.previewLayer];
    
}

@end

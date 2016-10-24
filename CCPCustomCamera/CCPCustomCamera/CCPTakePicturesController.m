//
//  CCPTakePicturesController.m
//  CCPCustomCamera
//
//  Created by C CP on 16/9/22.
//  Copyright © 2016年 C CP. All rights reserved.
//

#import "CCPTakePicturesController.h"

#import <AVFoundation/AVFoundation.h>
//处理相册的系统框架
#import <AssetsLibrary/AssetsLibrary.h>

#import "MotionOrientation.h"

typedef void(^lightBlock)();

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

/**
 *  session通过AVCaptureConnection连接AVCaptureStillImageOutput进行图片输出
 */

@property (nonatomic,strong) AVCaptureConnection *connection;

/**
 *  记录屏幕的旋转方向
 */
@property (nonatomic,assign) UIDeviceOrientation deviceOrientation;

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 *  最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;
/**
 *  闪光灯按钮
 */
@property(nonatomic,weak)UIButton *lightButton;
/**
 *  闪光灯状态
 */
@property (nonatomic,assign) NSInteger lightCameraState;


@end

@implementation CCPTakePicturesController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //判断相机 是否可以使用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        NSLog(@"sorry, no camera or camera is unavailable.");
        
        return;
    }
    
    //设置闪光灯的默认状态
    self.lightCameraState = 0;
    
    [[MotionOrientation sharedInstance] startAccelerometerUpdates];
    
    self.deviceOrientation = UIDeviceOrientationPortrait;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(motionDeviceOrientationChanged:) name:MotionOrientationChangedNotification object:nil];
    
    [self makeUI];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    //设置图层的frame
    CGFloat ScreenW = self.view.frame.size.width;
    CGFloat ScreenH = self.view.frame.size.height;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 40)];
    headView.backgroundColor = [UIColor blackColor];
    //返回按钮
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    backButton.backgroundColor = [UIColor redColor];
    
    [backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    
    [backButton setTintColor:[UIColor whiteColor]];
    
    [headView addSubview:backButton];
    
    //切换镜头按钮
    
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 0, 60, 40)];
    changeButton.backgroundColor = [UIColor greenColor];
    
    [changeButton addTarget:self action:@selector(clickchangeButton) forControlEvents:UIControlEventTouchUpInside];
    
    [changeButton setTitle:@"切换" forState:UIControlStateNormal];
    
    [changeButton setTintColor:[UIColor whiteColor]];
    
    [headView addSubview:changeButton];
    
    //闪光灯
    
    UIButton *lightButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 0, 80, 40)];
    lightButton.backgroundColor = [UIColor blueColor];
    
    [lightButton addTarget:self action:@selector(clickLightButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [lightButton setTitle:@"关闭" forState:UIControlStateNormal];
    
    [lightButton setTintColor:[UIColor whiteColor]];
    
    self.lightButton = lightButton;
    
    [headView addSubview:lightButton];
    
    [self.view addSubview:headView];
    
    NSError *error;
    //创建会话层
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //初始化session
    self.session = [[AVCaptureSession alloc] init];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
        
    }
    
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
    /** 设置图层的填充样式
     *  AVLayerVideoGravityResize,       // 非均匀模式。两个维度完全填充至整个视图区域
     AVLayerVideoGravityResizeAspect,  // 等比例填充，直到一个维度到达区域边界
     AVLayerVideoGravityResizeAspectFill, // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
     */
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.previewLayer.frame = CGRectMake(0, 40,ScreenW, (ScreenW * 4 / 3));
    [self.view.layer addSublayer:self.previewLayer];
    
    UIView *caramView = [[UIView alloc] initWithFrame:self.previewLayer.frame];
    caramView.backgroundColor = [UIColor redColor];
    caramView.alpha = 0.5f;
    [self.view addSubview:caramView];
    
    CGFloat previewLayerY = CGRectGetMaxY(self.previewLayer.frame);
    
    UIButton *button = [[UIButton alloc] init];
    
    [button setTitle:@"PHOTO" forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button setBackgroundColor:[UIColor purpleColor]];
    
    button.frame = CGRectMake(0, previewLayerY , ScreenW, ScreenH - previewLayerY);
    [button addTarget:self action:@selector(clickPHOTO) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void) clickBackButton {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) clickchangeButton {
    // 翻转
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    [UIView commitAnimations];
    
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            [self.session beginConfiguration];
            
            [self.session removeInput:input];
            [self.session addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration];
            break;
        }
    }
    
    
}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}


- (void) clickLightButton:(UIButton *)sender {
    
    if (self.lightCameraState < 0) {
        self.lightCameraState = 0;
    }
    self.lightCameraState ++;
    if (self.lightCameraState >= 4) {
        self.lightCameraState = 1;
    }
    AVCaptureFlashMode mode;
    
    switch (self.lightCameraState) {
        case 1:
            mode = AVCaptureFlashModeOn;
            [sender setTitle:@"打开" forState:UIControlStateNormal];
            break;
        case 2:
            mode = AVCaptureFlashModeAuto;
            [sender setTitle:@"自动" forState:UIControlStateNormal];
            break;
        case 3:
            mode = AVCaptureFlashModeOff;
            [sender setTitle:@"关闭" forState:UIControlStateNormal];
            break;
        default:
            mode = AVCaptureFlashModeOff;
            [sender setTitle:@"关闭" forState:UIControlStateNormal];
            break;
    }
    if ([self.device isFlashModeSupported:mode])
    {
        [self flashLightModel:^{
            
            [self.device setFlashMode:mode];
        }];
    }
}

- (void) flashLightModel:(lightBlock) lightBlock{
    if (!lightBlock) return;
    [self.session beginConfiguration];
    [self.device lockForConfiguration:nil];
    lightBlock();
    [self.device unlockForConfiguration];
    [self.session commitConfiguration];
    [self.session startRunning];
}

- (void)clickPHOTO {
    
    self.connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    /**
     *   UIDeviceOrientation 获取机器硬件的当前旋转方向
     需要注意的是如果手机手动锁定了屏幕，则不能判断旋转方向
     */
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    NSLog(@"-------%ld",(long)curDeviceOrientation);
    
    /**
     *  UIInterfaceOrientation 获取视图的当前旋转方向
     需要注意的是只有项目支持横竖屏切换才能监听到旋转方向
     */
    UIInterfaceOrientation sataus=[UIApplication sharedApplication].statusBarOrientation;
    NSLog(@"+++++++%ld",(long)sataus);
    
    /**
     *  为了实现在锁屏状态下能够获取屏幕的旋转方向，这里通过使用 CoreMotion 框架（加速计）进行屏幕方向的判断
     self.deviceOrientation = [MotionOrientation sharedInstance].deviceOrientation
     
     在这里用到了第三方开源框架 MotionOrientation 对作者表示衷心的感谢
     框架地址： GitHub:https://github.com/tastyone/MotionOrientation
     
     */
    NSLog(@"********%ld",(long)self.deviceOrientation);
    
    //获取输出视图的展示方向
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation: self.deviceOrientation];
    
    [self.connection setVideoOrientation:avcaptureOrientation];
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:self.connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        //原图
        UIImage *image = [UIImage imageWithData:jpegData];
        
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate);
        
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
            //无权限
            return ;
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
            
        }];
        
    }];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}


- (void)motionDeviceOrientationChanged:(NSNotification *)notification

{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.deviceOrientation = [MotionOrientation sharedInstance].deviceOrientation;
        
        NSLog(@"----------------%ld",(long)self.deviceOrientation);
        
    });
}





- (void)didClickButton:(UIImage *)img {
    
    // 1.先加载原图
    
    // 2.创建(开启)一个和原图一样大小的"位图上下文"
    
    //参数1 ->图形上下文的大小(单位是点)参数2 ->是否不透明参数3 ->一个点表示几个像素
    
    UIGraphicsBeginImageContextWithOptions(img.size,YES,0.0);
    
    // 3.获取刚才开启的图形上下文
    
    CGContextRef ctx =UIGraphicsGetCurrentContext();
    
    // 4.执行裁剪操作
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 40, img.size.width,img.size.height - 104)];
    
    CGContextAddPath(ctx, path.CGPath);
    
    CGContextClip(ctx);
    
    // 5.把图片绘制到上下文中
    
    [img drawAtPoint:CGPointZero];
    
    // 6.从上下文中获取裁剪好的图片对象
    
    UIImage*imgCliped =UIGraphicsGetImageFromCurrentImageContext();
    
    //    UIImageWriteToSavedPhotosAlbum(imgCliped, self, nil, NULL);
    
    // 6.2关闭位图上下文
    UIGraphicsEndImageContext();
    
}

- (UIImage *)getImageByCuttingImage:(UIImage *)image Rect:(CGRect)rect{
    
    //大图bigImage
    
    //定义myImageRect，截图的区域
    
    CGRect myImageRect = rect;
    
    UIImage* bigImage= image;
    
    CGImageRef imageRef = bigImage.CGImage;
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    
    CGSize size;
    
    size.width = rect.size.width;
    
    size.height = rect.size.height;
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, myImageRect, subImageRef);
    
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    
    //    UIImageWriteToSavedPhotosAlbum(smallImage, self, nil, NULL);
    
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}

//屏幕的截取
- (UIImage *)getSnapshotImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)), NO, 1);
    [self.view drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}
//设置当前页面支持横竖屏，DEMO默认不支持横竖屏
//-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

@end

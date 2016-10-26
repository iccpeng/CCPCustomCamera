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
#import "TOCropViewController.h"
#import "CCPCameraView.h"
#import "UIView+CCPExtension.h"

typedef void(^lightBlock)();

@interface CCPTakePicturesController ()<UIGestureRecognizerDelegate,AVCaptureMetadataOutputObjectsDelegate,TOCropViewControllerDelegate,CCPCameraViewDelegate>

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
/**
 *  遮照View
 */
@property (nonatomic,weak) CCPCameraView *caramView;
/**
 *  缩略图
 */
@property (nonatomic,weak) UIImageView *bottomImageView;
@end

@implementation CCPTakePicturesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    //默认开启截图功能
    self.isCanCut = YES;
    //判断相机 是否可以使用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        NSLog(@"sorry, no camera or camera is unavailable.");
        return;
    }
    
    //设置闪光灯的默认状态
    self.lightCameraState = 0;
    
    self.effectiveScale = self.beginGestureScale = 1.0f;
    
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
    //KVO 监听对焦回调
    [self.device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    
    if (self.session) {
        
        [self.session startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    //移除KVO
    [self.device removeObserver:self forKeyPath:@"adjustingFocus"];
    
    if (self.session) {
        
        [self.session stopRunning];
    }
}
#pragma mark -重写 isCanCut 的 setter 方法
- (void)setIsCanCut:(BOOL)isCanCut {
    _isCanCut = isCanCut;
}
#pragma mark -UI界面布局及对象的初始化
- (void) makeUI {
    //设置图层的frame
    CGFloat ScreenW = self.view.frame.size.width;
    CGFloat ScreenH = self.view.frame.size.height;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 40)];
    headView.backgroundColor = [UIColor blackColor];
    //返回按钮
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [headView addSubview:backButton];
    //切换镜头按钮
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenW - 60, 0, 60, 40)];
    [changeButton addTarget:self action:@selector(clickchangeButton) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setImage:[UIImage imageNamed:@"camera-switch"] forState:UIControlStateNormal];
    [headView addSubview:changeButton];
    //闪光灯
    UIButton *lightButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenW / 2 - 30, 0, 60, 40)];
    [lightButton addTarget:self action:@selector(clickLightButton:) forControlEvents:UIControlEventTouchUpInside];
    [lightButton setImage:[UIImage imageNamed:@"flashOffIcon"] forState:UIControlStateNormal];
    self.lightButton = lightButton;
    [headView addSubview:lightButton];
    [self.view addSubview:headView];
    
    //PreView
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
    self.previewLayer.frame = CGRectMake(0, 40,ScreenW, ScreenW * 4 / 3);
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    CGFloat previewLayerY = CGRectGetMaxY(self.previewLayer.frame);
    //遮照view
    CCPCameraView *caramView = [[CCPCameraView alloc] init];
    caramView.frame = self.previewLayer.frame;
    caramView.backgroundColor = [UIColor clearColor];
    caramView.delegate = self;
    self.caramView = caramView;
    //添加捏合手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [caramView addGestureRecognizer:pinch];
    [self.view addSubview:caramView];
    
    //bottomView
    CGRect rect = CGRectMake(0, previewLayerY , ScreenW, ScreenH - previewLayerY);
    UIView *bottomView = [[UIView alloc] initWithFrame:rect];
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"btn_prisma_takephoto"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 60, 60);
    button.centerX = bottomView.centerX;
    button.centerY = bottomView.height / 2;
    [button addTarget:self action:@selector(clickPHOTO) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, bottomView.height - 25, bottomView.height - 25)];
    imageView.centerY = bottomView.height / 2;
    imageView.backgroundColor = [UIColor redColor];
    [bottomView addSubview:imageView];
    self.bottomImageView = imageView;
}

#pragma mark -返回按钮
- (void) clickBackButton {
    CGFloat ScreenW = self.view.frame.size.width;
    self.previewLayer.frame =  CGRectMake(0, 40,ScreenW, ScreenW * 4 / 3);
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -镜头切换
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
            [self.session commitConfiguration];
            break;
        }
    }
}

#pragma mark -相机状态
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

#pragma mark - 闪光灯的状态
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
            
            [sender setImage:[UIImage imageNamed:@"flashOnIcon"] forState:UIControlStateNormal];
            
            break;
        case 2:
            mode = AVCaptureFlashModeAuto;
            [sender setImage:[UIImage imageNamed:@"flashAutoIcon"] forState:UIControlStateNormal];
            
            break;
        case 3:
            mode = AVCaptureFlashModeOff;
            
            [sender setImage:[UIImage imageNamed:@"flashOffIcon"] forState:UIControlStateNormal];
            break;
        default:
            mode = AVCaptureFlashModeOff;
            
            [sender setImage:[UIImage imageNamed:@"flashOffIcon"] forState:UIControlStateNormal];
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

#pragma mark -CCPCameraViewDelegate
- (void)cameraDidSelected:(CCPCameraView *)camera{
    [self.device lockForConfiguration:nil];
    [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
    [self.device setFocusPointOfInterest:CGPointMake(50,50)];
    //操作完成后，记得进行unlock。
    [self.device unlockForConfiguration];
}

#pragma mark -KVO,获取对焦回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        NSLog(@"对焦-----对焦----对焦");
    }
}
#pragma mark -拍照按钮
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
    
    [self.connection setVideoScaleAndCropFactor:self.effectiveScale];
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:self.connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        //原图
        UIImage *image = [UIImage imageWithData:jpegData];
        
#pragma mark - 图片的截取,通过对不同属性的设置获取目标的截图样式
        
        if (self.isCanCut) {
            
            TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:image];
            cropController.delegate = self;
            //隐藏比例选择按钮
            cropController.aspectRatioPickerButtonHidden = YES;
            //重置后缩小到当前设置的长宽比
            cropController.resetAspectRatioEnabled = NO;
            //截图的展示样式
            cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare;
            //是否可以手动拖动
            cropController.cropView.cropBoxResizeEnabled = NO;
            
            [self presentViewController:cropController animated:NO completion:nil];
        }
        
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
            //无权限
            return ;
        }
        
       UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
        
       self.bottomImageView.image = image;
        
//        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate);

//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
//            
//        }];
        
    }];
}

#pragma mark -图片方向
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

#pragma mark -加速计通知,监听手机方向
- (void)motionDeviceOrientationChanged:(NSNotification *)notification

{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.deviceOrientation = [MotionOrientation sharedInstance].deviceOrientation;
    });
}

#pragma mark -缩放手势
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.caramView];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer) {
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        CGFloat maxScaleAndCropFactor = [[self.imageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.0f];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
}

#pragma mark GestureRecognizer Delegate 缩放手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
}
    return YES;
}

# pragma mark -TOCropViewControllerDelegate 图片裁剪
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle{
    
    if (self.iconImage) {
        self.iconImage(image);
    }
    
    UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//设置当前页面支持横竖屏，DEMO默认不支持横竖屏
//-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

@end

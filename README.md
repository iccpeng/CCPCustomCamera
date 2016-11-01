# CCPCustomCamera

工作之余，研究了一下相机的自定义，在这里整理成篇仅供参考学习，希望可以给大家带来些许帮助，也期待大家的批评指正。
 
GIF 示例:
 
![ccpcamera.gif](http://upload-images.jianshu.io/upload_images/1764698-801f8a5ed322ab64.gif?imageMogr2/auto-orient/strip)

iOS开发中调用相机来获取照片时，如果对相机样式没有过多的要求，通常我们会调用UIImagePickerController这个系统封装好的控件。但是有时

UIImagePickerController无法满足项目的需求，例如我们需要自定义的相机样式，此时则需要自己构造一个相机控件，因此需要使用AVFoundation框架进行相机

的自定义。

首先导入 AVFoundation.framework 
```
#import <AVFoundation/AVFoundation.h>
```
####一、创建相机相关的属性
```
/**
 *  用来获取相机设备的一些属性
 */
@property (nonatomic,strong)AVCaptureDevice *device;

/**
 *  用来执行输入设备和输出设备之间的数据交换
 */
@property(nonatomic,strong)AVCaptureSession * session;

/**
 *  输入设备，调用所有的输入硬件，例如摄像头、麦克风
 */
@property (nonatomic,strong)AVCaptureDeviceInput *deviceInput;

/**
 *  照片流输出，用于输出图像
 */
@property (nonatomic,strong)AVCaptureStillImageOutput *imageOutput;

/**
 *  镜头扑捉到的预览图层
 */
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;

/**
 *  session通过AVCaptureConnection连接AVCaptureStillImageOutput进行图片输出
 */
@property (nonatomic,strong) AVCaptureConnection *connection;

#以下属性只是在本DEMO中有用到，大家可以按照自己项目的需求进行添加。
/**
 *  记录屏幕的旋转方向
 */
@property (nonatomic,assign) UIDeviceOrientation deviceOrientation;

/**
 *  给自定义相机添加（UIPinchGestureRecognizer）手势 ->记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;

/**
 *  记录最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;

/**
 *  自定义闪光灯功能 ->闪光灯按钮
 */
@property(nonatomic,weak)UIButton *lightButton;

/**
 *  闪光灯状态
 */
@property (nonatomic,assign) NSInteger lightCameraState;

/**
 *  遮照View,主要用来自定义相机界面的显示效果
 */
@property (nonatomic,weak) CCPCameraView *caramView;
```
####二、相机界面的布局

图片示意图

![ccpCa.png](http://upload-images.jianshu.io/upload_images/1764698-e3aa48775fdaae97.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

####三、主要功能介绍

1.拍照按钮

这里需要注意的是拍照完成后的照片显示的方向问题。

屏幕的方向大致可以分为以下6中：

home键盘朝下/home键朝右/home键朝上/home键朝左，还有两种就是屏幕朝上和屏幕朝下。因此需要根据不同屏幕方向进行照片的旋转，否则照片的显示将会出现问题，解决方法见下文介绍。

2.自定义截图功能

通过使用第三方截图框架(TOCropViewController)，实现自定义截图。

框架地址：[TOCropViewController](https://github.com/TimOliver/TOCropViewController)
```
 TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:image];
            cropController.delegate = self;
            //截图的展示样式
            cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare;
            //隐藏比例选择按钮
            cropController.aspectRatioPickerButtonHidden = YES;
            cropController.aspectRatioLockEnabled = YES;
            //重置后缩小到当前设置的长宽比
            cropController.resetAspectRatioEnabled = NO;
            
            //是否可以手动拖动
            cropController.cropView.cropBoxResizeEnabled = NO;
            
            [self presentViewController:cropController animated:NO completion:nil];

# pragma mark -TOCropViewControllerDelegate 图片裁剪
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle{

    UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];

}
```
3.聚焦功能

4.镜头切换与镜头缩放功能

5.闪光灯功能

####四、下一步将要完善的功能

1.图片浏览器功能；

2.图片的美化以及滤镜功能；

感谢您的阅读，期待您的 Star，如果在使用中您有任何问题，可以在 github issue,我会尽自己能力给您答复 。

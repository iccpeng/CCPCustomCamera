# CCPCustomCamera

工作之余，研究了一下相机与相册的自定义，在这里整理成篇仅供参考学习，希望可以给大家带来些许帮助，也期待大家的批评指正。

该demo最主要的目的是为了知识点的介绍与学习,不适用于直接使用到项目.
 
###相机的自定义
 
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

```
####二、相机界面的布局

图片示意图

![ccpCamera.png](http://upload-images.jianshu.io/upload_images/1764698-e3aa48775fdaae97.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

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

--------------------------------------------------------------------------------

###相册的自定义

GIF 示例:
![ccpCamera.png](http://upload-images.jianshu.io/upload_images/1764698-ab45e5fdeb6d2599.gif?imageMogr2/auto-orient/strip)

在 iOS 设备中，照片是相当重要的一部分。在 iOS8.0之前，开发者只能使用 AssetsLibrary 框架来访问设备的照片库。而在 iOS8 之后，苹果提供了一个名为   
PhotoKit 的框架，一个可以让应用更好地与设备照片库对接的框架.由于市面上有一部分应用还支持iOS7,同时为了更加全面的学习,在这里将整理AssetsLibrary 框架与 PhotoKit 框架的相关知识,供大家参考学习.



首先导入 AssetsLibrary.framework 

```
#import <AssetsLibrary/AssetsLibrary.h>
```
AssetsLibrary

####一、AssetsLibrary 基本介绍

AssetsLibrary: 代表整个设备中的资源库（照片库），通过 AssetsLibrary 可以获取和包括设备中的照片和视频

ALAssetsGroup: 映射照片库中的一个相册，通过 ALAssetsGroup 可以获取某个相册的信息，相册下的资源，同时也可以对某个相册添加资源。

ALAsset: 映射照片库中的一个照片或视频，通过 ALAsset 可以获取某个照片或视频的详细信息，或者保存照片和视频。

ALAssetRepresentation: ALAssetRepresentation 是对 ALAsset 的封装（但不是其子类），可以更方便地获取 ALAsset 中的资源信息，每个 ALAsset 都有至少有一个 ALAssetRepresentation 对象，可以通过 defaultRepresentation 获取。而例如使用系统相机应用拍摄的 RAW + JPEG 照片，则会有两个 ALAssetRepresentation，一个封装了照片的 RAW 信息，另一个则封装了照片的 JPEG 信息。

####二、PhotoKit 基本介绍

PhotoKit 是一套比 AssetsLibrary 更完整也更高效的库，对资源的处理跟 AssetsLibrary 也有很大的不同。

PhotoKit 基本构成的介绍：

PHAsset: 代表照片库中的一个资源，跟 ALAsset 类似，通过 PHAsset 可以获取和保存资源
PHFetchOptions: 获取资源时的参数，可以传 nil，即使用系统默认值
PHAssetCollection: PHCollection 的子类，表示一个相册或者一个时刻，或者是一个「智能相册（系统提供的特定的一系列相册，例如：最近删除，视频列表，收藏等等，如下图所示）
PHFetchResult: 表示一系列的资源结果集合，也可以是相册的集合，从?PHCollection 的类方法中获得
PHImageManager: 用于处理资源的加载，加载图片的过程带有缓存处理，可以通过传入一个 PHImageRequestOptions 控制资源的输出尺寸等规格
PHImageRequestOptions: 如上面所说，控制加载图片时的一系列参数

####三、主要功能

1.获取相册图片资源;

2.自定义相册功能;

3.图片浏览器功能;

本着不重复造轮子,demo中图片浏览器使用了 XLPhotoBrowser 

XLPhotoBrowser下载地址:[https://github.com/Shannoon/XLPhotoBrowser](https://github.com/Shannoon/XLPhotoBrowser)

在这里对框架作者表示感谢!

3.自定义相册图片展示

####四、参考:

a.[http://kayosite.com/ios-development-and-detail-of-photo-framework.html](http://kayosite.com/ios-development-and-detail-of-photo-framework.html)

b.[http://www.jianshu.com/p/535bfe3c328f](http://www.jianshu.com/p/535bfe3c328f)

c.[http://www.jianshu.com/p/cc85282fac5e]( http://www.jianshu.com/p/cc85282fac5e)

在这里对blog作者表示感谢!

####五、下一步将要完善的功能

图片的美化以及滤镜功能；

感谢您的阅读，期待您的 Star，如果在使用中您有任何问题，可以在 github issue,我会尽自己能力给您答复 。

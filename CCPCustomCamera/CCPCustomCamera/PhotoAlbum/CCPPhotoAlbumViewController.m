//
//  CCPPhotoAlbumViewController.m
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/14.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import "CCPPhotoAlbumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "CCPShowPhotoVC.h"

typedef void(^imageArrayBlock)(NSArray *imagesAssetArray);

@interface CCPPhotoAlbumViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;
//相册数组
@property (nonatomic,strong) NSMutableArray *assetsArray;

//@property (nonatomic,strong) NSMutableArray *assetArray2;
//相册名数组
@property (nonatomic,strong) NSMutableArray *nameArray;
//图片数组
@property (nonatomic,strong) NSMutableArray *imagesAssetArray;

@property (nonatomic,strong) UITableView *showTableView;
//封面图片数组
@property (nonatomic,strong) NSMutableArray *posterImageArray;

@property (nonatomic,copy) imageArrayBlock imageArrayBlock;

@end

@implementation CCPPhotoAlbumViewController

/*
 
 在 iOS 设备中，照片是相当重要的一部分。在 iOS8.0之前，开发者只能使用 AssetsLibrary 框架来访问设备的照片库。而在 iOS8 之后，苹果提供了一个名为 PhotoKit 的框架，一个可以让应用更好地与设备照片库对接的框架.
 由于市面上有一部分应用还支持iOS7,同时为了更加全面的学习,在此将整理AssetsLibrary 框架与 PhotoKit 框架的相关知识,供大家参考学习.
 
 参考:
 http://kayosite.com/ios-development-and-detail-of-photo-framework.html
 http://www.jianshu.com/p/535bfe3c328f
 http://www.jianshu.com/p/cc85282fac5e
 http://www.cnblogs.com/Jenaral/p/5580497.html
 在这里对原文作者表示感谢!
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
    
    if ([self iOSIsbefore_iOS8]) {
        [self iOSBefore_iOS8];
    } else {
        [self iOSAfter_iOS8];
    }
}

#pragma mark -tableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.assetsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.textLabel.text = self.nameArray[indexPath.row];
        
        cell.imageView.image =self.posterImageArray[indexPath.row];
        
    }
    
    return cell;
}

#pragma mark -tableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CCPShowPhotoVC *photoVC = [[CCPShowPhotoVC alloc] init];
    
    if ([self iOSIsbefore_iOS8]) {
        
        [self iOSSelectBefore_iOS8:indexPath.row];
        
        photoVC.imageArray = self.imagesAssetArray;
        photoVC.isIOS8 = YES;
        
    }else {
        
        photoVC.fetchResult = (PHFetchResult *)self.assetsArray[indexPath.row];
        photoVC.isIOS8 = NO;
    }
    
    [self presentViewController:photoVC animated:YES completion:nil];
}

#pragma mark -UI布局
- (void) makeUI {
    self.view.backgroundColor = [UIColor redColor];
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.assetsArray = [[NSMutableArray alloc] init];
    self.nameArray = [[NSMutableArray alloc] init];
    self.imagesAssetArray = [[NSMutableArray alloc] init];
    self.posterImageArray = [[NSMutableArray alloc] init];
    self.showTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 55)];
    self.showTableView.delegate = self;
    self.showTableView.dataSource = self;
    [self.view addSubview:self.showTableView];
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 55)];
    headView.backgroundColor = [UIColor orangeColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 60, 55)];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(clickTheBtn) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:button];
    [self.view addSubview:headView];
}
#pragma mark -系统版本判断
- (BOOL) iOSIsbefore_iOS8 {
    return [[[UIDevice currentDevice] systemVersion] floatValue] <= 8.0 ?1:0;
}

//系统版本小于8.0
- (void) iOSBefore_iOS8 {
    //提示
    NSString *tipTitle = nil;
    //相册的访问状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    /* 获取当前应用对照片的访问授权状态
     ALAuthorizationStatusNotDetermined = 0, // 用户还没有做出选择这个应用程序的问候
     ALAuthorizationStatusRestricted,        // 这个应用程序没有被授权访问照片数据。当前用户不能改变应用程序的状态，是受限制的。如家长控制权限
     ALAuthorizationStatusDenied,            // 用户已拒绝该应用程序访问照片数据
     ALAuthorizationStatusAuthorized         // 用户已授权该应用可以访问
     */
    
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *myAppName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
        tipTitle = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", myAppName];
    } else {
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                if (group.numberOfAssets > 0) {
                    // 把相册储存到数组中，方便后面展示相册时使用
                    [self.assetsArray addObject:group];
                    [self.nameArray addObject:[group valueForProperty:ALAssetsGroupPropertyName]];
                    //获取相册封面图
                    UIImage *posterImage =  [UIImage imageWithCGImage:[group posterImage]];
                    [self.posterImageArray addObject:posterImage];
                    
                }
                
            } else {
                
                if ([self.assetsArray count] > 0) {
                    // 把所有的相册储存完毕，可以展示相册列表
                } else {
                    // 没有任何有资源的相册，输出提示
                }
            }
            
            
        } failureBlock:^(NSError *error) {
            
            NSLog(@"Asset group not found!\n");
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.showTableView reloadData];
        });
        
    }
}

- (void) iOSSelectBefore_iOS8:(NSInteger)tag {
    
    /*
     //获取资源图片的详细资源信息
     ALAssetRepresentation* representation = [asset defaultRepresentation];
     //获取资源图片的长宽
     CGSize dimension = [representation dimensions];
     //获取资源图片的高清图
     [representation fullResolutionImage];
     //获取资源图片的全屏图
     [representation fullScreenImage];
     //获取资源图片的名字
     NSString* filename = [representation filename];
     NSLog(@"filename:%@",filename);
     //缩放倍数
     [representation scale];
     //图片资源容量大小
     [representation size];
     //图片资源原数据
     [representation metadata];
     //旋转方向
     [representation orientation];
     //资源图片url地址，该地址和ALAsset通过ALAssetPropertyAssetURL获取的url地址是一样的
     NSURL* url = [representation url];
     NSLog(@"url:%@",url);
     //资源图片uti，唯一标示符
     NSLog(@"uti:%@",[representation UTI]);
     */
    //清空数组
    [self.imagesAssetArray removeAllObjects];
    if (self.assetsArray.count > 0) {
        [self.assetsArray[tag] enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                // 获取资源图片的详细资源信息，其中 imageAsset 是某个资源的 ALAsset 对象
                ALAssetRepresentation *representation = [result defaultRepresentation];
                // 获取资源图片的 fullScreenImage
                UIImage *contentImage = [UIImage imageWithCGImage:[representation fullScreenImage]];
                [self.imagesAssetArray addObject:contentImage];
            } else {
                
            }
        }];
    }
}

//系统版本号大于等于8.0
- (void) iOSAfter_iOS8 {
    
    /*
     
     PHAssetCollectionTypeAlbum      自建相册
     PHAssetCollectionTypeSmartAlbum 智能相册
     PHAssetCollectionTypeMoment     时刻相册
     
     智能相册子类型
     PHAssetCollectionSubtypeSmartAlbumGeneric    通用的
     PHAssetCollectionSubtypeSmartAlbumPanoramas  全景
     PHAssetCollectionSubtypeSmartAlbumVideos     视屏
     PHAssetCollectionSubtypeSmartAlbumFavorites  收藏
     PHAssetCollectionSubtypeSmartAlbumTimelapses 延时视屏,也会在PHAssetCollectionSubtypeSmartAlbumVideos在出现
     PHAssetCollectionSubtypeSmartAlbumAllHidden  隐藏的
     PHAssetCollectionSubtypeSmartAlbumRecentlyAdded 最近添加
     PHAssetCollectionSubtypeSmartAlbumBursts    连拍
     PHAssetCollectionSubtypeSmartAlbumSlomoVideos Slomo是slow motion的缩写,高速摄影慢动作解析
     PHAssetCollectionSubtypeSmartAlbumUserLibrary 用户所有的资源
     PHAssetCollectionSubtypeSmartAlbumSelfPortraits 所有前置摄像头拍的照片和视屏
     PHAssetCollectionSubtypeSmartAlbumScreenshots 所有的截屏图
     
     */
    
    //权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        [self noticeAlerPhotos];
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                //排序方式
                option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
                // 列出所有相册智能相册
                PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                /* 列出所有用户创建的相册
                 PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
                 */
                
                /*
                 获取所有资源的集合，并按资源的创建时间排序
                 PHFetchOptions *options = [[PHFetchOptions alloc] init];
                 options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                 PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
                 */
                
                for (NSInteger i = 0; i < smartAlbums.count; i++) {
                    // 获取一个相册（PHAssetCollection）
                    PHCollection *collection = smartAlbums[i];
                    if ([collection isKindOfClass:[PHAssetCollection class]]) {
                        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                        // 从每一个智能相册中获取到的 PHFetchResult 中包含的才是真正的资源（PHAsset）
                        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                        
                        if (fetchResult.count > 0) {
                            
                            [self.assetsArray addObject:fetchResult];
                            
                            [self.nameArray addObject:assetCollection.localizedTitle];
                            
                            /*
                            获取封面图片,就是第一张图片
                            默认的是异步加载,这里选择了同步 因为只获取一张照片，不会对界面产生很大的影响
                            如果targetSize:PHImageManagerMaximumSize 则默认的返回原图,耗费很大的性能
                             */
                            PHAsset *asset = (PHAsset *)fetchResult.firstObject;
                            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                            options.synchronous = YES;
                            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
                             {
                                 [self.posterImageArray addObject:result];
                             }];
                        }
                    }else {
                        
                        NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
                    }
                }
                //在主线程更新UI界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.showTableView reloadData];
                });
            }
        }];
    }
}

- (void)noticeAlerPhotos{
    NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *alerString = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
    // 展示提示语
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"%@",alerString);
        
    });
}


- (void) clickTheBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

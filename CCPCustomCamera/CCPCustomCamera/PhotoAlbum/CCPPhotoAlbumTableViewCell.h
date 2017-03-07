//
//  CCPPhotoAlbumTableViewCell.h
//  CCPCustomCamera
//
//  Created by CCP on 2017/3/7.
//  Copyright © 2017年 CCP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCPPhotoAlbumTableViewCell : UITableViewCell
@property (nonatomic,strong) UIImage *coverImage;
@property (nonatomic,copy) NSString *coverString;
+ (instancetype)initWithTableview:(UITableView *)tableview;
@end

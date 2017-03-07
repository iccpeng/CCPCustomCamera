//
//  CCPPhotoAlbumTableViewCell.m
//  CCPCustomCamera
//
//  Created by CCP on 2017/3/7.
//  Copyright © 2017年 CCP. All rights reserved.
//

#import "CCPPhotoAlbumTableViewCell.h"

@interface CCPPhotoAlbumTableViewCell ()
@property (nonatomic,weak) UIImageView *coverImageView;
@property (nonatomic,weak) UILabel *coverLabel;

@end
@implementation CCPPhotoAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (instancetype)initWithTableview:(UITableView *)tableview {
    
    static NSString *coverCell = @"coverCell";
    
    CCPPhotoAlbumTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:coverCell];
    
    if (cell == nil) {
        cell = [[CCPPhotoAlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:coverCell];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpUI];
    }
    return self;
}

- (void) setUpUI {
    UIImageView *coverImageView = [[UIImageView alloc] init];
    coverImageView.frame = CGRectMake(8, 0, 80, 80);
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    coverImageView.clipsToBounds = YES;
    [self.contentView addSubview:coverImageView];
    self.coverImageView = coverImageView;
    UILabel *coverLabel = [[UILabel alloc] init];
    coverLabel.frame = CGRectMake(96, 0, 150, 80);
    [self.contentView addSubview:coverLabel];
    self.coverLabel = coverLabel;
}

- (void)setCoverImage:(UIImage *)coverImage {
    _coverImage = coverImage;
    self.coverImageView.image = coverImage;
}
- (void)setCoverString:(NSString *)coverString {
    _coverString = coverString;
    self.coverLabel.text = coverString;
}

@end

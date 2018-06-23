//
//  TableViewCell.m
//  HLDownloadDemo
//
//  Created by LiHongli on 2018/6/22.
//  Copyright © 2018年 HL. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.textLabel.numberOfLines = 0;
        self.textLabel.font = [UIFont systemFontOfSize:17];

        self.detailTextLabel.textColor = [UIColor redColor];
    }
    return self;
}

- (void)setObject:(HLDownLoader *)object{
    _object = object;
    object.delegate = self;
    self.textLabel.text = object.m3u8url.absoluteString;
}

-(void)downloaderFinished:(HLDownLoader *)download{
    
}

-(void)downloaderFailed:(HLDownLoader *)download{
    
}

-(void)downloader:(HLDownLoader *)download Progress:(double)progess{
    NSString *str = [NSString stringWithFormat:@"%0.1f%%",progess*100];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.detailTextLabel.text = str;
    });
}


@end

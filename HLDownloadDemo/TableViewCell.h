//
//  TableViewCell.h
//  HLDownloadDemo
//
//  Created by LiHongli on 2018/6/22.
//  Copyright © 2018年 HL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HLDownload/HLDownload.h>

@interface TableViewCell : UITableViewCell<HLDownloadDelegate>

@property (nonatomic, strong) HLDownLoader *object;

@end

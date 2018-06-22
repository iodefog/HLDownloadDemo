//
//  HLDownLoader.h
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLM3U8List.h"
#import "HLSegmentDownLoader.h"

@interface HLDownLoader : NSObject<HLSegmentDownloadDelegate>

@property(nonatomic, weak) id <HLDownloadDelegate> delegate;
@property(nonatomic, strong) HLM3U8List *playlist;
@property(nonatomic, strong) NSURL      *m3u8url;

// 当前写入大小
@property(nonatomic, assign) double writtenSize;
// 总大小
@property(nonatomic, assign) double totalSize;
// 当前总写入大小
@property (nonatomic, assign) double totalWrittenSize;
// 整体进度
@property(nonatomic, assign) double progress;
@property(nonatomic, assign) BOOL isDownloading;
/**
 *  分段下载器数组
 */
@property (nonatomic, strong) NSMutableArray *downloadArray;
/**
 *  每个视频的目录
 */
@property (nonatomic, copy) NSString *filePath;


-(instancetype)initWithHLM3U8List:(HLM3U8List *)list;

/**
 * 创建本地m3u8索引
 */
-(NSString*)createLocalM3U8file;




/**
 *  开始下载
 */
- (void)startDownload;

/**
 *  继续下载
 */
-(void)resumeDownload;

/**
 *  暂停下载
 */
- (void)suspendDownload;

/**
 *  取消下载
 */
- (void)cancelDownload;

@end

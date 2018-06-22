//
//  HLDownloaderCenter.m
//  HLDownload
//
//  Created by LHL on 2018/6/22.
//  Copyright © 2018 HL. All rights reserved.
//

#import "HLDownloaderCenter.h"
#import "HLDownLoader.h"
#import "HLM3U8Praser.h"

@interface HLDownloaderCenter()

@property(nonatomic, strong) NSMutableArray *downloadsArray;
@property(nonatomic, strong) dispatch_queue_t m3u8RequestQueue;

@end

@implementation HLDownloaderCenter

static id manager = nil;
+ (instancetype)shareInstanced{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[[self class] alloc] init];
        }
    });
    return manager;
}

- (instancetype)init{
    if (self = [super init]) {
        self.m3u8RequestQueue = dispatch_queue_create("com.lhl.m3u8RequestQueue", NULL);
        self.downloadsArray = [NSMutableArray array];
    }
    return self;
}

- (void)downloadWithM3u8URL:(NSURL *)url{
    dispatch_async(self.m3u8RequestQueue, ^{
        HLM3U8Praser *m3u8Praser = [[HLM3U8Praser alloc] init];
        [m3u8Praser praseM3u8Url:url praserBlock:^(NSURL *m3u8URL ,HLM3U8List *segmentList) {
            HLDownLoader *downloader = [[HLDownLoader alloc] initWithHLM3U8List:segmentList];
            downloader.m3u8url = m3u8URL;
//            downloader.delegate = self;
            [downloader startDownload];
            [self.downloadsArray addObject:downloader];
        }];
    });
}

- (void)startAll{
    [self.downloadsArray enumerateObjectsUsingBlock:^(HLDownLoader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj startDownload];
    }];
}

- (void)pauseAll{
    [self.downloadsArray enumerateObjectsUsingBlock:^(HLDownLoader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj suspendDownload];
    }];
}

- (void)resumeAll{
    [self.downloadsArray enumerateObjectsUsingBlock:^(HLDownLoader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj resumeDownload];
    }];
}

- (void)cancelAll{
    [self.downloadsArray enumerateObjectsUsingBlock:^(HLDownLoader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancelDownload];
    }];
}

- (void)removeItem:(HLDownLoader *)downloader{
    if (downloader) {
        if (downloader.isDownloading) {
            [downloader cancelDownload];
        }
        [self.downloadsArray removeObject:downloader];
    }
}

- (void)removeItemIndex:(NSInteger)index{
    if (index < self.downloadsArray.count) {
        [self removeItem:self.downloadsArray[index]];
    }
}




@end

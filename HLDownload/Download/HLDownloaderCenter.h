//
//  HLDownloaderCenter.h
//  HLDownload
//
//  Created by LHL on 2018/6/22.
//  Copyright © 2018 HL. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HLDownLoader;

@interface HLDownloaderCenter : NSObject

+ (instancetype)shareInstanced;

- (void)downloadWithM3u8URL:(NSURL *)url;


- (void)startAll;
- (void)pauseAll;
- (void)resumeAll;
- (void)cancelAll;


- (void)removeItem:(HLDownLoader *)downloader;
- (void)removeItemIndex:(NSInteger)index;

@end

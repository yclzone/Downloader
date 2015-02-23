//
//  MultiThreadDownloader.h
//  02.23-Downloader
//
//  Created by Chenglin Yu on 2/23/15.
//  Copyright (c) 2015 yclzone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultiThreadDownloader : NSObject
/** sourceURL */
@property (copy, nonatomic) NSString *sourceURL;
/** destinationPath */
@property (copy, nonatomic) NSString *destinationPath;
/** progressHandle */
@property (copy, nonatomic) void (^progressHandle)(double progress);
/** completeHandle */
@property (copy, nonatomic) void (^completeHandle)();
/** downloading */
@property (assign, nonatomic, getter=isDownloading) BOOL downloading;

- (void)start;
- (void)pause;
@end

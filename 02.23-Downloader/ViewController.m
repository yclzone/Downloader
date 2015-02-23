//
//  ViewController.m
//  02.23-Downloader
//
//  Created by Chenglin Yu on 2/23/15.
//  Copyright (c) 2015 yclzone. All rights reserved.
//

#import "ViewController.h"
#import "MultiThreadDownloader.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
/** downloader */
@property (strong, nonatomic) MultiThreadDownloader *downloader;
@end

@implementation ViewController

- (MultiThreadDownloader *)downloader {
  if (!_downloader) {
    _downloader = [[MultiThreadDownloader alloc] init];
    _downloader.sourceURL = @"http://cdimage.ubuntu.com/releases/14.04.2/release/ubuntu-14.04-server-powerpc.iso.zsync";
    _downloader.destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"file.d"];
  }
  return _downloader;
}

- (IBAction)download:(UIButton *)sender {
  if (!self.downloader.isDownloading) {
    // 默认为 NO
    [sender setTitle:@"暂停" forState:UIControlStateNormal];
    [self.downloader start];
    
    __weak typeof(self) weakSelf = self;
    self.downloader.progressHandle = ^(double progress) {
      weakSelf.progressView.progress = progress;
    };
    self.downloader.completeHandle = ^ {
      [sender setTitle:@"下载完成" forState:UIControlStateNormal];
      weakSelf.downloader = nil;
    };
  } else {
    [sender setTitle:@"开始" forState:UIControlStateNormal];
    [self.downloader pause];
  }
}
@end

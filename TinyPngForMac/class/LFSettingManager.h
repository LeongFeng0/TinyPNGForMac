//
//  LFSettingManager.h
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/25.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LFSettingManager : NSObject
@property (nonatomic, assign) NSInteger tasksCount;
@property (nonatomic, assign) float allTasksOfSize;
@property (nonatomic, assign) float compressionOfSize;
+ (instancetype)share;
-(void)setAPIKey:(NSString *)key;
-(NSString *)getAPIKey;
-(void)setSaveImagePath:(NSString *)path;
-(NSString *)getSaveImagePath;
-(void)getDownloadDirectorySecurityScoped;
-(void)saveBookmarkDataToUserDefaultWithURL:(NSURL *)url;
-(void)saveCompressionCount:(NSString *)count;
-(NSString *)getCompressionCount;
@end

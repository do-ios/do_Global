//
//  do_Global_IMethod.h
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol do_Global_ISM <NSObject>

//实现同步或异步方法，parms中包含了所需用的属性
@required
- (void)exit:(NSArray *)parms;
- (void)getFromPasteboard:(NSArray *)parms;
- (void)getMemory:(NSArray *)parms;
//- (void)getSignatureInfo:(NSArray *)parms;
- (void)getTime:(NSArray *)parms;
- (void)getVersion:(NSArray *)parms;
- (void)getWakeupID:(NSArray *)parms;
- (void)install:(NSArray *)parms;
- (void)setMemory:(NSArray *)parms;
- (void)setToPasteboard:(NSArray *)parms;

@end
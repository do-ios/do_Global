//
//  do_Global_App.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Global_App.h"
static do_Global_App* instance;
@implementation do_Global_App
@synthesize OpenURLScheme;
+(id) Instance
{
    if(instance==nil)
        instance = [[do_Global_App alloc]init];
    return instance;
}
@end

//
//  do_Global_SM.h
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Global_ISM.h"
#import "doSingletonModule.h"
#import "doIGlobal.h"

@interface do_Global_SM : doSingletonModule<do_Global_ISM,doIGlobal>

@end
//
//  do_Global_SM.m
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Global_SM.h"

#import "doScriptEngineHelper.h"
#import "doServiceContainer.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"

#import "doIApp.h"
#import "doIOHelper.h"
#import "doJsonHelper.h"
#import <UIKit/UIKit.h>

@implementation do_Global_SM
{
    NSMutableDictionary * dictApps;
    NSMutableDictionary * dictMemCache;
}
@synthesize ScreenHeight = _ScreenHeight;
@synthesize ScreenWidth = _ScreenWidth;
@synthesize DesignScreenHeight = _DesignScreenHeight;
@synthesize DesignScreenWidth = _DesignScreenWidth;
@synthesize OSType = _OSType;
@synthesize OSVersion = _OSVersion;
@synthesize MainAppID = _MainAppID;
@synthesize ScriptType = _ScriptType;
@synthesize LaunchType;
@synthesize LaunchData;
@synthesize DataRootPath;
@synthesize SourceRootPath;
@synthesize InitDataRootPath = _InitDataRootPath;
@synthesize MappingSourceRootPath = _MappingSourceRootPath;

- (id)init{
    self = [super init];
    if(self)
    {
        dictApps = [[NSMutableDictionary alloc]init];
        dictMemCache = [[NSMutableDictionary alloc]init];
    }
    
    return self;
    
}

#pragma mark - 方法
#pragma mark - 同步异步方法的实现
//同步
- (void)Dispose{
    if (dictApps != nil) {
        for(NSString* _key in [dictApps allKeys] )
        {
            [dictApps[_key] Dispose];
        }
        [dictApps removeAllObjects];
        dictApps = nil;
    }
    if (dictMemCache != nil)
    {
        [dictMemCache removeAllObjects];
        dictMemCache = nil;
    }
}

- (id<doIApp>)GetAppByID:(NSString *)_appID{
    if (dictApps == nil) {
        return nil;
    }
    if (![dictApps objectForKey:_appID]) {
        NSString * _appRootPath = [NSString stringWithFormat:@"%@/%@",self.SourceRootPath,_appID];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if (![fileMgr fileExistsAtPath:_appRootPath]) {
            return nil;
        }
        id<doIApp> _app = [doServiceContainer Instance].App;
        [_app LoadApp:_appID];
        [dictApps setObject:_app forKey:_appID];
        [_app LoadScripts];
    }
    return [dictApps objectForKey:_appID];
}
- (void)CloseApp:(NSString *)_appID{
    if (dictApps == nil) {
        return;
    }
    if (![dictApps objectForKey:_appID]) {
        return;
    }
    [dictApps[_appID] Dispose];
    [dictApps removeObjectForKey:_appID];
    
}
- (void) ClearAllApps
{
    if (dictApps == nil) return;
    [dictApps removeAllObjects];
}
- (id<doIApp>)GetAppByAddress:(NSString *)_key{
    return nil;
}
- (void)LoadConfig:(NSString *)_configFileName{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:_configFileName]) {
        @throw [[NSException alloc] initWithName:@"doGlobal" reason:@"不存在启动配置文件!" userInfo:nil];
    }
    NSString * _configContent = [doIOHelper ReadUTF8File:_configFileName];
    id  _jsonParaValue = [doJsonHelper LoadDataFromText :_configContent];
    
    NSDictionary * _jsonPara = [doJsonHelper GetOneNode: _jsonParaValue :@"Base"];
    _MainAppID = [doJsonHelper GetOneText: _jsonPara: @"AppID" :nil];
    NSDictionary * _jsonParaScreen = [doJsonHelper GetOneNode: _jsonParaValue :@"DesignEnvironment"];
    _DesignScreenHeight = [doJsonHelper GetOneFloat:_jsonParaScreen :@"ScreenHeight" :1334];
    _DesignScreenWidth = [doJsonHelper GetOneFloat:_jsonParaScreen :@"ScreenWidth" :750];
    NSString* temp =[doJsonHelper GetOneText: _jsonPara: @"ScriptType" :@"javascript"];
    if ([@"lua" isEqualToString:temp]) {
        _ScriptType = @".lua";
    } else {
        _ScriptType = @".js";
    }
    if (_MainAppID == nil || _MainAppID.length <= 0)
        @throw [[NSException alloc] initWithName:@"启动配置文件中未设置主应用ID!" reason:nil userInfo:nil];
    
}

#pragma mark -
#pragma mark - private
//获取当前设备时间 同步
- (void) getTime:(NSArray*) parms
{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    //    id<doIScriptEngine> _scriptEngine =[parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSString* _format = [doJsonHelper GetOneText:_dictParas :@"format" :@"" ];
    if([_format stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        [_invokeResult SetResultText:[NSString stringWithFormat:@"%lld",(long long)([NSDate date].timeIntervalSince1970 *1000)]];
        return;
    }else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:_format];
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
        [_invokeResult SetResultText:currentDateStr];
    }
}
//获取整个应用唤醒id 同步
- (void) getWakeupID:(NSArray*) parms
{
    //    NSDictionary * _dictParas =[parms objectAtIndex:0];
    //    id<doIScriptEngine> _scriptEngine =[parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSArray *array = [infoDictionary objectForKey:@"CFBundleURLTypes"];
    NSDictionary *wakeupid  =[array objectAtIndex:0];
    NSArray *wakeidArr  = [wakeupid objectForKey:@"CFBundleURLSchemes"];
    NSString *Relwakeupid = [wakeidArr objectAtIndex:0];
    [_invokeResult SetResultText:Relwakeupid];
}
//获取整个应用程序原生安装包的版本号 同步
- (void) getVersion:(NSArray*) parms
{
    //    NSDictionary * _dictParas =[parms objectAtIndex:0];
    //    id<doIScriptEngine> _scriptEngine =[parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSMutableDictionary *jsNode = [[NSMutableDictionary alloc] init];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [jsNode setObject:version forKey:@"ver"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    [jsNode setObject:app_build forKey:@"code"];
    [_invokeResult SetResultNode:jsNode];
}

//获取全局的内存变量值 同步
- (void) getMemory:(NSArray*) parms
{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    //    id<doIScriptEngine> _scriptEngine =[parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSString* _key = [doJsonHelper GetOneText:_dictParas :@"key" :@"" ];
    if ([[dictMemCache allKeys] containsObject:_key])
    {
        [_invokeResult SetResultText:dictMemCache[_key]];
    }
    else
    {
        [_invokeResult SetResultText:@""];
    }
}
//设置全局的内存变量值 同步
- (void) setMemory:(NSArray*) parms

{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    //    id<doIScriptEngine> _scriptEngine =[parms objectAtIndex:1];
    //    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSString* _key = [doJsonHelper GetOneText:_dictParas :@"key" :@"" ];
    NSString* _value = [doJsonHelper GetOneText:_dictParas :@"value" : @""];
    dictMemCache[_key] = _value;
}

- (void) install:(NSArray *) parms
{
}
- (void) exit:(NSArray*) parms
{
    //有可能以下代码会被AppStore拒
    NSLog(@"exit(0)");
    exit(0);
}

//复制到剪切板
- (void)setToPasteboard:(NSArray*) parms
{
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    
    NSDictionary * dict = [parms objectAtIndex:0];
    NSString *content = [doJsonHelper GetOneText:dict :@"data" :@""];
    if (content == 0) {
        [_invokeResult SetResultBoolean:NO];
        return;
    }
    UIPasteboard * pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:content];
    [_invokeResult SetResultBoolean:YES];
}
//读取剪切板
- (void)getFromPasteboard:(NSArray*) parms
{
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    
    UIPasteboard * pasteBoard = [UIPasteboard generalPasteboard];
    NSString * content = [pasteBoard string];
    [_invokeResult SetResultText:content];
}
@end
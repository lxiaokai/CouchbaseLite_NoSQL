//
//  DatabaseSetupUtil.m
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "DatabaseSetupUtil.h"
#import "DBManager.h"

#define AppSetupDatabaseName @"sq580doctor"
#define DBInitStatusKey @"SQ580DoctorDBInitStatusKey"

@implementation DatabaseSetupUtil

/**
 *  数据库是否已经初始化
 *
 */
+ (BOOL)isDatabaseInit {
    return [self getDBInitStatus];
}



/**
 *  获取数据库存放路径
 *
 */
+ (NSString*)getDatabaseSavePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [paths objectAtIndex:0];
    return dbPath;
}


/**
 *  数据库打开或者创建方法
 *
 */
+ (BOOL)databaseOpenOrCreate {
    if (![NSThread isMainThread]) {
        __block BOOL ret = NO;
        __block BOOL isOK = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            ret = [self databaseOpenOrCreate];
            isOK = YES;
        });
        while (!isOK) {
            [NSThread sleepForTimeInterval:0.5];
        }
        return ret;
    }
    
    BOOL result = [[DBManager shareInstance] openDBWithPath:[DatabaseSetupUtil getDatabaseSavePath] name:AppSetupDatabaseName];
    if (result) {
        if (![self getDBInitStatus]) {
            [self setDBInitStatus:YES];
        }
    }
    return result;
}


/**
 *  数据库重新初始化方法
 *
 */
+ (BOOL)databaseReInit {
    if (![NSThread isMainThread]) {
        __block BOOL ret = NO;
        __block BOOL isOK = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            ret = [self databaseReInit];
            isOK = YES;
        });
        while (!isOK) {
            [NSThread sleepForTimeInterval:0.5];
        }
        return ret;
    }
    
    //    BOOL result = [DBModelSystemMessage deleteAllWithUserID:[AppDelegate getInstance].currentLoginUserID];
    //    if (!result) {
    //        return NO;
    //    }
    
    return YES;
}

/**
 *  设置数据库初始化状态
 *
 *  @param value 当前数据库初始化状态
 */
+ (void)setDBInitStatus:(BOOL)value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:DBInitStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/**
 *  获取当前数据库初始化状态
 *
 *  @return 当前数据库初始化状态
 */
+ (BOOL)getDBInitStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:DBInitStatusKey];
}

@end

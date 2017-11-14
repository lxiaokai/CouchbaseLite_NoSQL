//
//  DatabaseSetupUtil.h
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  数据库设置
 *  作用：
 *  负责数据库设置有关的工作，例如创建数据库、打开数据库、重新初始化数据库等
 *  历史：
 *  1.2017年11月14日：新创建。
 */
@interface DatabaseSetupUtil : NSObject

/**
 *  数据库打开或者创建方法
 *
 */
+ (BOOL)databaseOpenOrCreate;

/**
 *  数据库重新初始化方法(未完全实现)
 *
 */
+ (BOOL)databaseReInit;

@end

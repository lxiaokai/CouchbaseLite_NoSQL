//
//  DBManager.h
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CouchbaseLite/CouchbaseLite.h"
#import "CouchbaseLite/CBLDocument.h"

#define NoSqlDBQueueName @"NoSqlDBQueue"  //名字
static const void * const kNoSqlDispatchQueueSpecificKey = &kNoSqlDispatchQueueSpecificKey;

/**
 CouchbaseLite数据库的CRUD操作
 */
@interface DBManager : NSObject

/* 数据库 */
@property(strong,nonatomic,readonly) CBLDatabase*
database;

/* 是否启用数据库加密，默认不启用 */
@property(nonatomic) BOOL encrypt;

/**
 *  获取单例管理器对象
 */
+ (DBManager*)shareInstance;

/**
 *  根据数据库存放的路径以及数据库名字创建数据库
 * 参数 path ：数据库存放的路径
 * 参数 name ：数据库存放的路径
 * 返回值 ：如果创建成功或者指定的路径已经存在指定名字的数据库则返回YES,否则返回NO
 */
-(BOOL)createDBWithPath:(NSString*)path  name:(NSString*)name;

/**
 *  根据数据库存放的路径以及数据库名字打开数据库
 * 参数 path ：数据库存放的路径
 * 参数 name ：数据库存放的路径
 * 返回值 ：如果打开成功返回YES,否则返回NO
 */
-(BOOL)openDBWithPath:(NSString*)path  name:(NSString*)name;

/**
 *  删除数据库(必须先打开数据库才能执行删除操作)
 * 参数 path ：数据库存放的路径
 * 参数 name ：数据库存放的路径
 * 返回值 ：如果如果成功或者不存在指定的路径指定名字的数据库则返回YES,否则返回NO
 */
-(BOOL)deleteDB;

/**
 *  执行事务性操作
 * 参数 block ：事务block,一旦该block返回No即会执行回滚操作，返回Yes表示事务执行完成
 * 返回值 ：如果成功则返回YES,否则返回NO
 */
- (BOOL)inTransaction: (BOOL(^)(void))block;

/**
 *  执行事务性操作(异步模式)
 * 参数 block ：事务block,一旦该block返回No即会执行回滚操作，返回Yes表示事务执行完成
 * 参数 competition ：完成回调block ，如果成功则返回YES,否则返回NO
 */
- (void)inTransaction: (BOOL(^)(void))block competition:(void (^)(BOOL result))competition;


@end

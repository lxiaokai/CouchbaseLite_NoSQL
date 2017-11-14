//
//  DBManager.m
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "DBManager.h"
#import "SingleJobQueue.h"

#define NoSqlDBCryptoSecureKeyName @"NoSqlDBCryptoSecureKey"

@interface DBManager () {
    CBLManager* _manager;  //数据库管理器
}
@end

@implementation DBManager

/**
 *  获取单例对象
 */
+ (DBManager*)shareInstance {
    static DBManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.encrypt = NO;
    });
    return sharedInstance;
}

/**
 *  生成数据库加密密钥
 * 返回值 ：如果成功则返回256位密钥数据,否则返回nil
 */
- (NSData*)generateCryptoSecureKey {
    unsigned char bytes[32];
    int result = SecRandomCopyBytes(kSecRandomDefault, 32, bytes);
    if (result != noErr) {
        return nil;
    }
    return [NSData dataWithBytes:bytes length:32];
}

/**
 *  获取数据库加密密钥
 * 返回值 ：如果成功则返回256位密钥数据,否则返回nil
 */
-(NSData*)getCryptoSecureKey {
    NSData* key = nil;
    
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:NoSqlDBCryptoSecureKeyName];
    if (data == nil) {
        key = [self generateCryptoSecureKey];
        if (key) {
            [[NSUserDefaults standardUserDefaults] setObject:key forKey:NoSqlDBCryptoSecureKeyName];
            data = [[NSUserDefaults standardUserDefaults] objectForKey:NoSqlDBCryptoSecureKeyName];
            if (data == nil) {
                key = nil;
            }
        }
    }
    else {
        key = data;
    }
    
    return key;
}

/**
 *  根据数据库存放的路径以及数据库名字创建数据库
 * 参数 path ：数据库存放的路径
 * 参数 name ：数据库存放的路径
 * 返回值 ：如果创建成功或者指定的路径已经存在指定名字的数据库则返回YES,否则返回NO
 */
-(BOOL)createDBWithPath:(NSString*)path  name:(NSString*)name {
    __block BOOL ret = NO;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        // 创建一个数据库的名称,并确保名称是合法的
        if (![CBLManager isValidDatabaseName: name]) {
            NSLog (@"数据库的名称不合法");
            ret = NO;
        }
        
        ret = [self openDBWithPath:path name:name];
    }];
    return ret;
}

/**
 *  根据数据库存放的路径以及数据库名字打开数据库
 * 参数 path ：数据库存放的路径
 * 参数 name ：数据库存放的路径
 * 返回值 ：如果打开成功返回YES,否则返回NO
 */
-(BOOL)openDBWithPath:(NSString*)path  name:(NSString*)name {
    __block BOOL ret = NO;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        NSError *error;
        CBLDatabaseOptions* dbOptions = nil;
        dbOptions = [[CBLDatabaseOptions alloc] init];
        dbOptions.create = YES;
        dbOptions.storageType = kCBLSQLiteStorage;
        
        if (self.encrypt) {
            //需要加密
            NSData* key = [self getCryptoSecureKey];
            if (key) {
                dbOptions.encryptionKey = key;
            }
        }
        _manager = [[CBLManager sharedInstance] initWithDirectory:path options:nil error:nil];
        _database = [_manager openDatabaseNamed:name withOptions:dbOptions error:&error];
        
        ret = _database != nil;
    }];
    return ret;
}


/**
 *  删除数据库(必须先打开数据库才能执行删除操作)
 * 返回值 ：如果如果成功或者不存在指定的路径指定名字的数据库则返回YES,否则返回NO
 */
-(BOOL)deleteDB {
    __block BOOL ret = NO;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        NSError *error;
        [_database close:&error];
        ret = [_database deleteDatabase:&error];
    }];
    return ret;
}


/**
 *  执行事务性操作
 * 参数 block ：事务block,一旦该block返回No即会执行回滚操作，返回Yes表示事务执行完成
 * 返回值 ：如果成功则返回YES,否则返回NO
 */
- (BOOL)inTransaction: (BOOL(^)(void))block {
    __block BOOL ret = NO;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        ret = [_database inTransaction:block];
    }];
    return ret;
    
}

/**
 *  执行事务性操作(异步模式)
 * 参数 block ：事务block,一旦该block返回No即会执行回滚操作，返回Yes表示事务执行完成
 * 参数 competition ：完成回调block ，如果成功则返回YES,否则返回NO
 */
- (void)inTransaction: (BOOL(^)(void))block competition:(void (^)(BOOL result))competition {
    __block BOOL ret = NO;
    [[SingleJobQueue shareInstance] runAsyncJobWithJobBlock:^{
        ret = [_database inTransaction:block];
    } competition:^{
        if (competition) {
            competition(ret);
        }
    }];
}


@end

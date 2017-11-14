//
//  DBModelBase.m
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "DBModelBase.h"
#import <objc/message.h>
#import "SingleJobQueue.h"

@implementation DBModelBase

/**
 *  根据指定的实体对象创建一个文档
 * 参数 model ：继承自实体基类的具体实体实例
 * 返回值 ：如果创建成功则返回文档id,否则返回nil
 */
+(NSString*)createDocument:(id)model {
    __block NSString* ret = nil;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        ret = [self createDocumentForTransaction:model];
    }];
    return ret;
}

/**
 *  根据指定的实体对象创建一个文档
 * 参数 model ：继承自实体基类的具体实体实例
 * 参数 competition ：完成回调block ，如果创建成功则返回文档id,否则返回nil
 */
+(void)createDocument:(id)model competition:(void (^)(NSString* docId))competition {
    __block NSString* ret = nil;
    [[SingleJobQueue shareInstance] runAsyncJobWithJobBlock:^{
        ret = [self createDocumentForTransaction:model];
    } competition:^{
        if (competition) {
            competition(ret);
        }
    }];
}

/**
 *  根据指定的实体对象创建一个文档(适合于在事务中执行)
 * 参数 model ：继承自实体基类的具体实体实例
 * 返回值 ：如果创建成功则返回文档id,否则返回nil
 */
+(NSString*)createDocumentForTransaction:(id)model {
    NSError *error;
    // 创建一个文档
    
    CBLDocument*  doc = [[DBManager shareInstance].database createDocument];

    // 向数据库写入文档
    CBLRevision *listRevision = [doc putProperties:[model toDictionary] error: &error];
    if (!listRevision) {
        NSLog (@"不能写入文档到数据库. 错误信息: %@", error.localizedDescription);
        return nil;
    }
    else {
        NSLog (@"成功写入文档到数据库");
    }
    
    return doc.documentID;
}

/**
 *  删除指定id的文档
 * 参数 documentId ：文档id
 * 返回值 ：如果创建成功则返回YES,否则返回NO
 */
+(BOOL)deleteDocumentWithId:(NSString*)documentId {
    __block BOOL ret = NO;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        ret = [self deleteDocumentForTransactionWithId:documentId];
    }];
    return ret;
    
    
}

/**
 *  删除指定id的文档(异步模式)
 * 参数 documentId ：文档id
 * 参数 competition ：完成回调block ，如果创建成功则返回YES,否则返回NO
 */
+(void)deleteDocumentWithId:(NSString*)documentId competition:(void (^)(BOOL result))competition {
    __block BOOL ret = NO;
    [[SingleJobQueue shareInstance] runAsyncJobWithJobBlock:^{
        ret = [self deleteDocumentForTransactionWithId:documentId];
    } competition:^{
        if (competition) {
            competition(ret);
        }
    }];
}

/**
 *  删除指定id的文档(适合于在事务中执行)
 * 参数 documentId ：文档id
 * 返回值 ：如果创建成功则返回YES,否则返回NO
 */
+(BOOL)deleteDocumentForTransactionWithId:(NSString*)documentId {
    NSError *error;
    // 从数据库中检索文档,然后删除它
    if (![[[DBManager shareInstance].database documentWithID: documentId] deleteDocument: &error]) {
        NSLog (@"不能删除文档. 错误信息: %@", error.localizedDescription);
        return NO;
    }
    else {
        NSLog (@"成功删除");
    }
    return YES;
}


/**
 *  根据指定的实体对象更新符合条件的文档
 * 参数 model ：条件参数
 * 参数 newModel ：新的文档值参数，继承自实体基类的具体实体实例
 * 返回值 ：如果创建成功则返回YES,否则返回NO
 */
+(BOOL)updateDocument:(NSPredicate*)where newModel: (id) newModel {
    __block BOOL ret = NO;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        ret = [self updateDocumentForTransaction:where newModel:newModel];
    }];
    return ret;
}

/**
 *  根据指定的实体对象更新符合条件的文档(异步模式)
 * 参数 model ：条件参数
 * 参数 newModel ：新的文档值参数，继承自实体基类的具体实体实例
 * 参数 competition ：完成回调block ，如果创建成功则返回YES,否则返回NO
 */
+(void)updateDocument:(NSPredicate*)where newModel: (id) newModel competition:(void (^)(BOOL result))competition {
    __block BOOL ret = NO;
    [[SingleJobQueue shareInstance] runAsyncJobWithJobBlock:^{
        ret = [self updateDocumentForTransaction:where newModel:newModel];
    } competition:^{
        if (competition) {
            competition(ret);
        }
    }];
}

/**
 *  根据指定的实体对象更新符合条件的文档(适合于在事务中执行)
 * 参数 model ：条件参数
 * 参数 newModel ：新的文档值参数，继承自实体基类的具体实体实例
 * 返回值 ：如果创建成功则返回YES,否则返回NO
 */
+(BOOL)updateDocumentForTransaction:(NSPredicate*)where newModel: (id) newModel {
    __block BOOL ret = NO;
    
    if (where == nil) {
        return NO;
    }
    
    NSArray* models = [self getDocumentForTransactionWithSelect:@[@"_id"] where:where orderBy:nil];
    if (models != nil && models.count != 0) {
        [[DBManager shareInstance].database inTransaction:^BOOL{
            
            for (DBModelBase* item in models) {
                NSError *error;
                
                // 从数据库中检索文档
                CBLDocument *retrievedDoc = [[DBManager shareInstance].database documentWithID: item._id];
                
                // 向数据库写入更新的文档
                CBLSavedRevision *newRev = [retrievedDoc putProperties: [newModel toDictionary] error: &error];
                if (!newRev) {
                    NSLog (@"不能更新文档: %@", error.localizedDescription);
                    return NO;
                }
                else {
                    NSLog (@"成功更新");
                }
                [newModel setValue:newRev.revisionID forKey:@"_rev"];
            }
            
            ret = YES;
            return YES;
        }];
    }
    else {
        ret = YES;
    }
    
    return ret;
}



/**
 *  根据指定的文档id查询文档
 * 参数 documentId ：文档id
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例,否则返回nil
 */
+(id)getDocumentWithId:(NSString*)documentId {
    __block id ret = nil;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        ret = [self getDocumentForTransactionWithId:documentId];
    }];
    return ret;
}

/**
 *  根据指定的文档id查询文档(异步模式)
 * 参数 documentId ：文档id
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例,否则返回nil
 */
+(void)getDocumentWithId:(NSString*)documentId competition:(void (^)(id doc))competition {
    __block id ret = nil;
    [[SingleJobQueue shareInstance] runAsyncJobWithJobBlock:^{
        ret = [self getDocumentForTransactionWithId:documentId];
    } competition:^{
        if (competition) {
            competition(ret);
        }
    }];
}

/**
 *  根据指定的文档id查询文档(适合于在事务中执行)
 * 参数 documentId ：文档id
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例,否则返回nil
 */
+(id)getDocumentForTransactionWithId:(NSString*)documentId {
    // 从数据库中检索文档
    CBLDocument *retrievedDoc = [[DBManager shareInstance].database documentWithID: documentId];
    if (retrievedDoc == nil) {
        return nil;
    }
    
    return [self fromDictionary:retrievedDoc.properties];
}

//当我们有方法名和参数列表，想要动态地给对象发送消息，可用通过反射函数机制来实现(运行时的应用)
+(id) sendNewObjcMsg:(id) _target _sel:(SEL) _sel withObj:(id) _obj
{
    id (*action)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
    return action(_target,_sel,_obj);
}

/**
 *  根据指定的实体对象获取符合条件的文档
 * 参数 select ：获取字段参数
 * 参数 where ：条件参数
 * 参数 orderBy ：排序参数
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(NSArray*)getDocumentWithSelect: (nullable NSArray*)select where: (NSPredicate*)where orderBy:(nullable NSArray*)orderBy {
    __block NSArray* ret = nil;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        ret = [self getDocumentForTransactionWithSelect:select where:where orderBy:orderBy];
    }];
    return ret;
}

/**
 *  根据指定的实体对象获取符合条件的文档(异步模式)
 * 参数 select ：获取字段参数
 * 参数 where ：条件参数
 * 参数 orderBy ：排序参数
 * 参数 competition ：完成回调block,如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(void)getDocumentWithSelect: (nullable NSArray*)select where:(NSPredicate*)where orderBy:(nullable NSArray*)orderBy competition:(void (^)(NSArray*))competition {
    __block NSArray* ret = nil;
    [[SingleJobQueue shareInstance] runAsyncJobWithJobBlock:^{
        ret = [self getDocumentForTransactionWithSelect:select where:where orderBy:orderBy];
    } competition:^{
        if (competition) {
            competition(ret);
        }
    }];
}

/**
 *  根据指定的实体对象获取符合条件的文档(适合于在事务中执行)
 * 参数 select ：获取字段参数
 * 参数 where ：条件参数
 * 参数 orderBy ：排序参数
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(NSArray*)getDocumentForTransactionWithSelect: (nullable NSArray*)select where: (NSPredicate*)where orderBy:(nullable NSArray*)orderBy {
    NSMutableArray* ret = nil;
    
    NSError *error;
    CBLQueryBuilder *queryBuilder = [[CBLQueryBuilder alloc] initWithDatabase:[DBManager shareInstance].database select:select wherePredicate:where orderBy:orderBy error:&error];
    CBLQuery* query = [queryBuilder createQueryWithContext:nil];
    if (query == nil) {
        return nil;
    }
    query.prefetch = YES;
    
    //开启一个同步查询
    CBLQueryEnumerator *rowEnum = [query run:&error];
    if (rowEnum == nil) {
        return nil;
    }
    if (rowEnum.count == 0) {
        return [NSMutableArray array];
    }
    ret = [NSMutableArray array];
    for (CBLQueryRow *row in rowEnum) {
        CBLDocument* document = row.document;
        if (document != nil) {
            SEL sel = NSSelectorFromString(@"fromDictionary:");
            //[ret addObject:objc_msgSend(self, sel, document.properties)];
            [ret addObject:[self sendNewObjcMsg:self _sel:sel withObj:document.properties]];
        }
    }
    
    
    return ret;
}


/**
 *  根据指定的实体对象获取符合条件的文档
 * 参数 select : 获取字段参数
 * 参数 where : 条件参数
 * 参数 orderBy : 排序参数
 * 参数 skip : 跳过多少条
 * 参数 limit : 读取多少条
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(NSArray*)getDocumentWithSelect: (nullable NSArray*)select where:(NSPredicate*)where orderBy:(nullable NSArray*)orderBy skip:(NSInteger)skip limit:(NSInteger)limit {
    __block NSArray* ret = nil;
    [[SingleJobQueue shareInstance] runWithJobBlock:^{
        ret = [self getDocumentForTransactionWithSelect:select where:where orderBy:orderBy skip:skip limit:limit];
    }];
    return ret;
}

/**
 *  根据指定的实体对象获取符合条件的文档(异步模式)
 * 参数 select : 获取字段参数
 * 参数 where : 条件参数
 * 参数 orderBy : 排序参数
 * 参数 skip : 跳过多少条
 * 参数 limit : 读取多少条
 * 参数 competition ：完成回调block,如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(void)getDocumentWithSelect: (nullable NSArray*)select where:(NSPredicate*)where orderBy:(nullable NSArray*)orderBy skip:(NSInteger)skip limit:(NSInteger)limit competition:(void (^)(NSArray*))competition {
    __block NSArray* ret = nil;
    [[SingleJobQueue shareInstance] runAsyncJobWithJobBlock:^{
        ret = [self getDocumentForTransactionWithSelect:select where:where orderBy:orderBy skip:skip limit:limit];
    } competition:^{
        if (competition) {
            competition(ret);
        }
    }];
}

/**
 *  根据指定的实体对象获取符合条件的文档(适合于在事务中执行)
 * 参数 select : 获取字段参数
 * 参数 where : 条件参数
 * 参数 orderBy : 排序参数
 * 参数 skip : 跳过多少条
 * 参数 limit : 读取多少条
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(NSArray*)getDocumentForTransactionWithSelect: (nullable NSArray*)select where:(NSPredicate*)where orderBy:(nullable NSArray*)orderBy skip:(NSInteger)skip limit:(NSInteger)limit {
    NSMutableArray* ret = nil;
    
    NSError *error;
    CBLQueryBuilder *queryBuilder = [[CBLQueryBuilder alloc] initWithDatabase:[DBManager shareInstance].database select:select wherePredicate:where orderBy:orderBy error:&error];
    CBLQuery* query = [queryBuilder createQueryWithContext:nil];
    if (query == nil) {
        return nil;
    }
    query.prefetch = YES;
    query.skip = skip;
    query.limit = limit;
    
    //开启一个同步查询
    CBLQueryEnumerator *rowEnum = [query run:&error];
    if (rowEnum == nil) {
        return nil;
    }
    if (rowEnum.count == 0) {
        return [NSMutableArray array];
    }
    ret = [NSMutableArray array];
    for (CBLQueryRow *row in rowEnum) {
        CBLDocument* document = row.document;
        if (document != nil) {
            SEL sel = NSSelectorFromString(@"fromDictionary:");
            //[ret addObject:objc_msgSend(self, sel, document.properties)];
            [ret addObject:[self sendNewObjcMsg:self _sel:sel withObj:document.properties]];
        }
    }
    
    return ret;
}


@end

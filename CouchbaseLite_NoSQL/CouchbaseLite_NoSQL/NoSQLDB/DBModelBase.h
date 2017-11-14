//
//  DBModelBase.h
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"

/**
 数据库文档实体基类
 */
@interface DBModelBase : NSObject

@property(strong,nonatomic) NSString* _id; //文档唯一性id
@property(strong,nonatomic) NSString* _rev; //文档版本
@property(strong,nonatomic) NSString* collection; //文档所属的记录集
@property(strong,nonatomic) NSMutableDictionary* extendFields;  //动态扩展字段

//实体转词典,子类必须重写
- (NSDictionary*)toDictionary;

//词典转实体
+ (id)fromDictionary:(NSDictionary*)dictionary;

//转换成服务端JSON
- (NSData*)toServerJSON;

/**
 *  根据指定的实体对象创建一个文档
 * 参数 model ：继承自实体基类的具体实体实例
 * 返回值 ：如果创建成功则返回文档id,否则返回nil
 */
+(NSString*)createDocument:(id)model;

/**
 *  根据指定的实体对象创建一个文档(异步模式)
 * 参数 model ：继承自实体基类的具体实体实例
 * 参数 competition ：完成回调block ，如果创建成功则返回文档id,否则返回nil
 */
+(void)createDocument:(id)model competition:(void (^)(NSString* docId))competition;

/**
 *  根据指定的实体对象创建一个文档(适合于在事务中执行)
 * 参数 model ：继承自实体基类的具体实体实例
 * 返回值 ：如果创建成功则返回文档id,否则返回nil
 */
+(NSString*)createDocumentForTransaction:(id)model;

/**
 *  删除指定id的文档
 * 参数 documentId ：文档id
 * 返回值 ：如果创建成功则返回YES,否则返回NO
 */
+(BOOL)deleteDocumentWithId:(NSString*)documentId;

/**
 *  删除指定id的文档(异步模式)
 * 参数 documentId ：文档id
 * 参数 competition ：完成回调block ，如果创建成功则返回YES,否则返回NO
 */
+(void)deleteDocumentWithId:(NSString*)documentId competition:(void (^)(BOOL result))competition;

/**
 *  删除指定id的文档(适合于在事务中执行)
 * 参数 documentId ：文档id
 * 返回值 ：如果创建成功则返回YES,否则返回NO
 */
+(BOOL)deleteDocumentForTransactionWithId:(NSString*)documentId;


/**
 *  根据指定的实体对象更新符合条件的文档
 * 参数 model ：条件参数
 * 参数 newModel ：新的文档值参数，继承自实体基类的具体实体实例
 * 返回值 ：如果创建成功则返回YES,否则返回NO
 */
+(BOOL)updateDocument:(NSPredicate*)where newModel: (id) newModel;

/**
 *  根据指定的实体对象更新符合条件的文档(异步模式)
 * 参数 model ：条件参数
 * 参数 newModel ：新的文档值参数，继承自实体基类的具体实体实例
 * 参数 competition ：完成回调block ，如果创建成功则返回YES,否则返回NO
 */
+(void)updateDocument:(NSPredicate*)where newModel: (id) newModel competition:(void (^)(BOOL result))competition;

/**
 *  根据指定的实体对象更新符合条件的文档
 * 参数 model ：条件参数
 * 参数 newModel ：新的文档值参数，继承自实体基类的具体实体实例
 * 返回值 ：如果创建成功则返回YES,否则返回NO
 */
+(BOOL)updateDocumentForTransaction:(NSPredicate*)where newModel: (id) newModel;

/**
 *  根据指定的文档id查询文档
 * 参数 documentId ：文档id
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例,否则返回nil
 */
+(id)getDocumentWithId:(NSString*)documentId;

/**
 *  根据指定的文档id查询文档(异步模式)
 * 参数 documentId ：文档id
 * 参数 competition ：完成回调block,如果查询成功则返回继承自实体基类的具体实体实例,否则返回nil
 */
+(void)getDocumentWithId:(NSString*)documentId competition:(void (^)(id doc))competition;

/**
 *  根据指定的文档id查询文档(适合于在事务中执行)
 * 参数 documentId ：文档id
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例,否则返回nil
 */
+(id)getDocumentForTransactionWithId:(NSString*)documentId;

/**
 *  根据指定的实体对象获取符合条件的文档
 * 参数 select ：获取字段参数
 * 参数 where ：条件参数
 * 参数 orderBy ：排序参数
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(NSArray*)getDocumentWithSelect: (nullable NSArray*)select where:(NSPredicate*)where orderBy:(nullable NSArray*)orderBy;

/**
 *  根据指定的实体对象获取符合条件的文档(异步模式)
 * 参数 select ：获取字段参数
 * 参数 where ：条件参数
 * 参数 orderBy ：排序参数
 * 参数 competition ：完成回调block,如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(void)getDocumentWithSelect: (nullable NSArray*)select where:(NSPredicate*)where orderBy:(nullable NSArray*)orderBy competition:(void (^)(NSArray*))competition;

/**
 *  根据指定的实体对象获取符合条件的文档(适合于在事务中执行)
 * 参数 select ：获取字段参数
 * 参数 where ：条件参数
 * 参数 orderBy ：排序参数
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(NSArray*)getDocumentForTransactionWithSelect: (nullable NSArray*)select where: (NSPredicate*)where orderBy:(nullable NSArray*)orderBy;

/**
 *  根据指定的实体对象获取符合条件的文档
 * 参数 select : 获取字段参数
 * 参数 where : 条件参数
 * 参数 orderBy : 排序参数
 * 参数 skip : 跳过多少条
 * 参数 limit : 读取多少条
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(NSArray*)getDocumentWithSelect: (nullable NSArray*)select where:(NSPredicate*)where orderBy:(nullable NSArray*)orderBy skip:(NSInteger)skip limit:(NSInteger)limit;

/**
 *  根据指定的实体对象获取符合条件的文档(异步模式)
 * 参数 select : 获取字段参数
 * 参数 where : 条件参数
 * 参数 orderBy : 排序参数
 * 参数 skip : 跳过多少条
 * 参数 limit : 读取多少条
 * 参数 competition ：完成回调block,如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(void)getDocumentWithSelect: (nullable NSArray*)select where:(NSPredicate*)where orderBy:(nullable NSArray*)orderBy skip:(NSInteger)skip limit:(NSInteger)limit competition:(void (^)(NSArray*))competition;

/**
 *  根据指定的实体对象获取符合条件的文档(适合于在事务中执行)
 * 参数 select : 获取字段参数
 * 参数 where : 条件参数
 * 参数 orderBy : 排序参数
 * 参数 skip : 跳过多少条
 * 参数 limit : 读取多少条
 * 返回值 ：如果查询成功则返回继承自实体基类的具体实体实例数组,否则返回nil
 */
+(NSArray*)getDocumentForTransactionWithSelect: (nullable NSArray*)select where:(NSPredicate*)where orderBy:(nullable NSArray*)orderBy skip:(NSInteger)skip limit:(NSInteger)limit;

@end

//
//  SingleJobQueue.h
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SingleJobQueueDebug NO  //日志打印,默认关闭

/**
 *  单工作项工作队列类
 *  主要的应用场景是多个线程之中的操作委托给一个线程排队来处理
 */
@interface SingleJobQueue : NSObject

/**
 *  获取单例对象
 */
+ (SingleJobQueue*)shareInstance;

/**
 *  以block方式运行工作任务
 *
 *  @param jobBlock 工作任务block
 */
- (void)runWithJobBlock:(void (^)(void))jobBlock;

/**
 *  以block方式异步运行工作任务(不要问我为什么没有同步~)
 *
 *  @param jobBlock 工作任务block
 *  @param competition 完成回调block
 */
- (void)runAsyncJobWithJobBlock:(void (^)(void))jobBlock competition:(void (^)(void))competition;

@end

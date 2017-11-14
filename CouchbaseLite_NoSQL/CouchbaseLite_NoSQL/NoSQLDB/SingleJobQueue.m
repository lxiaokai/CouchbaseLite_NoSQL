//
//  SingleJobQueue.m
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "SingleJobQueue.h"

static NSInteger currentSingleJobQueueJobCount = 0;

typedef void(^JobBlock)(void);

/**
 工作队列之中的工作线程状态
 */
typedef enum  {
    ThreadStatusOfJobQueue_NoReady = 0,
    ThreadStatusOfJobQueue_Runing = 1,
    ThreadStatusOfJobQueue_Pause = 2,
    ThreadStatusOfJobQueue_Stop = 3,
}ThreadStatusOfJobQueue;

@interface SingleJobQueue () {
    NSThread* _jobThread; //执行工作任务的工作线程
    JobBlock _jobBlock;  //当前工作任务block
    ThreadStatusOfJobQueue _threadStatus;  //当前工作线程状态
    BOOL _isResumeJobThread;  //是否唤醒工作线程
    BOOL _isResumeSourceThread;  //是否唤醒源线程
    NSCondition* _jobThreadCondition;  //工作线程信号条件
    NSCondition* _sourceThreadCondition;  //源线程信号条件
    dispatch_queue_t _asyncQueue;  //异步操作队列
    BOOL _jobFinish;  //当前工作任务是否执行完成
}

@end

@implementation SingleJobQueue

/**
 *  获取单例对象
 */
+ (SingleJobQueue*)shareInstance {
    static SingleJobQueue* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

/**
 *  初始化
 *
 *  @return 实例对象
 */
-(id)init {
    self = [super init];
    if (self) {
        _jobThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadJob:) object:nil];
        _isResumeJobThread = NO;
        _jobThreadCondition = [[NSCondition alloc]init];
        _asyncQueue = dispatch_queue_create("SingleJobQueue_AsyncQueue", NULL);
    }
    return self;
}

/**
 *  以block方式运行工作任务
 *
 *  @param jobBlock 工作任务block
 */
- (void)runWithJobBlock:(void (^)(void))jobBlock {
    @synchronized (self) {
        if (SingleJobQueueDebug) {
            NSLog(@"current thread:%@",[NSThread currentThread]);
            currentSingleJobQueueJobCount ++;
            NSLog(@"工作项执行开始:%ld",(long)currentSingleJobQueueJobCount);
        }
        _jobFinish = NO;
        _jobBlock = jobBlock;
        if (_threadStatus == ThreadStatusOfJobQueue_NoReady) {
            //启动工作线程
            [_jobThread start];
            _threadStatus = ThreadStatusOfJobQueue_Runing;
            if (SingleJobQueueDebug) {
                NSLog(@"启动工作线程");
            }
        }
        else if (_threadStatus != ThreadStatusOfJobQueue_Stop) {
            //唤醒工作线程
            [self resumeJobThread];
        }
        
        
        //等待工作任务执行完毕
        while (!_jobFinish) {
            [NSThread sleepForTimeInterval:1.0 / 1000];
        }
        if (SingleJobQueueDebug) {
            NSLog(@"工作项执行完毕:%ld",(long)currentSingleJobQueueJobCount);
        }
    }
}

/**
 *  以block方式异步运行工作任务
 *
 *  @param jobBlock 工作任务block
 *  @param competition 完成回调block
 */
- (void)runAsyncJobWithJobBlock:(void (^)(void))jobBlock competition:(void (^)(void))competition {
    dispatch_async(_asyncQueue, ^{
        [self runWithJobBlock:jobBlock];
        if (competition) {
            competition();
        }
    });
}

/**
 *  线程工作调度函数
 *
 *  @param param 线程参数
 */
-(void)threadJob:(id)param {
    while (_threadStatus != ThreadStatusOfJobQueue_Stop) {
        if (_jobBlock) {
            if (SingleJobQueueDebug) {
                NSLog(@"执行工作项 start:%ld",(long)currentSingleJobQueueJobCount);
            }
            
            _jobBlock();
            _jobBlock = nil;
            
            if (SingleJobQueueDebug) {
                NSLog(@"执行工作项 end:%ld",(long)currentSingleJobQueueJobCount);
            }
        }
        else {
            if (SingleJobQueueDebug) {
                NSLog(@"没有jobBlock");
            }
            [self sleepJobThread];
            continue;
        }
        //通知源线程工作任务执行完毕
        _jobFinish = YES;
        
        [self sleepJobThread];
    }
}

/**
 *  令工作线程进入睡眠
 */
- (void)sleepJobThread {
    if (SingleJobQueueDebug) {
        NSLog(@"令工作线程进入睡眠 start");
    }
    [_jobThreadCondition lock];
    _threadStatus = ThreadStatusOfJobQueue_Pause;
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow: 10];
    BOOL signaled = [_jobThreadCondition waitUntilDate:date];
    if (SingleJobQueueDebug) {
        NSLog(@"工作线程信号:%@",[NSNumber numberWithBool:signaled]);
    }
    while (!_isResumeJobThread && signaled) {
        
    }
    [_jobThreadCondition unlock];
    _isResumeJobThread = NO;
    if (SingleJobQueueDebug) {
        NSLog(@"令工作线程进入睡眠 end");
    }
}

/**
 *  唤醒工作线程
 */
- (void)resumeJobThread {
    if (SingleJobQueueDebug) {
        NSLog(@"唤醒工作线程 start");
    }
    [_jobThreadCondition lock];
    _threadStatus = ThreadStatusOfJobQueue_Runing;
    _isResumeJobThread = YES;
    [_jobThreadCondition signal];
    [_jobThreadCondition unlock];
    if (SingleJobQueueDebug) {
        NSLog(@"唤醒工作线程 end");
    }
}

@end

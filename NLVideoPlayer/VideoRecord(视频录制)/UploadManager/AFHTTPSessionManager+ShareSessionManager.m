//
//  AFHTTPSessionManager+ShareSessionManager.m
//  NLVideoRecordAndUpload
//
//  Created by yj_zhang on 2018/5/11.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "AFHTTPSessionManager+ShareSessionManager.h"

static AFHTTPSessionManager *manager = nil;
@implementation AFHTTPSessionManager (ShareSessionManager)

+(AFHTTPSessionManager *)shareSessionManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFHTTPSessionManager alloc]init];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        AFSecurityPolicy *security = [AFSecurityPolicy defaultPolicy];
        security.allowInvalidCertificates = YES;
        security.validatesDomainName = NO;
        manager.securityPolicy = security;
        
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 12.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    });
    return manager;
}

@end

//
//  NLVideoUploadManager.m
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import "NLVideoUploadManager.h"
#import "AFHTTPSessionManager+ShareSessionManager.h"

@implementation NLVideoUploadManager

//普通网络请求(不带进度)
+(void)requestNetWorkWithMethod:(VideoHttpMethod)method APIMethod:(NSString *)apiMethod Params:(NSMutableDictionary *)params Domain:(NSString *)domain success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    [self requestProgressNetWorkWithMethod:method APIMethod:apiMethod Params:params Domain:domain progress:nil success:success failure:failure];
}
//普通网络请求(带进度)
+(void)requestProgressNetWorkWithMethod:(VideoHttpMethod)method APIMethod:(NSString *)apiMethod Params:(NSMutableDictionary *)params Domain:(NSString *)domain progress:(void (^)(NSProgress * _Nonnull))progress success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    [self requestDataNetWorkWithMethod:method APIMethod:apiMethod Params:params Domain:domain constructingBodyWithBlock:nil progress:progress success:success failure:failure];
}
//文件上传网络请求(带进度,带文件)
+(void)requestDataNetWorkWithMethod:(VideoHttpMethod)method APIMethod:(NSString *)apiMethod Params:(NSMutableDictionary *)params Domain:(NSString *)domain constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block progress:(void (^)(NSProgress * _Nonnull))progress success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    
    //添加公共参数
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareSessionManager];
    switch (method) {
        case Video_GET:
            [manager GET:domain parameters:params progress:progress success:success failure:failure];
            break;
        case Video_POST:
            [manager POST:domain parameters:params progress:progress success:success failure:failure];
            break;
        case Video_POSTFILE:
            [manager POST:domain parameters:params constructingBodyWithBlock:block progress:progress success:success failure:failure];
            break;
        default:
            break;
    }
    
}



@end




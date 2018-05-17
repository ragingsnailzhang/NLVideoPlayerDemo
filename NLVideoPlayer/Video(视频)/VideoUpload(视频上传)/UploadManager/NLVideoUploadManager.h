//
//  NLVideoUploadManager.h
//  NLVideoPlayer
//
//  Created by yj_zhang on 2018/5/10.
//  Copyright © 2018年 yj_zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class NLUploadModel;


typedef NS_ENUM(NSInteger,VideoHttpMethod){
    Video_GET = 1,
    Video_POST,
    Video_POSTFILE,
};

@interface NLVideoUploadManager : NSObject

/**
 *普通网络请求(不带进度)
 */
+(void)requestNetWorkWithMethod:(VideoHttpMethod)method APIMethod:(NSString *)apiMethod Params:(NSMutableDictionary *)params Domain:(NSString *)domain success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 *普通网络请求(带进度)
 */
+(void)requestProgressNetWorkWithMethod:(VideoHttpMethod)method APIMethod:(NSString *)apiMethod Params:(NSMutableDictionary *)params Domain:(NSString *)domain progress:(void (^)(NSProgress * _Nonnull))progress success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 *文件上传网络请求(带进度,带文件)
 */
+(void)requestDataNetWorkWithMethod:(VideoHttpMethod)method APIMethod:(NSString *)apiMethod Params:(NSMutableDictionary *)params Domain:(NSString *)domain constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block progress:(void (^)(NSProgress * _Nonnull))progress success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;



@end


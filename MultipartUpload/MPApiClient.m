//
//  MPApiClient.m
//  MultipartUpload
//
//  Created by Zeeshan Anjum on 28/12/2017.
//  Copyright © 2017 Zeeshan Anjum. All rights reserved.
//

#import "MPApiClient.h"

@implementation MPApiClient

- (instancetype)init {
    
    NSURL *url = [NSURL URLWithString:@"http://35.227.40.51/api/user/"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    return [super initWithBaseURL:url sessionConfiguration:configuration];
}

#pragma mark - Public methods

+ (instancetype)sharedClient {
    static MPApiClient *sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[MPApiClient alloc] init];
    });
    
    return sharedClient;
}

- (id)uploadMediaWithMediaPath:(NSString *)filePath withProgressCompletionHandler:(MPAPIClientProgressCompletionHandler)progressCompletionHandler andCompletionHandler:(MPAPIClientCompletionHandler)completionHandler {
    NSString *methodName = @"editProfile";
    NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
    NSString *fileName = [filePathURL lastPathComponent];
    
    if (!fileName) {
        return nil;
    }
    
    NSDictionary *params = @{@"email":@"test1@test.com", @"userAddress":@"testtest", @"fullName":@"test"};
    return [self uploadRequestWithMethodName:methodName andFileURL:filePath andParams:params withProgressCompletionHandler:progressCompletionHandler andCompletionHandler:completionHandler];
}


- (NSURLSessionTask *)uploadRequestWithMethodName:(NSString *)methodName andFileURL:(NSString *)fileURL andParams:(NSDictionary *)params withProgressCompletionHandler:(MPAPIClientProgressCompletionHandler)progressCompletionHandler andCompletionHandler:(MPAPIClientCompletionHandler)completionHandler {
    NSError *error;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:[NSString stringWithFormat:@"%@%@",self.baseURL.absoluteString, methodName]
                                                                                             parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                                 
                                                                                                 NSURL *url = [NSURL fileURLWithPath:fileURL];
                                                                                                 [formData appendPartWithFileURL:url name:@"profilePicture" fileName:@"profilePicture" mimeType:@"image/jpeg" error:nil];

                                                                                                 [formData appendPartWithFormData:[[params valueForKey:@"email"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                                             name:@"email"];
                                                                                                 [formData appendPartWithFormData:[[params valueForKey:@"userAddress"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                                             name:@"userAddress"];
                                                                                                 [formData appendPartWithFormData:[[params valueForKey:@"fullName"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                                             name:@"fullName"];
                                                                                                 
    } error:&error];
    
    [request addValue:@"JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmdWxsTmFtZSI6InRlc3QgVXNlciAyIiwiZW1haWwiOiJ0ZXN0MUB0ZXN0LmNvbSIsInVzZXJJRCI6MjYxLCJpYXQiOjE1MTQzOTM4NDh9.q35q3o2NJMaWMLdgMgcGAnbenJQEsfjpV_Wvsi-iUI0" forHTTPHeaderField:@"authorization"];
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [self uploadTaskWithStreamedRequest:request
                                            progress:^(NSProgress * _Nonnull uploadProgress) {
                                                progressCompletionHandler(uploadProgress);
                                            }
                                   completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                       completionHandler (response,responseObject,error);
                                   }];
    
    [uploadTask resume];
    
    return uploadTask;
}

@end

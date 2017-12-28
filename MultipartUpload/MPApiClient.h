//
//  MPApiClient.h
//  MultipartUpload
//
//  Created by Zeeshan Anjum on 28/12/2017.
//  Copyright © 2017 Zeeshan Anjum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^MPAPIClientCompletionHandler)(NSURLResponse *response, id result, NSError *error);
typedef void (^MPAPIClientProgressCompletionHandler)(NSProgress *progress);

@interface MPApiClient : AFHTTPSessionManager

+ (instancetype)sharedClient;
- (id)uploadMediaWithMediaPath:(NSString *)filePath withProgressCompletionHandler:(MPAPIClientProgressCompletionHandler)progressCompletionHandler andCompletionHandler:(MPAPIClientCompletionHandler)completionHandler;

@end

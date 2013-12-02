//
//  CMDHueBridge.m
//  CMDHue
//
//  Created by Caleb Davenport on 11/16/13.
//  Copyright (c) 2013 Caleb Davenport. All rights reserved.
//

#import "CMDHueBridge.h"
#import "CMDHueClient.h"
#import "CMDHueLight.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CMDHueBridge ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *lights;

@end

@implementation CMDHueBridge

@synthesize baseURL = _baseURL;

#pragma mark - Public

- (instancetype)initWithClient:(CMDHueClient *)client address:(NSString *)address {
    if ((self = [super init])) {
        _client = client;
        _IPAddress = address;
    }
    return self;
}


- (RACSignal *)configuration {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *path = [NSString stringWithFormat:@"/api/%@", self.client.username];
        NSURL *URL = [NSURL URLWithString:path relativeToURL:self.baseURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [NSURLConnection
         sendAsynchronousRequest:request
         queue:[NSOperationQueue mainQueue]
         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
             NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
             if (statusCode == 200 && data) {
                 NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                 [self unpackDictionary:dictionary];
                 [subscriber sendNext:self];
             }
             else {
                 [subscriber sendError:error];
             }
             [subscriber sendCompleted];
         }];
        return nil;
    }];
}


- (void)unpackDictionary:(NSDictionary *)dictionary {
    
    // Configuration
    NSDictionary *configuration = dictionary[@"config"];
    self.name = configuration[@"name"];
    
    // Lights
    NSDictionary *lights = dictionary[@"lights"];
    self.lights = [[lights.rac_sequence map:^(RACTuple *tuple) {
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        dictionary[@"id"] = tuple.first;
        [dictionary addEntriesFromDictionary:tuple.second];
        return [[CMDHueLight alloc] initWithBridge:self dictionary:dictionary];
    }] array];
    
}


#pragma mark - Accessors

- (NSURL *)baseURL {
    if (!_baseURL) {
        _baseURL = [[NSURL alloc] initWithScheme:@"http" host:self.IPAddress path:@"/"];
    }
    return _baseURL;
}

@end

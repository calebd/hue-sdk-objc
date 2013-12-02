//
//  HueBridge.h
//  HueBot
//
//  Created by Caleb Davenport on 11/16/13.
//  Copyright (c) 2013 SimpleAuth. All rights reserved.
//

@class HueClient;
@class RACSignal;

@interface HueBridge : NSObject

@property (nonatomic, readonly) HueClient *client;
@property (nonatomic, readonly) NSString *IPAddress;
@property (nonatomic, readonly) NSURL *baseURL;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray *lights;

- (instancetype)initWithClient:(HueClient *)client address:(NSString *)address;

- (RACSignal *)configuration;

- (void)unpackDictionary:(NSDictionary *)dictionary;

@end

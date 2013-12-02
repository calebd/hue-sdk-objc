//
//  CMDHueBridge.h
//  CMDHue
//
//  Created by Caleb Davenport on 11/16/13.
//  Copyright (c) 2013 Caleb Davenport. All rights reserved.
//

@class CMDHueClient;
@class RACSignal;

@interface CMDHueBridge : NSObject

@property (nonatomic, readonly) CMDHueClient *client;
@property (nonatomic, readonly) NSString *IPAddress;
@property (nonatomic, readonly) NSURL *baseURL;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray *lights;

- (instancetype)initWithClient:(CMDHueClient *)client address:(NSString *)address;

- (RACSignal *)configuration;

- (void)unpackDictionary:(NSDictionary *)dictionary;

@end

//
//  HueClient.h
//  HueBot
//
//  Created by Caleb Davenport on 11/16/13.
//  Copyright (c) 2013 SimpleAuth. All rights reserved.
//

@class RACSignal;

@interface HueClient : NSObject

@property (nonatomic, readonly) NSString *username;

- (instancetype)initWithUsername:(NSString *)username;

- (RACSignal *)bridges;

- (RACSignal *)lights;
- (RACSignal *)lightsByName;

@end

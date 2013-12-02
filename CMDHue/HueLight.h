//
//  HueLight.h
//  HueBot
//
//  Created by Caleb Davenport on 12/1/13.
//  Copyright (c) 2013 SimpleAuth. All rights reserved.
//

@class HueBridge;

@interface HueLight : NSObject

@property (nonatomic, readonly, strong) HueBridge *bridge;
@property (nonatomic, readonly, copy) NSString *model;
@property (nonatomic, readonly, copy) NSString *type;
@property (nonatomic, readonly, copy) NSNumber *remoteID;

@property (nonatomic, copy) NSString *name;

// These properties can be configured in a batch update
@property (nonatomic, assign) BOOL on;
@property (nonatomic, copy) UIColor *color;

- (instancetype)initWithBridge:(HueBridge *)bridge dictionary:(NSDictionary *)dictionary;

- (void)unpackDictionary:(NSDictionary *)dictionary;

- (void)performBatchUpdates:(void (^) (HueLight *light))updates;
- (void)performBatchUpdates:(void (^)(HueLight *))updates interval:(NSTimeInterval)interval;

- (BOOL)isOn;
- (void)turnOn;
- (void)turnOff;

@end

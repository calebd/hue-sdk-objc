//
//  CMDHueLight.h
//  CMDHue
//
//  Created by Caleb Davenport on 12/1/13.
//  Copyright (c) 2013 Caleb Davenport. All rights reserved.
//

@class CMDHueBridge;

@interface CMDHueLight : NSObject

@property (nonatomic, readonly, strong) CMDHueBridge *bridge;
@property (nonatomic, readonly, copy) NSString *model;
@property (nonatomic, readonly, copy) NSString *type;
@property (nonatomic, readonly, copy) NSNumber *remoteID;

@property (nonatomic, copy) NSString *name;

// These properties can be configured in a batch update
@property (nonatomic, assign) BOOL on;
@property (nonatomic, copy) UIColor *color;

- (instancetype)initWithBridge:(CMDHueBridge *)bridge dictionary:(NSDictionary *)dictionary;

- (void)unpackDictionary:(NSDictionary *)dictionary;

- (void)performBatchUpdates:(void (^) (CMDHueLight *light))updates;
- (void)performBatchUpdates:(void (^)(CMDHueLight *))updates interval:(NSTimeInterval)interval;

- (BOOL)isOn;
- (void)turnOn;
- (void)turnOff;

@end

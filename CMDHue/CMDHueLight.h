//
//  CMDHueLight.h
//  CMDHue
//
//  Created by Caleb Davenport on 12/1/13.
//  Copyright (c) 2013 Caleb Davenport. All rights reserved.
//

typedef NS_ENUM(NSUInteger, CMDHueLightAlert) {
    CMDHueLightAlertNone,
    CMDHueLightAlertBreatheOnce,
    CMDHueLightAlertBreatheIndefinite
};
CMDHueLightAlert CMDHueLightAlertFromString(NSString *string);
NSString *NSStringFromCMDHueLightAlert(CMDHueLightAlert alert);

typedef NS_ENUM(NSUInteger, CMDHueLightEffect) {
    CMDHueLightEffectNone,
    CMDHueLightEffectColorLoop
};
CMDHueLightEffect CMDHueLightEffectFromString(NSString *string);
NSString *NSStringFromCMDHueLightEffect(CMDHueLightEffect alert);

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
@property (nonatomic, assign) CMDHueLightAlert alert;
@property (nonatomic, assign) CMDHueLightEffect effect;

- (instancetype)initWithBridge:(CMDHueBridge *)bridge dictionary:(NSDictionary *)dictionary;

- (void)unpackDictionary:(NSDictionary *)dictionary;

- (void)performBatchUpdates:(void (^) (CMDHueLight *light))updates;
- (void)performBatchUpdates:(void (^)(CMDHueLight *))updates interval:(NSTimeInterval)interval;

- (BOOL)isOn;
- (void)turnOn;
- (void)turnOff;

@end

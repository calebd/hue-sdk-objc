//
//  CMDHueLight.m
//  CMDHue
//
//  Created by Caleb Davenport on 12/1/13.
//  Copyright (c) 2013 Caleb Davenport. All rights reserved.
//

#import "CMDHueLight.h"
#import "CMDHueBridge.h"
#import "CMDHueClient.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>

#pragma mark - C functions

CMDHueLightAlert CMDHueLightAlertFromString(NSString *string) {
    static dispatch_once_t token;
    static NSDictionary *dictionary;
    dispatch_once(&token, ^{
        dictionary = @{
            @"none" : @(CMDHueLightAlertNone),
            @"lselect" : @(CMDHueLightAlertBreatheIndefinite),
            @"select" : @(CMDHueLightAlertBreatheOnce)
        };
    });
    return [dictionary[string] unsignedIntegerValue];
}


NSString *NSStringFromCMDHueLightAlert(CMDHueLightAlert alert) {
    if (alert == CMDHueLightAlertNone) {
        return @"none";
    }
    else if (alert == CMDHueLightAlertBreatheOnce) {
        return @"select";
    }
    else if (alert == CMDHueLightAlertBreatheIndefinite) {
        return @"lselect";
    }
    else {
        return nil;
    }
}


CMDHueLightEffect CMDHueLightEffectFromString(NSString *string) {
    static dispatch_once_t token;
    static NSDictionary *dictionary;
    dispatch_once(&token, ^{
        dictionary = @{
            @"none" : @(CMDHueLightEffectNone),
            @"colorloop" : @(CMDHueLightEffectColorLoop)
        };
    });
    return [dictionary[string] unsignedIntegerValue];
}


NSString *NSStringFromCMDHueLightEffect(CMDHueLightEffect alert) {
    if (alert == CMDHueLightEffectNone) {
        return @"none";
    }
    else if (alert == CMDHueLightEffectColorLoop) {
        return @"colorloop";
    }
    else {
        return nil;
    }
}

@interface CMDHueLight ()

@property (nonatomic, strong) CMDHueBridge *bridge;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *remoteID;

@end

@implementation CMDHueLight {
    BOOL _ignoreChangesInSetters;
}

#pragma mark - Public

- (instancetype)initWithBridge:(CMDHueBridge *)bridge dictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        self.bridge = bridge;
        [self unpackDictionary:dictionary];
        
//        @weakify(self);
//        [RACObserve(self, on) subscribeNext:^(id x) {
//            @strongify(self);
//            [self sendState];
//        }];
    }
    return self;
}


- (void)unpackDictionary:(NSDictionary *)dictionary {
    _ignoreChangesInSetters = YES;
    
    // Base properties
    self.remoteID = dictionary[@"id"];
    self.name = dictionary[@"name"];
    self.type = dictionary[@"type"];
    self.model = dictionary[@"model"];
    
    // State
    NSDictionary *state = dictionary[@"state"];
    [state[@"on"] boolValue] ? [self turnOn] : [self turnOff];
    
    // Color
    double hue = [state[@"hue"] doubleValue];
    double saturation = [state[@"sat"] doubleValue];
    double brightness = [state[@"bri"] doubleValue];
    self.color = [UIColor colorWithHue:(hue / 65535.0) saturation:(saturation / 255.0) brightness:(brightness / 255.0) alpha:1.0];
    
    _ignoreChangesInSetters = NO;
}


- (void)performBatchUpdates:(void (^) (CMDHueLight *light))updates {
    _ignoreChangesInSetters = YES;
    updates(self);
    _ignoreChangesInSetters = NO;
    [self sendState];
}


- (void)performBatchUpdates:(void (^)(CMDHueLight *))updates interval:(NSTimeInterval)interval {
    _ignoreChangesInSetters = YES;
    updates(self);
    _ignoreChangesInSetters = NO;
    [self sendState:@(interval / 10.0)];
}


- (void)turnOff {
    self.on = NO;
}


- (void)turnOn {
    self.on = YES;
}


- (BOOL)isOn {
    return self.on;
}


#pragma mark - Accessors

- (void)setColor:(UIColor *)color {
    _color = [color copy];
    [self sendState];
}


- (void)setOn:(BOOL)on {
    _on = on;
    [self sendState];
}


- (void)setEffect:(CMDHueLightEffect)effect {
    _effect = effect;
    [self sendState];
}


- (void)setAlert:(CMDHueLightAlert)alert {
    _alert = alert;
    [self sendState];
}


#pragma mark - Private

- (void)sendState {
    [self sendState:nil];
}


- (void)sendState:(NSNumber *)transitionTime {
    
    // Break if we are ingnoring changes
    if (_ignoreChangesInSetters) {
        return;
    }
    
    // Build request body
    CGFloat hue, saturation, brightness;
    [self.color getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[@"on"] = @(self.on);
    dictionary[@"hue"] = @((NSUInteger)(hue * 65535.0));
    dictionary[@"sat"] = @((NSUInteger)(saturation * 255.0));
    dictionary[@"bri"] = @((NSUInteger)(brightness * 255.0));
    dictionary[@"alert"] = NSStringFromCMDHueLightAlert(self.alert);
    dictionary[@"effect"] = NSStringFromCMDHueLightEffect(self.effect);
    if (transitionTime) {
        dictionary[@"transitiontime"] = transitionTime;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:nil];
    
    NSString *path = [NSString stringWithFormat:@"/api/%@/lights/%@/state", self.bridge.client.username, self.remoteID];
    NSURL *URL = [NSURL URLWithString:path relativeToURL:self.bridge.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"PUT"];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
         if (/*statusCode == 200 && */data) {
             NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
             NSLog(@"%@", dictionary);
         }
         else {
             NSLog(@"%@", error);
         }
     }];
}

@end

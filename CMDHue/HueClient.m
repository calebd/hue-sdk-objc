//
//  HueClient.m
//  HueBot
//
//  Created by Caleb Davenport on 11/16/13.
//  Copyright (c) 2013 SimpleAuth. All rights reserved.
//

#import "HueClient.h"
#import "HueBridge.h"
#import "HueLight.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation HueClient

#pragma mark - Public

- (instancetype)initWithUsername:(NSString *)username {
    if ((self = [super init])) {
        _username = [username copy];
    }
    return self;
}


- (RACSignal *)bridges {
    return [[[[[self bridgeDictionaries]
     flattenMap:^(NSArray *dictionaries) {
         return [dictionaries.rac_sequence signal];
     }]
     flattenMap:^(NSDictionary *dictionary) {
         NSString *address = dictionary[@"internalipaddress"];
         HueBridge *bridge = [[HueBridge alloc] initWithClient:self address:address];
         return [RACSignal return:bridge];
     }]
     flattenMap:^(HueBridge *bridge) {
         return [bridge configuration];
     }]
     collect];
}


- (RACSignal *)lights {
    return [[[[self bridges]
     flattenMap:^(NSArray *bridges) {
         return [bridges.rac_sequence signal];
     }]
     flattenMap:^(HueBridge *bridge) {
         return [bridge.lights.rac_sequence signal];
     }]
     collect];
}


- (RACSignal *)lightsByName {
    return [[self lights] map:^(NSArray *lights) {
        RACSequence *sequence = [lights.rac_sequence map:^(HueLight *light) {
            return light.name;
        }];
        return [NSDictionary dictionaryWithObjects:lights forKeys:sequence.array];
    }];
}


#pragma mark - Private

- (RACSignal *)bridgeDictionaries {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *URL = [NSURL URLWithString:@"https://www.meethue.com/api/nupnp"];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [NSURLConnection
         sendAsynchronousRequest:request
         queue:[NSOperationQueue mainQueue]
         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
             NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
             if (statusCode == 200 && data) {
                 NSArray *bridges = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                 [subscriber sendNext:bridges];
             }
             else {
                 [subscriber sendError:error];
             }
             [subscriber sendCompleted];
         }];
        return nil;
    }];
}

@end

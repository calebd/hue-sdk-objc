# CMDHue

CMDHue is an Objective-C SDK for working with [Hue]() lights. It is powered by ReactiveCocoa. It currently covers a small subset of the Hue API but I plan to expand that over time.

## Usage

Instantiate a client:

````objc
HueClient *client = [[HueClient alloc] initWithUsername:@"username"];
````

Play with some lights:

````objc
[[client lightsByName] subscribeNext:^(NSDictionary *lights) {
	HueLight *light;
	
	light = lights[@"Desk"];
    [light performBatchUpdates:^(HueLight *light) {
        light.color = [UIColor purpleColor];
		[light turnOn];
    }];
	
	light = lights[@"Floor"];
    [light performBatchUpdates:^(HueLight *light) {
        light.color = [UIColor blueColor];
		[light turnOn];
    }];
	
	light = lights[@"Bookshelf"];
	[light turnOff];
}]
````

## License

CMDHue is released under the MIT license.

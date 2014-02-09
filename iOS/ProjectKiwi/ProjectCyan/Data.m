//
//  Data.m
//  ProjectCyan
//
//  Created by David Skrundz on 2/9/2014.
//  Copyright (c) 2014 David Skrundz. All rights reserved.
//

#import "Data.h"

@implementation Data

- (instancetype)initWithUUID:(NSString *)uuid count:(int)count delta:(double)delta address:(NSString *)address latitude:(NSString *)latitude longitude:(NSString *)longitude name:(NSString *)name time:(NSString *)time {
	if (self = [super init]) {
		self.uuid = uuid;
		self.count = count;
		self.delta = delta;
		self.address = address;
		self.latitude = latitude;
		self.longitude = longitude;
		self.name = name;
		self.time = time;
	}
	return self;
}

- (NSString *)toString {
	return [NSString stringWithFormat:@"UUID: %@\nCount: %d\nDelta: %f\nAddress: %@\nLatitude: %@\nLongitude: %@\nName: %@\nTime: %@", self.uuid, self.count, self.delta, self.address, self.latitude, self.longitude, self.name, self.time];
}

@end
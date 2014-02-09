//
//  Data.h
//  ProjectCyan
//
//  Created by David Skrundz on 2/9/2014.
//  Copyright (c) 2014 David Skrundz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) int count;
@property (nonatomic, assign) double delta;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *time;

- (instancetype)initWithUUID:(NSString *)uuid count:(int)count delta:(double)delta address:(NSString *)address latitude:(NSString *)latitude longitude:(NSString *)longitude name:(NSString *)name time:(NSString *)time;

@end
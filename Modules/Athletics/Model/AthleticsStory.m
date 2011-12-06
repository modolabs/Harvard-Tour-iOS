//
//  AthleticsStory.m
//  Universitas
//
//  Created by Liu Mingxing on 12/6/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsStory.h"

@implementation AthleticsStory
@synthesize title;
@synthesize thumbImage;
@synthesize summary;
@synthesize identifier;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.title = nil;
    self.thumbImage = nil;
    self.summary = nil;
    self.identifier = nil;

    [super dealloc];
}
@end

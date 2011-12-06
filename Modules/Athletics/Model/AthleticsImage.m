//
//  AthleticsImage.m
//  Universitas
//
//  Created by Liu Mingxing on 12/6/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsImage.h"

@implementation AthleticsImage
@synthesize data;
@synthesize url;

- (void)dealloc {
    self.data = nil;
    self.url = nil;

    [super dealloc];
}
@end

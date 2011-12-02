//
//  AthleticsTableViewCell.m
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsTableViewCell.h"

@implementation AthleticsTableViewCell
- (void)dealloc {
    [_thumbnailView release];
    [_titleLabel release];
    [_dekLabel release];
    [super dealloc];
}
@end

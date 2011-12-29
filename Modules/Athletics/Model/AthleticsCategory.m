//
//  AthleticsCategory.m
//  Universitas
//
//  Created by Liu Mingxing on 12/20/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsCategory.h"
#import "AthleticsMenu.h"
#import "AthleticsSchedule.h"
#import "AthleticsStory.h"

NSString * const AthleticsCategoryEntityName = @"AthleticsCategory";
@implementation AthleticsCategory

@dynamic category;
@dynamic category_id;
@dynamic isMainCategory;
@dynamic ivar;
@dynamic key;
@dynamic lastUpdated;
@dynamic moduleTag;
@dynamic moreStories;
@dynamic nextSeekId;
@dynamic path;
@dynamic sortOrder;
@dynamic title;
@dynamic url;
@dynamic menu;
@dynamic bookmarked;
@dynamic stories;
@dynamic schedules;

- (BOOL)isBookmarked {
    return [self.bookmarked boolValue];
}

- (void)addBookmark {
    if (![self isBookmarked]) {
        self.bookmarked = [NSNumber numberWithBool:YES];
    }
}

- (void)removeBookmark {
    if ([self isBookmarked]) {
        self.bookmarked = [NSNumber numberWithBool:NO];
    }
}

@end



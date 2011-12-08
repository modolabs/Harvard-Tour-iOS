//
//  AthleticsStory.m
//  Universitas
//
//  Created by Liu Mingxing on 12/8/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsStory.h"
#import "AthleticsCategory.h"
#import "AthleticsImage.h"
#import "KGOAppDelegate+ModuleAdditions.h"
NSString * const AthleticsStoryEntityName = @"AthleticsStory";
@implementation AthleticsStory

@dynamic author;
@dynamic body;
@dynamic bookmarked;
@dynamic featured;
@dynamic hasBody;
@dynamic identifier;
@dynamic link;
@dynamic postDate;
@dynamic read;
@dynamic searchResult;
@dynamic title;
@dynamic topStory;
@dynamic summary;
@dynamic categories;
@dynamic featuredImage;
@dynamic thumbImage;

@synthesize moduleTag;
#pragma mark - KGOSearchResult

- (NSString *)subtitle {
    return self.summary;
}

- (BOOL)isBookmarked {
    return [self.bookmarked boolValue];
}

- (void)addBookmark {
    if (![self isBookmarked]) {
        self.bookmarked = [NSNumber numberWithBool:YES];
    }
    self.searchResult = [NSNumber numberWithInt:0];
}

- (void)removeBookmark {
    if ([self isBookmarked]) {
        self.bookmarked = [NSNumber numberWithBool:NO];
    }
}

- (BOOL)didGetSelected:(id)selector
{
    if ([self.hasBody boolValue]) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self, @"story", nil];
        return [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail
                                      forModuleTag:self.moduleTag
                                            params:params];
    } else if (self.link.length) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.link]];
        return YES;
    }
    return NO;
}

@end

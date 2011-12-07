//
//  AthleticsStory.m
//  Universitas
//
//  Created by Liu Mingxing on 12/6/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsStory.h"
#import "KGOAppDelegate+ModuleAdditions.h"


NSString * const AthleticsStoryEntityName = @"AthleticsStory";
@implementation AthleticsStory
@synthesize body;
@synthesize author;
@synthesize read;
@synthesize featured;
@synthesize hasBody;
@synthesize identifier;
@synthesize link;
@synthesize postDate;
@synthesize title;
@synthesize topStory;
@synthesize summary;
@synthesize searchResult;
@synthesize bookmarked;
@synthesize categories;
@synthesize thumbImage;
@synthesize featuredImage;
@synthesize moduleTag;



- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.body = nil;
    self.author = nil;
    self.read = nil;
    self.featured = nil;
    self.hasBody = nil;
    self.identifier = nil;
    self.link = nil;
    self.postDate = nil;
    self.title = nil;
    self.topStory = nil;
    self.summary = nil;
    self.searchResult = nil;
    self.bookmarked = nil;
    self.categories = nil;
    self.thumbImage = nil;
    self.featuredImage = nil;


    [super dealloc];
}

- (void)addCategoriesObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] addObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCategoriesObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] unionSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCategories:(NSSet *)value {
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] minusSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

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

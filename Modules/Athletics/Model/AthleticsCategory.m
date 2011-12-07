//
//  AthleticsCategory.m
//  Universitas
//
//  Created by Liu Mingxing on 12/7/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsCategory.h"
#import "AthleticsStory.h"

NSString * const AthleticsCategoryEntityName = @"AthleticsCategory";

@implementation AthleticsCategory 
@dynamic lastUpdated;
@dynamic nextSeekId;
@dynamic category_id;
@dynamic title;
@dynamic moduleTag;
@dynamic isMainCategory;
@dynamic moreStories;
@dynamic stories;
@dynamic url;
// Added in v3
@dynamic sortOrder;

- (void)addStoriesObject:(AthleticsStory *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"stories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"stories"] addObject:value];
    [self didChangeValueForKey:@"stories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeStoriesObject:(AthleticsStory *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"stories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"stories"] removeObject:value];
    [self didChangeValueForKey:@"stories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addStories:(NSSet *)value {    
    [self willChangeValueForKey:@"stories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"stories"] unionSet:value];
    [self didChangeValueForKey:@"stories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeStories:(NSSet *)value {
    [self willChangeValueForKey:@"stories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"stories"] minusSet:value];
    [self didChangeValueForKey:@"stories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end

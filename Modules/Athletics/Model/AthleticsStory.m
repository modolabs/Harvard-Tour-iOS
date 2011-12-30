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

- (NSString *)subtitle {
    return self.summary;
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

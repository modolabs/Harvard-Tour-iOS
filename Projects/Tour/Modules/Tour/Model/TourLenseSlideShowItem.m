//
//  TourLenseSlideShowItem.m
//  Tour
//
//  Created by Brian Patt on 5/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TourLenseSlideShowItem.h"
#import "TourSlide.h"


@implementation TourLenseSlideShowItem
@dynamic slides;

- (void)addSlidesObject:(TourSlide *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"slides" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"slides"] addObject:value];
    [self didChangeValueForKey:@"slides" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSlidesObject:(TourSlide *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"slides" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"slides"] removeObject:value];
    [self didChangeValueForKey:@"slides" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSlides:(NSSet *)value {    
    [self willChangeValueForKey:@"slides" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"slides"] unionSet:value];
    [self didChangeValueForKey:@"slides" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSlides:(NSSet *)value {
    [self willChangeValueForKey:@"slides" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"slides"] minusSet:value];
    [self didChangeValueForKey:@"slides" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end

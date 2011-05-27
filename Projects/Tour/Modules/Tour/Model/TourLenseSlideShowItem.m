#import "TourLenseSlideShowItem.h"
#import "TourSlide.h"
#import "TourConstants.h"
#import "CoreDataManager.h"
#import "Foundation+KGOAdditions.h"

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

+ (TourLenseSlideShowItem *)itemWithDictionary:(NSDictionary *)slideShowDict {
    TourLenseSlideShowItem *slideShow = [[CoreDataManager sharedManager] 
                                           insertNewObjectForEntityForName:TourLenseSlideShowItemEntityName];
    
    NSArray *slideDicts = [slideShowDict arrayForKey:@"slides"];
    for(NSInteger index=0; index < slideDicts.count; index++) {
        NSDictionary *slideDict = [slideDicts objectAtIndex:index];
        TourSlide *slide = [TourSlide slideWithDictionary:slideDict];
        slide.order = [NSNumber numberWithInt:index];
        [slideShow addSlidesObject:slide];
    }
    return slideShow;
}

@end

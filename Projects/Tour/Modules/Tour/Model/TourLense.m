#import "CoreDataManager.h"
#import "Foundation+KGOAdditions.h"
#import "TourConstants.h"
#import "TourLense.h"
#import "TourLenseItem.h"
#import "TourStop.h"
#import "TourLenseHtmlItem.h"
#import "TourLensePhotoItem.h"
#import "TourLenseSlideShowItem.h"
#import "TourLenseVideoItem.h"

@implementation TourLense
@dynamic lenseType;
@dynamic stop;
@dynamic lenseItems;


- (void)addLenseItemsObject:(TourLenseItem *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"lenseItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"lenseItems"] addObject:value];
    [self didChangeValueForKey:@"lenseItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeLenseItemsObject:(TourLenseItem *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"lenseItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"lenseItems"] removeObject:value];
    [self didChangeValueForKey:@"lenseItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addLenseItems:(NSSet *)value {    
    [self willChangeValueForKey:@"lenseItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"lenseItems"] unionSet:value];
    [self didChangeValueForKey:@"lenseItems" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeLenseItems:(NSSet *)value {
    [self willChangeValueForKey:@"lenseItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"lenseItems"] minusSet:value];
    [self didChangeValueForKey:@"lenseItems" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

+ (TourLense *)lenseWithItems:(NSArray *)lenseItems ofLenseType:(NSString *)lenseType {
    TourLense *lense =[[CoreDataManager sharedManager] insertNewObjectForEntityForName:TourLenseEntityName];
    lense.lenseType = lenseType;
    for (NSInteger index=0; index < lenseItems.count; index++) {
        NSDictionary *lenseItemDict = [lenseItems objectAtIndex:index];
        
        NSString *lenseItemType = [lenseItemDict stringForKey:@"type" nilIfEmpty:NO];
        
        TourLenseItem *lenseItem;
        if ([lenseItemType isEqualToString:@"html"]) {
            lenseItem = [TourLenseHtmlItem itemWithDictionary:lenseItemDict];
        }
        else if([lenseItemType isEqualToString:@"photo"]) {
            lenseItem = [TourLensePhotoItem itemWithDictionary:lenseItemDict];
        }
        else if([lenseItemType isEqualToString:@"video"]) {
            lenseItem = [TourLenseVideoItem itemWithDictionary:lenseItemDict];
        }
        else if([lenseItemType isEqualToString:@"slideshow"]) {
            lenseItem = [TourLenseSlideShowItem itemWithDictionary:lenseItemDict];
        }
        
        lenseItem.order = [NSNumber numberWithInt:index];
        lenseItem.type = lenseItemType;
        [lense addLenseItemsObject:lenseItem];
    }
    return lense;
}


@end

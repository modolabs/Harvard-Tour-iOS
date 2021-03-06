
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "TourStop.h"
#import "TourMediaItem.h"
#import "TourLense.h"
#import "TourConstants.h"
#import "CoreDataManager.h"
#import "Foundation+KGOAdditions.h"

@implementation TourStop
@dynamic subtitle;
@dynamic id;
@dynamic longitude;
@dynamic title;
@dynamic visited;
@dynamic order;
@dynamic latitude;
@dynamic thumbnail;
@dynamic lenses;
@dynamic photo;


- (void)addLensesObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"lenses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"lenses"] addObject:value];
    [self didChangeValueForKey:@"lenses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeLensesObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"lenses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"lenses"] removeObject:value];
    [self didChangeValueForKey:@"lenses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addLenses:(NSSet *)value {    
    [self willChangeValueForKey:@"lenses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"lenses"] unionSet:value];
    [self didChangeValueForKey:@"lenses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeLenses:(NSSet *)value {
    [self willChangeValueForKey:@"lenses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"lenses"] minusSet:value];
    [self didChangeValueForKey:@"lenses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (void)updateStopDetailsWithDictionary:(NSDictionary *)stopDetailsDict {
    
    /*** get stop-details by: [stopDetailsDict objectForKet:@"details"] ****/
    
    /*** get stop-lenses-details by: [stopDetailsDict objectForKey:@"lenses"] ***/
    NSDictionary *lensesDict = [stopDetailsDict objectForKey:@"lenses"];
    for (NSString *key in lensesDict) {
        NSDictionary *lenseItems = [lensesDict objectForKey:key];
        NSArray * lenseItemsContents = [lenseItems objectForKey:@"contents"];
        TourLense *lense = [TourLense lenseWithItems:lenseItemsContents ofLenseType:key];
        [self addLensesObject:lense];
    }
}

+ (TourStop *)stopWithDictionary:(NSDictionary *)stopDict order:(NSInteger)order {
    TourStop *stop = [[CoreDataManager sharedManager] uniqueObjectForEntity:TourStopEntityName attribute:@"id" value:[stopDict objectForKey:@"id"]];
    
    if (!stop) {
        stop = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:TourStopEntityName];
        stop.id = [stopDict objectForKey:@"id"];
    }
    
    stop.order = [NSNumber numberWithInt:order];
    stop.latitude = [stopDict numberForKey:@"lat"];
    stop.longitude = [stopDict numberForKey:@"lon"];
    stop.subtitle = [stopDict stringForKey:@"subtitle"];
    stop.title = [stopDict stringForKey:@"title"];
    stop.photo = [TourMediaItem mediaItemForURL:[stopDict stringForKey:@"photo"]];
    stop.thumbnail = [TourMediaItem mediaItemForURL:[stopDict stringForKey:@"thumbnail"]];
    return stop;
                    
}

- (NSArray *)orderedLenses {
    NSArray *lenseTypes = [NSArray arrayWithObjects:@"info", @"insideout", @"fastfacts", @"innovation", @"history", nil];
    
    NSMutableArray *lenses = [NSMutableArray array];
    for (NSString *lenseType in lenseTypes) {
        for (TourLense *lense in self.lenses) {
            if([lense.lenseType isEqualToString:lenseType]) {
                [lenses addObject:lense];
                break;
            }
        }
    }
    return lenses;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude floatValue], [self.longitude floatValue]);
}

- (void)markVisited {
    self.visited = [NSNumber numberWithBool:YES];
}
@end

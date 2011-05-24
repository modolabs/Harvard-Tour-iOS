#import "TourStop.h"
#import "TourMediaItem.h"
#import "TourConstants.h"
#import "CoreDataManager.h"

@implementation TourStop
@dynamic subtitle;
@dynamic id;
@dynamic longitude;
@dynamic title;
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

+ (TourStop *)stopWithDictionary:(NSDictionary *)stopDict order:(NSInteger)order {
    TourStop *stop = [[CoreDataManager sharedManager] getObjectForEntity:TourStopEntityName attribute:@"id" value:[stopDict objectForKey:@"id"]];
    
    if (!stop) {
        stop = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:TourStopEntityName];
        stop.id = [stopDict objectForKey:@"id"];
    }
    
    stop.order = [NSNumber numberWithInt:order];
    stop.latitude = [stopDict objectForKey:@"lat"];
    stop.longitude = [stopDict objectForKey:@"lon"];
    stop.subtitle = [stopDict objectForKey:@"subtitle"];
    stop.title = [stopDict objectForKey:@"title"];
    stop.photo = [TourMediaItem mediaItemForURL:[stopDict objectForKey:@"photo"]];
    stop.thumbnail = [TourMediaItem mediaItemForURL:[stopDict objectForKey:@"thumbnail"]];
    return stop;
                    
}

@end

#import "TourDataManager.h"
#import "TourConstants.h"
#import "TourStop.h"
#import "CoreDataManager.h"
#import "JSON.h"

#define CURRENT_TOUR_STOP_KEY @"currentTourStop"
#define INITIAL_TOUR_STOP_KEY @"initialTourStop"

@interface TourDataManager (Private)
- (NSInteger)countStops;
- (TourStop *)stopForIndex:(NSInteger)index;
@end

@implementation TourDataManager

+ (TourDataManager *)sharedManager {
	static TourDataManager *sharedInstance = nil;
	if (!sharedInstance) {
		sharedInstance = [TourDataManager new];
	}
	return sharedInstance;
}

- (NSInteger)countStops {
    if(!stopsCount) {

        // check if stops already loaded into core data
        NSManagedObjectContext *context = [[CoreDataManager sharedManager] managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:TourStopEntityName
                                   inManagedObjectContext:context]];
    
        [request setIncludesSubentities:NO];
        NSError *error = nil;
        stopsCount = [context countForFetchRequest:request error:&error];
        [request release];
    }
    return stopsCount;
}

- (void)loadStopSummarys {
    if(stopSummarysLoaded) {
        return;
    }
    
    // check if stops already loaded into core data    
    if([self countStops] == 0) {
        NSString *stopsJsonPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"data/stops.json"];
        NSData *stopsJsonData = [NSData dataWithContentsOfFile:stopsJsonPath];
        SBJsonParser *jsonParser = [[[SBJsonParser alloc] init] autorelease];        
        NSArray *stopDicts = [jsonParser objectWithData:stopsJsonData];
                              
        for(NSInteger i = 0; i < [stopDicts count]; i++) {
            NSDictionary *stopDict = [stopDicts objectAtIndex:i];
            NSDictionary *stopDetailsDict = [stopDict objectForKey:@"details"];
            [TourStop stopWithDictionary:stopDetailsDict order:i];
        }
        [[CoreDataManager sharedManager] saveData];
    }
    
    stopSummarysLoaded = YES;
}

- (TourStop *)stopForIndex:(NSInteger)index {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"order = %d", index];
    return [[[CoreDataManager sharedManager] objectsForEntity:TourStopEntityName
                                            matchingPredicate:pred] lastObject];
}

- (TourStop *)getFirstStop {
    return [self stopForIndex:0];
}

- (NSArray *)getAllTourStops {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    return [[CoreDataManager sharedManager] objectsForEntity:TourStopEntityName 
                                           matchingPredicate:nil 
                                             sortDescriptors:[NSArray arrayWithObject:sort]];
}

- (NSArray *)getTourStopsForInitialStop:(TourStop *)stop {
    NSArray *allStops = [self getAllTourStops];
    NSInteger firstStopIndex = [[stop order] intValue];
    NSRange rangeOfFirstStops = NSMakeRange(firstStopIndex, allStops.count - firstStopIndex);
    NSRange rangeOfLastStops = NSMakeRange(0, firstStopIndex);
    NSArray *firstStops = [allStops subarrayWithRange:rangeOfFirstStops];
    NSArray *lastStops = [allStops subarrayWithRange:rangeOfLastStops];
    return [firstStops arrayByAddingObjectsFromArray:lastStops];
}

- (void)markAllStopsUnvisited {
    NSArray *stops = [[CoreDataManager sharedManager] objectsForEntity:TourStopEntityName matchingPredicate:nil];
    for(TourStop *stop in stops) {
        stop.visited = [NSNumber numberWithBool:NO];
    }
    [[CoreDataManager sharedManager] saveData];
}

- (void)populateTourStopDetails:(TourStop *)tourStop {
    if(tourStop.lenses.count == 0) {
        NSString *stopDetailsJsonPath = [[[NSBundle mainBundle] bundlePath] 
            stringByAppendingPathComponent:[NSString stringWithFormat:@"data/stops/%@/content.json", tourStop.id]];
        NSData *stopDetailsJsonBytes = [NSData dataWithContentsOfFile:stopDetailsJsonPath];
        SBJsonParser *jsonParser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *tourStopDetailsDict = [jsonParser objectWithData:stopDetailsJsonBytes];
        [tourStop updateStopDetailsWithDictionary:tourStopDetailsDict];
        [[CoreDataManager sharedManager] saveData];
    }
}

- (NSArray *) retrieveAndAssignWelcomeText {
    
    NSString *pagesJsonPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"data/pages.json"];
    NSData *pagesJsonData = [NSData dataWithContentsOfFile:pagesJsonPath];
    SBJsonParser *jsonParser = [[[SBJsonParser alloc] init] autorelease];        
    NSDictionary *pagesDict = [jsonParser objectWithData:pagesJsonData];
    
    NSDictionary * pagesDetailsDict = [pagesDict objectForKey:@"pages"];
    NSArray * welcomeArray = [pagesDetailsDict objectForKey:@"welcome"];
    return welcomeArray;
}

- (void)saveInitialStop:(TourStop *)tourStop {
    [[NSUserDefaults standardUserDefaults] setValue:tourStop.id forKey:INITIAL_TOUR_STOP_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveCurrentStop:(TourStop *)tourStop {
    [[NSUserDefaults standardUserDefaults] setValue:tourStop.id forKey:CURRENT_TOUR_STOP_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (TourStop *)getStopByID:(NSString *)id {
    return [[CoreDataManager sharedManager] getObjectForEntity:TourStopEntityName attribute:@"id" value:id];
}

- (TourStop *)getCurrentStop {
    NSString *currentStopID = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_TOUR_STOP_KEY];
    if (currentStopID) {
        return [self getStopByID:currentStopID];
    } else {
        return nil;
    }
}

- (TourStop *)getInitialStop {
    NSString *initialStopID = [[NSUserDefaults standardUserDefaults] objectForKey:INITIAL_TOUR_STOP_KEY];
    if (initialStopID) {
        return [self getStopByID:initialStopID];
    } else {
        return nil;
    }
}

- (TourStop *)lastTourStopForFirstTourStop:(TourStop *)startingTourStop {
    if([startingTourStop.order intValue] == 0) {
        return [self stopForIndex:([self countStops] - 1)];
    } else {
        return [self stopForIndex:([startingTourStop.order intValue] - 1)];
    }
}

- (TourStop *)previousStopForTourStop:(TourStop *)stop {
    NSInteger index = [stop.order intValue];
    if (index == 0) {
        return [self stopForIndex:([self countStops] - 1)];
    } else {
        return [self stopForIndex:(index - 1)];
    }
}

- (TourStop *)nextStopForTourStop:(TourStop *)stop {
    NSInteger index = [stop.order intValue];
    if (index == [self countStops]-1) {
        return [self getFirstStop];
    } else {
        return [self stopForIndex:index+1];
    }   
}

@end

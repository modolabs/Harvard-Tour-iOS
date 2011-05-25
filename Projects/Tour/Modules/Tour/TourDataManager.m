#import "TourDataManager.h"
#import "TourConstants.h"
#import "TourStop.h"
#import "CoreDataManager.h"
#import "JSON.h"


@implementation TourDataManager

+ (TourDataManager *)sharedManager {
	static TourDataManager *sharedInstance = nil;
	if (!sharedInstance) {
		sharedInstance = [TourDataManager new];
	}
	return sharedInstance;
}

- (void)loadStopSummarys {
    if(stopSummarysLoaded) {
        return;
    }
    
    // check if stops already loaded into core data
    NSManagedObjectContext *context = [[CoreDataManager sharedManager] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:TourStopEntityName
                                   inManagedObjectContext:context]];
    
    [request setIncludesSubentities:NO];
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    if(count == 0) {
        NSString *stopsJsonPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"data/stops.json"];
        NSData *stopsJsonBytes = [NSData dataWithContentsOfFile:stopsJsonPath];
        NSString *stopsJsonString = [[[NSString alloc] initWithData:stopsJsonBytes encoding:NSUTF8StringEncoding] autorelease];
        SBJsonParser *jsonParser = [[[SBJsonParser alloc] init] autorelease];
        
        NSError *error = nil;
        NSArray *stopDicts = [jsonParser objectWithString:stopsJsonString error:&error];
        for(NSInteger i = 0; i < [stopDicts count]; i++) {
            NSDictionary *stopDict = [stopDicts objectAtIndex:i];
            [TourStop stopWithDictionary:stopDict order:i];
        }
        [[CoreDataManager sharedManager] saveData];
    }
    
    stopSummarysLoaded = YES;
}

- (TourStop *)getFirstStop {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"order = %d", 0];
    return [[[CoreDataManager sharedManager] objectsForEntity:TourStopEntityName
                                                               matchingPredicate:pred] lastObject];
}

- (NSArray *)getAllTourStops {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    return [[CoreDataManager sharedManager] objectsForEntity:TourStopEntityName 
                                           matchingPredicate:nil 
                                             sortDescriptors:[NSArray arrayWithObject:sort]];
}
@end

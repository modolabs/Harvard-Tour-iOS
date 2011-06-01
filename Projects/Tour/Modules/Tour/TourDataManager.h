#import <Foundation/Foundation.h>

#import "TourStop.h"
#import "TourMediaItem.h"

@interface TourDataManager : NSObject {
    BOOL stopSummarysLoaded;
    NSInteger stopsCount;
}

+ (TourDataManager *)sharedManager;
- (void)loadStopSummarys;
- (void)populateTourStopDetails:(TourStop *)tourStop;

- (TourStop *)getFirstStop;
- (NSArray *)getAllTourStops;
- (void)markAllStopsUnvisited;

- (TourStop *)lastTourStopForFirstTourStop:(TourStop *)startingTourStop;
- (TourStop *)previousStopForTourStop:(TourStop *)stop;
- (TourStop *)nextStopForTourStop:(TourStop *)stop;

@end

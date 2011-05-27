#import <Foundation/Foundation.h>

#import "TourStop.h"
#import "TourMediaItem.h"

@interface TourDataManager : NSObject {
    BOOL stopSummarysLoaded;
    NSInteger stopsCount;
}

+ (TourDataManager *)sharedManager;
- (void)loadStopSummarys;
- (TourStop *)getFirstStop;
- (NSArray *)getAllTourStops;

- (TourStop *)lastTourStopForFirstTourStop:(TourStop *)startingTourStop;
- (TourStop *)previousStopForTourStop:(TourStop *)stop;
- (TourStop *)nextStopForTourStop:(TourStop *)stop;

@end

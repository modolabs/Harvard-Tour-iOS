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
- (NSArray *)retrieveWelcomeText;
- (NSArray *)finishText;

- (void)saveInitialStop:(TourStop *)tourStop;
- (TourStop *)getInitialStop;
- (void)saveCurrentStop:(TourStop *)tourStop;
- (TourStop *)getCurrentStop;

- (TourStop *)getFirstStop;
- (NSArray *)getAllTourStops;
- (NSArray *)getTourStopsForInitialStop:(TourStop *)stop;
- (void)markAllStopsUnvisited;

- (TourStop *)lastTourStopForFirstTourStop:(TourStop *)startingTourStop;
- (TourStop *)previousStopForTourStop:(TourStop *)stop;
- (TourStop *)nextStopForTourStop:(TourStop *)stop;

+ (NSString *)stripHTMLTagsFromString:(NSString *)rawString;

@end

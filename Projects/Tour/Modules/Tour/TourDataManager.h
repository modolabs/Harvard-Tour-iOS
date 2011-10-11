
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

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
- (NSArray *)pagesTextArray:(NSString *)sectionName;

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

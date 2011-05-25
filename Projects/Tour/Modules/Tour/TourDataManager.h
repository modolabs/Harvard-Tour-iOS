//
//  TourDataManager.h
//  Tour
//
//  Created by Brian Patt on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TourStop.h"
#import "TourMediaItem.h"

@interface TourDataManager : NSObject {
    BOOL stopSummarysLoaded;
}

+ (TourDataManager *)sharedManager;
- (void)loadStopSummarys;
- (TourStop *)getFirstStop;
- (NSArray *)getAllTourStops;
@end

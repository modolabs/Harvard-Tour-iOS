
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TourLenseItem.h"

@class TourMediaItem;

@interface TourLenseVideoItem : TourLenseItem {
@private
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) TourMediaItem * video;

+ (TourLenseVideoItem *)itemWithDictionary:(NSDictionary *)itemDict;

@end


/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TourMediaItem.h"


@interface TourSlide : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) TourMediaItem * photo;

+ (TourSlide *)slideWithDictionary:(NSDictionary *)slideDict;

@end

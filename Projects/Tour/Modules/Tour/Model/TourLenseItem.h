
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TourLense;

@interface TourLenseItem : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) TourLense * lense;

@end

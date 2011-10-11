
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TourLenseItem, TourStop;

@interface TourLense : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * lenseType;
@property (nonatomic, retain) TourStop * stop;
@property (nonatomic, retain) NSSet* lenseItems;

+ (TourLense *)lenseWithItems:(NSArray *)lenseItems ofLenseType:(NSString *)lenseType;

- (NSArray *)orderedItems;

@end

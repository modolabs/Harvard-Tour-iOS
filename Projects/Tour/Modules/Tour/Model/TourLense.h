//
//  TourLense.h
//  Tour
//
//  Created by Brian Patt on 5/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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

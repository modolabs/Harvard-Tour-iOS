//
//  TourLenseItem.h
//  Tour
//
//  Created by Brian Patt on 5/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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

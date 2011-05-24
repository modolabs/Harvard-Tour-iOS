//
//  TourLense.h
//  Tour
//
//  Created by Brian Patt on 5/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TourStop;

@interface TourLense : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * lenseType;
@property (nonatomic, retain) TourStop * parent;

@end

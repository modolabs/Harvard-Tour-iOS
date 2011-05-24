//
//  TourLenseSlideShowItem.h
//  Tour
//
//  Created by Brian Patt on 5/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TourLenseItem.h"

@class TourSlide;

@interface TourLenseSlideShowItem : TourLenseItem {
@private
}
@property (nonatomic, retain) NSSet* slides;

@end

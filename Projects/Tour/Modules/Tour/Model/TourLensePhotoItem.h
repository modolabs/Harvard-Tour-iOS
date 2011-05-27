//
//  TourLensePhotoItem.h
//  Tour
//
//  Created by Brian Patt on 5/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TourLenseItem.h"

@class TourMediaItem;

@interface TourLensePhotoItem : TourLenseItem {
@private
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) TourMediaItem * photo;

+ (TourLensePhotoItem *)itemWithDictionary:(NSDictionary *)itemDict;

@end

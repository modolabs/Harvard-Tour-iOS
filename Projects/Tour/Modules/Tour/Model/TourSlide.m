
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "CoreDataManager.h"
#import "Foundation+KGOAdditions.h"
#import "TourConstants.h"
#import "TourMediaItem.h"
#import "TourSlide.h"

@implementation TourSlide
@dynamic order;
@dynamic title;
@dynamic photo;

+ (TourSlide *)slideWithDictionary:(NSDictionary *)slideDict {
    TourSlide *slide = [[CoreDataManager sharedManager] 
                                insertNewObjectForEntityForName:TourSlideEntityName];
    slide.title = [slideDict stringForKey:@"title"];
    slide.photo = [TourMediaItem mediaItemForURL:[slideDict stringForKey:@"url"]];
    return slide;
}

@end

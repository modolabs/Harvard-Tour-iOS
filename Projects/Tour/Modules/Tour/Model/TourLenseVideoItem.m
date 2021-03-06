
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "TourLenseVideoItem.h"
#import "TourMediaItem.h"
#import "Foundation+KGOAdditions.h"
#import "CoreDataManager.h"
#import "TourMediaItem.h"
#import "TourConstants.h"

@implementation TourLenseVideoItem
@dynamic title;
@dynamic video;

+ (TourLenseVideoItem *)itemWithDictionary:(NSDictionary *)itemDict {
    TourLenseVideoItem *item = [[CoreDataManager sharedManager] 
                                insertNewObjectForEntityForName:TourLenseVideoItemEntityName];
    item.title = [itemDict stringForKey:@"title"];
    item.video = [TourMediaItem mediaItemForURL:[itemDict stringForKey:@"url"]];
    return item;
}

@end

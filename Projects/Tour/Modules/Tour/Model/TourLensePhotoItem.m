
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "TourLensePhotoItem.h"
#import "TourMediaItem.h"
#import "TourConstants.h"
#import "Foundation+KGOAdditions.h"
#import "CoreDataManager.h"

@implementation TourLensePhotoItem
@dynamic title;
@dynamic photo;


+ (TourLensePhotoItem *)itemWithDictionary:(NSDictionary *)itemDict {
    TourLensePhotoItem *item = [[CoreDataManager sharedManager] 
                                insertNewObjectForEntityForName:TourLensePhotoItemEntityName];
    item.title = [itemDict stringForKey:@"title"];
    item.photo = [TourMediaItem mediaItemForURL:[itemDict stringForKey:@"url"]];
    return item;
}

@end

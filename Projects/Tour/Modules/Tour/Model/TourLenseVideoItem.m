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
                                insertNewObjectForEntityForName:TourLensePhotoItemEntityName];
    item.title = [itemDict stringForKey:@"title" nilIfEmpty:NO];
    item.video = [TourMediaItem mediaItemForURL:[itemDict stringForKey:@"url" nilIfEmpty:NO]];
    return item;
}

@end

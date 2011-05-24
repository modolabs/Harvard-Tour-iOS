#import "TourMediaItem.h"
#import "CoreDataManager.h"
#import "TourConstants.h"


@implementation TourMediaItem
@dynamic URL;
@dynamic mediaData;

+ (TourMediaItem *)mediaItemForURL:(NSString *)url {
    TourMediaItem *mediaItem = [[CoreDataManager sharedManager] getObjectForEntity:TourMediaItemEntityName attribute:@"URL" value:url];
    
    if (!mediaItem) {
        mediaItem = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:TourMediaItemEntityName];
        mediaItem.URL = url;
    }
    return mediaItem;
}
@end

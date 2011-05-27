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
    slide.title = [slideDict stringForKey:@"title" nilIfEmpty:NO];
    slide.photo = [TourMediaItem mediaItemForURL:[slideDict stringForKey:@"url" nilIfEmpty:NO]];
    return slide;
}

@end

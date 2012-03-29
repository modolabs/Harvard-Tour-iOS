
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "CoreDataManager.h"
#import "Foundation+KGOAdditions.h"
#import "TourLenseHtmlItem.h"
#import "TourConstants.h"


@implementation TourLenseHtmlItem
@dynamic html;


+ (TourLenseHtmlItem *)itemWithDictionary:(NSDictionary *)itemDict {
    TourLenseHtmlItem *item = [[CoreDataManager sharedManager] 
                               insertNewObjectForEntityForName:TourLenseHtmlItemEntityName];
    item.html = [itemDict stringForKey:@"html"];
    return item;
}

@end

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TourLenseItem.h"

@class TourSlide;

/*
 * TODO: Maybe
 * This assumes slides are slideShows of photos, a more general implementation
 * is tricky to do given some of core datas constraints (like relationships needing inverses)
 */
@interface TourLenseSlideShowItem : TourLenseItem {
@private
}
@property (nonatomic, retain) NSSet* slides;

+ (TourLenseSlideShowItem *)itemWithDictionary:(NSDictionary *)slideShowDict;

@end

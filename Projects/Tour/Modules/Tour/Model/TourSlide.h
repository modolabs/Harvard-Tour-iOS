#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TourSlide : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSManagedObject * photo;

+ (TourSlide *)slideWithDictionary:(NSDictionary *)slideDict;

@end

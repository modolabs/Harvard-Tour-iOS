#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TourSlide : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSManagedObject * photo;

@end

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NewsStory;

@interface NewsCategory : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * category_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) ModuleTag * moduleTag;
@property (nonatomic, retain) NSNumber * moreStories;
@property (nonatomic, retain) NSNumber * showBodyThumbnail;
@property (nonatomic, retain) NSString * url; // may not be needed
@property (nonatomic, retain) NSSet* stories;

// Added in v3
@property (nonatomic, retain) NSNumber * sortOrder;

@end

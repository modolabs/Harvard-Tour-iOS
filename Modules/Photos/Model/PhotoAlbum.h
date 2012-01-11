#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MITThumbnailView.h"

@class Photo;

@interface PhotoAlbum : NSManagedObject <MITThumbnailDelegate>

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSNumber * totalItems;
@property (nonatomic, retain) NSData * thumbData;
@property (nonatomic, retain) NSSet *photos;

+ (PhotoAlbum *)albumWithDictionary:(NSDictionary *)dictionary;
+ (PhotoAlbum *)albumWithID:(NSString *)identifier canCreate:(BOOL)canCreate;
- (void)updateWithDictionary:(NSDictionary *)dictionary;

- (NSString *)albumSize; // returns localized version of "# photos"
- (NSString *)lastUpdateString; // return localized "Updated # days ago"

@end

@interface PhotoAlbum (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
@end

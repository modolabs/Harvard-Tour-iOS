#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MITThumbnailView.h"
#import "KGOSearchModel.h"

@class PhotoAlbum;

@interface Photo : NSManagedObject <KGOSearchResult, MITThumbnailDelegate>

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSData * thumbData;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) PhotoAlbum *album;

@property (nonatomic, retain) ModuleTag *moduleTag;
@property (nonatomic, retain) MITThumbnailView *thumbView; // thumbnail view in grid, not detail

+ (Photo *)photoWithDictionary:(NSDictionary *)dictionary;
+ (Photo *)photoWithID:(NSString *)identifier canCreate:(BOOL)canCreate;
- (void)updateWithDictionary:(NSDictionary *)dictionary;
- (NSString *)lastUpdateString;

@end

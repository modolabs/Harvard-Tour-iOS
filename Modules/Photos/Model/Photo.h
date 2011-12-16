#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MITThumbnailView.h"

@interface Photo : NSManagedObject <MITThumbnailDelegate>

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSData * thumbData;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSManagedObject *album;

+ (Photo *)photoWithDictionary:(NSDictionary *)dictionary;
+ (Photo *)photoWithID:(NSString *)identifier canCreate:(BOOL)canCreate;
- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end

#import <CoreData/CoreData.h>

@class Video;

@interface VideoTag :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Video * includedInVideos;

@end




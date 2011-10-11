
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TourMediaItem : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * URL;

+ (TourMediaItem *)mediaItemForURL:(NSString *)url;

- (NSString *)mediaFilePath;
- (UIImage *)image;

@end

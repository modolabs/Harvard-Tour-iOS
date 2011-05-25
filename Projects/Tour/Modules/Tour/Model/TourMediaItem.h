//
//  TourMediaItem.h
//  Tour
//
//  Created by Brian Patt on 5/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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

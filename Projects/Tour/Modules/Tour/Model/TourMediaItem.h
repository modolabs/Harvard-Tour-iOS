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
@property (nonatomic, retain) NSData * mediaData;

+ (TourMediaItem *)mediaItemForURL:(NSString *)url;

@end

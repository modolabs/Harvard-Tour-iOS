//
//  AthleticsStory.h
//  Universitas
//
//  Created by Liu Mingxing on 12/6/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AthleticsImage.h"

@interface AthleticsStory : NSManagedObject {
}
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSNumber * hasBody;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSDate * postDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * topStory;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSNumber * searchResult;
@property (nonatomic, retain) NSNumber * bookmarked;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) AthleticsImage * thumbImage;
@property (nonatomic, retain) AthleticsImage * featuredImage;
@property (nonatomic, retain)  NSString *moduleTag;


@end

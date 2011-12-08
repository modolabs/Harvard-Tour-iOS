//
//  AthleticsCategory.h
//  Universitas
//
//  Created by Liu Mingxing on 12/8/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AthleticsStory;

@interface AthleticsCategory : NSManagedObject

@property (nonatomic, retain) NSString * category_id;
@property (nonatomic, retain) NSNumber * isMainCategory;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * moduleTag;
@property (nonatomic, retain) NSNumber * moreStories;
@property (nonatomic, retain) NSNumber * nextSeekId;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *stories;

@end

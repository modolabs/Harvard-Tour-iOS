//
//  AthleticsCategory.h
//  Universitas
//
//  Created by Liu Mingxing on 12/15/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AthleticsMenu, AthleticsStory;

@interface AthleticsCategory : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * category_id;
@property (nonatomic, retain) NSNumber * isMainCategory;
@property (nonatomic, retain) NSString * ivar;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * moduleTag;
@property (nonatomic, retain) NSNumber * moreStories;
@property (nonatomic, retain) NSNumber * nextSeekId;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *stories;
@property (nonatomic, retain) AthleticsMenu *menu;
@end

@interface AthleticsCategory (CoreDataGeneratedAccessors)

- (void)addStoriesObject:(AthleticsStory *)value;
- (void)removeStoriesObject:(AthleticsStory *)value;
- (void)addStories:(NSSet *)values;
- (void)removeStories:(NSSet *)values;

@end

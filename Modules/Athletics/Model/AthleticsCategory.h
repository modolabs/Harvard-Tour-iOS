//
//  AthleticsCategory.h
//  Universitas
//
//  Created by Liu Mingxing on 12/7/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface AthleticsCategory : NSManagedObject {
    
}
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * nextSeekId;
@property (nonatomic, retain) NSString * category_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) ModuleTag * moduleTag;
@property (nonatomic, retain) NSNumber * isMainCategory;
@property (nonatomic, retain) NSNumber * moreStories;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet* stories;

// Added in v3
@property (nonatomic, retain) NSNumber * sortOrder;
@end

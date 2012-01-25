//
//  AthleticsImage.h
//  Universitas
//
//  Created by Liu Mingxing on 12/8/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AthleticsStory;

@interface AthleticsImage : NSManagedObject

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * ordinality;
@property (nonatomic, retain) NSString * credits;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) AthleticsStory *thumbParent;
@property (nonatomic, retain) AthleticsStory *featuredParent;

@end

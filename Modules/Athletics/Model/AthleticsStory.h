//
//  AthleticsStory.h
//  Universitas
//
//  Created by Liu Mingxing on 12/6/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AthleticsImage.h"
@interface AthleticsStory : NSObject {
    NSString *title;
    AthleticsImage *thumbImage;
}
@property (nonatomic, retain)  NSString *title;
@property (nonatomic, retain)  AthleticsImage *thumbImage;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain)  NSString *identifier;
@property (nonatomic, retain)  NSString *link;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * hasBody;
@end

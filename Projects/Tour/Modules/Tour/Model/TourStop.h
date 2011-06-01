//
//  TourStop.h
//  Tour
//
//  Created by Brian Patt on 5/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>


@interface TourStop : NSManagedObject <MKAnnotation> {
@private
}
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * visited;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSManagedObject * thumbnail;
@property (nonatomic, retain) NSSet* lenses;
@property (nonatomic, retain) NSManagedObject * photo;

+ (TourStop *)stopWithDictionary:(NSDictionary *)stopDict order:(NSInteger)integer;
- (void)updateStopDetailsWithDictionary:(NSDictionary *)stopDetailsDict;

- (NSArray *)orderedLenses;

- (void)markVisited;

@end

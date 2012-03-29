
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>


@interface TourStop : NSManagedObject <MKAnnotation> {
@private
}
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, copy) NSString * title;
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

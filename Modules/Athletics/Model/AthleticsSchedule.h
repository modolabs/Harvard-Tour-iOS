#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AthleticsCategory;

@interface AthleticsSchedule : NSManagedObject

@property (nonatomic, retain) NSNumber * allDay;
@property (nonatomic, retain) NSString * descriptionString;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * schedule_id;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * locationLabel;
@property (nonatomic, retain) NSNumber * pastStatus;
@property (nonatomic, retain) NSString * sport;
@property (nonatomic, retain) NSString * sportName;
@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) AthleticsCategory *category;

@end

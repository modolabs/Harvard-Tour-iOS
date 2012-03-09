#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "KGOSearchModel.h"
#import <EventKitUI/EventKitUI.h>

@class CalendarDataManager, KGOCalendar, EKEvent;

@interface KGOEvent : NSManagedObject <KGOSearchResult, EKEventEditViewDelegate> {
@private
}
@property (nonatomic, retain) NSNumber * bookmarked;
@property (nonatomic, retain) NSString * briefLocation;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * placemarkID;
@property (nonatomic, retain) NSData * rrule;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * userInfo;
@property (nonatomic, retain) NSSet* calendars;

// new in v2:
@property (nonatomic, retain) NSNumber * allDay;
@property (nonatomic, retain) NSData * fields;

// new in v3. gone: participants
@property (nonatomic, retain) NSSet* attendees;
@property (nonatomic, retain) NSString * ekIdentifier;
@property (nonatomic, retain) NSSet* organizers;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

+ (KGOEvent *)eventWithDictionary:(NSDictionary *)dictionary module:(ModuleTag *)moduleTag;
+ (KGOEvent *)eventWithID:(NSString *)identifier module:(ModuleTag *)moduleTag;
+ (KGOEvent *)findEventWithID:(NSString *)identifier module:(ModuleTag *)moduleTag;

// expose core data generated method

- (void)addCalendarsObject:(KGOCalendar *)value;

// non cached properties

@property (nonatomic, assign) CalendarDataManager *dataManager;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSArray *fieldsArray;
@property (nonatomic, retain) EKEvent *ekEvent;

// eventKit

- (EKEvent *)eventForEventStore;
- (void)deleteFromEventStore;
- (UIViewController *)eventViewController;

@end

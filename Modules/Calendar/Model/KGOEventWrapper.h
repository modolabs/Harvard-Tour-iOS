#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "KGOSearchModel.h"

@class EKEvent, KGOEvent, KGOAttendeeWrapper, KGOCalendar,
EKEventEditViewController, CalendarDataManager;

@interface KGOEventWrapper : NSObject <KGOSearchResult, MKAnnotation> {
    
    EKEvent *_ekEvent;
    KGOEvent *_kgoEvent;
    
    NSSet *_attendees;
    NSSet *_organizers; // KGOEventParticipant, EKParticipant
    
    // not yet supported EKEvent properties: alarms, availability, isDetached,
    // status, calendar (this will be always set to local) 
}

// same type in eventkit and core data
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDate *lastUpdate; // lastModifiedDate in EKEvent
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *summary;  // notes in EKEvent
@property (nonatomic) BOOL allDay;                // comes out of userInfo

// different type in eventkit and core data
@property (nonatomic, retain) NSDictionary *rrule; // recurrenceRule in EKEvent
@property (nonatomic, retain) NSSet *organizers;   // set of KGOAttendeeWrapper objects
@property (nonatomic, retain) NSSet *attendees;    // set of KGOAttendeeWrapper objects
@property (nonatomic, retain) NSString *ekIdentifier;

// core data only -- no eventkit counterpart
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSMutableSet *calendars;
@property (nonatomic) BOOL bookmarked;
@property (nonatomic, retain) NSString *briefLocation;
@property (nonatomic, retain) NSDictionary *fields;
@property (nonatomic, retain) NSDictionary *userInfo;

// set by the data controller
@property (nonatomic, retain) ModuleTag *moduleTag; // TODO: remove moduleTag
@property (nonatomic, assign) CalendarDataManager *dataManager;

// server api

- (id)initWithDictionary:(NSDictionary *)dictionary module:(ModuleTag *)moduleTag;
- (void)updateWithDictionary:(NSDictionary *)dictionary;

// eventkit

- (id)initWithEKEvent:(EKEvent *)event;
- (EKEvent *)convertToEKEvent;
- (BOOL)saveToEventStore;
- (EKEventEditViewController *)editViewController;

@property (nonatomic, retain) EKEvent *EKEvent; // setting this will override core data if saved

// core data

- (id)initWithKGOEvent:(KGOEvent *)event;
- (KGOEvent *)convertToKGOEvent;
- (void)saveToCoreData;
- (void)addCalendar:(KGOCalendar *)aCalendar;
- (NSSet *)unwrappedOrganizers;
- (NSSet *)unwrappedAttendees;

@property (nonatomic, retain) KGOEvent *KGOEvent; // setting this will override eventkit if saved

// subclass properties

- (NSString *)placemarkID;

@end

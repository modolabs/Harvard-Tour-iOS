#import <Foundation/Foundation.h>
#import "CalendarModel.h"
#import "KGORequestManager.h"

@protocol CalendarDataManagerDelegate <NSObject>

@optional

- (void)groupsDidChange:(NSArray *)groups;
- (void)groupDataDidChange:(KGOCalendarGroup *)group;
- (void)eventsDidChange:(NSArray *)events
               calendar:(KGOCalendar *)calendar
       didReceiveResult:(BOOL)receivedResult; // didReceiveResult is a misnomer for "came from network"
- (void)eventDetailsDidChange:(KGOEvent *)event;

@end

@class KGOCalendarGroup, EKEventStore;

@interface CalendarDataManager : NSObject <KGORequestDelegate> {
    
    KGOCalendarGroup *_currentGroup;
    
    KGORequest *_groupsRequest;
    NSMutableDictionary *_categoriesRequests;
    NSMutableDictionary *_eventsRequests;
    NSMutableDictionary *_detailRequests;
    NSMutableDictionary *_detailRequestEvents;
    
    NSDictionary *_dateFormatters;
    
    EKEventStore *_eventStore;
    
}

@property (nonatomic, assign) id<CalendarDataManagerDelegate> delegate;
@property (nonatomic, readonly) KGOCalendarGroup *currentGroup;
@property (nonatomic, retain) ModuleTag *moduleTag;
@property (nonatomic, readonly) EKEventStore *eventStore;

- (BOOL)requestGroups;
- (BOOL)requestCalendarsForGroup:(KGOCalendarGroup *)group;

- (BOOL)requestEventsForCalendar:(KGOCalendar *)calendar params:(NSDictionary *)params;
- (BOOL)requestEventsForCalendar:(KGOCalendar *)calendar startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (BOOL)requestEventsForCalendar:(KGOCalendar *)calendar time:(NSDate *)time;
- (BOOL)requestEventsForCalendar:(KGOCalendar *)calendar start:(NSDate *)start limit:(NSInteger)limit;
- (BOOL)requestDetailsForEvent:(KGOEvent *)event;

- (void)selectGroupAtIndex:(NSInteger)index;

- (NSString *)mediumDateStringFromDate:(NSDate *)date;
- (NSString *)shortDateStringFromDate:(NSDate *)date;
- (NSString *)shortTimeStringFromDate:(NSDate *)date;
- (NSString *)shortDateTimeStringFromDate:(NSDate *)date;

- (NSString *)dateTimeStringForEvent:(KGOEvent *)event multiline:(BOOL)multiline;

@end

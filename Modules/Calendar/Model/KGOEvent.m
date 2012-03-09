#import "KGOEvent.h"
#import "KGOCalendar.h"
#import "CoreDataManager.h"
#import "UIKit+KGOAdditions.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "Foundation+KGOAdditions.h"
#import "CalendarDataManager.h"
#import <EventKit/EventKit.h>

NSString * const KGOEntityNameEvent = @"KGOEvent";

@implementation KGOEvent
@dynamic allDay;
@dynamic bookmarked;
@dynamic briefLocation;
@dynamic ekIdentifier;
@dynamic endDate;
@dynamic fields;
@dynamic identifier;
@dynamic lastUpdate;
@dynamic latitude;
@dynamic location;
@dynamic longitude;
@dynamic placemarkID;
@dynamic rrule;
@dynamic startDate;
@dynamic summary;
@dynamic title;
@dynamic userInfo;
@dynamic attendees;
@dynamic calendars;
@dynamic organizers;

@synthesize dataManager = _dataManager, coordinate = _coordinate, ekEvent = _ekEvent;

+ (KGOEvent *)findEventWithID:(NSString *)identifier
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    KGOEvent *event = [[[CoreDataManager sharedManager] objectsForEntity:KGOEntityNameEvent matchingPredicate:pred] lastObject];
    return event;
    
}

+ (KGOEvent *)eventWithID:(NSString *)identifier
{
    KGOEvent *event = [KGOEvent findEventWithID:identifier];
    if (!event) {
        event = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:KGOEntityNameEvent];
        event.identifier = identifier;
    }
    return event;
}

+ (KGOEvent *)eventWithDictionary:(NSDictionary *)dictionary module:(ModuleTag *)moduleTag
{
    NSString *identifier = [dictionary nonemptyStringForKey:@"id"];
    if (!identifier) {
        return nil;
    }
    KGOEvent *event = [self eventWithID:identifier module:moduleTag];
    [event updateWithDictionary:dictionary];
    return event;
}

- (void)addCalendarsObject:(KGOCalendar *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"calendars" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"calendars"] addObject:value];
    [self didChangeValueForKey:@"calendars" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCalendarsObject:(KGOCalendar *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"calendars" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"calendars"] removeObject:value];
    [self didChangeValueForKey:@"calendars" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addCalendars:(NSSet *)value {    
    [self willChangeValueForKey:@"calendars" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"calendars"] unionSet:value];
    [self didChangeValueForKey:@"calendars" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCalendars:(NSSet *)value {
    [self willChangeValueForKey:@"calendars" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"calendars"] minusSet:value];
    [self didChangeValueForKey:@"calendars" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addParticpantsObject:(KGOEventParticipantRelation *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"particpants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"particpants"] addObject:value];
    [self didChangeValueForKey:@"particpants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeParticpantsObject:(KGOEventParticipantRelation *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"particpants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"particpants"] removeObject:value];
    [self didChangeValueForKey:@"particpants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addParticpants:(NSSet *)value {    
    [self willChangeValueForKey:@"particpants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"particpants"] unionSet:value];
    [self didChangeValueForKey:@"particpants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeParticpants:(NSSet *)value {
    [self willChangeValueForKey:@"particpants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"particpants"] minusSet:value];
    [self didChangeValueForKey:@"particpants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

// remove these methods when coredata branch is merged

+ (KGOEvent *)eventWithID:(NSString *)identifier module:(ModuleTag *)moduleTag
{
    return [[self class] eventWithID:identifier];
}

+ (KGOEvent *)findEventWithID:(NSString *)identifier module:(ModuleTag *)moduleTag
{
    return [[self class] findEventWithID:identifier];
}

#pragma mark - methods that used to be in KGOEventWrapper

#pragma mark - KGOSearchResult

- (UIImage *)annotationImage
{
    return [UIImage imageWithPathName:@"modules/calendar/event_map_pin"];
}

- (NSString *)subtitle
{
    if (!self.allDay) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        return [dateFormatter stringFromDate:self.startDate]; 
    } else {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        return [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:self.startDate], NSLocalizedString(@"CALENDAR_ALL_DAY_SUBTITLE", @"All day")];
    }
}

- (NSString *)moduleTag
{
    return self.dataManager.moduleTag;
}

- (BOOL)didGetSelected:(id)selector
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self, @"searchResult",nil];
    return [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail forModuleTag:self.dataManager.moduleTag params:params];
}

- (void)setFieldsArray:(NSArray *)fieldsArray
{
    self.fields = [NSKeyedArchiver archivedDataWithRootObject:fieldsArray];
}

- (NSArray *)fieldsArray
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.fields];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    // Title and description
    self.title = [dictionary nonemptyStringForKey:@"title"];
    self.summary = [dictionary nonemptyStringForKey:@"description"];
    
    // Location
    self.location = [dictionary nonemptyStringForKey:@"location"];
    self.briefLocation = [dictionary nonemptyStringForKey:@"locationLabel"]; // v2
    NSNumber *lat = [dictionary objectForKey:@"latitude"];
    NSNumber *lon = [dictionary objectForKey:@"longitude"];
    if (lat && lon && [lat isKindOfClass:[NSNumber class]] && [lon isKindOfClass:[NSNumber class]]) {
        self.coordinate = CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]);
    }
    
    // Date and Time
    NSTimeInterval startTimestamp = [[dictionary objectForKey:@"start"] doubleValue];
    NSTimeInterval endTimestamp = [[dictionary objectForKey:@"end"] doubleValue];
    NSNumber *allDay = [dictionary objectForKey:@"allday"]; // v2
    self.startDate = [NSDate dateWithTimeIntervalSince1970:startTimestamp];
    if (endTimestamp > startTimestamp) {
        self.endDate = [NSDate dateWithTimeIntervalSince1970:endTimestamp];
    }
    if (allDay && [allDay isKindOfClass:[NSNumber class]]) {
        self.allDay = allDay;
    } else {
        self.allDay = [NSNumber numberWithBool:(endTimestamp - startTimestamp) + 1 >= 24 * 60 * 60];
    }
    
    // Additional attributes
    self.fieldsArray = [dictionary objectForKey:@"fields"]; // v2
    
    self.lastUpdate = [NSDate date];
}

#pragma mark - EventKit

- (void)deleteFromEventStore
{
    if (self.ekIdentifier) {
        DLog(@"attempting to delete %@ from local calendar", self.title);
        EKEventStore *eventStore = self.dataManager.eventStore;
        EKEvent *event = [eventStore eventWithIdentifier:self.ekIdentifier];
        if (event) {
            NSError *error = nil;
            [eventStore removeEvent:event span:EKSpanFutureEvents error:&error];
        }
    }
}

- (EKEvent *)eventForEventStore
{
    EKEventStore *eventStore = self.dataManager.eventStore;
    if (self.ekIdentifier) {
        self.ekEvent = [eventStore eventWithIdentifier:self.ekIdentifier];
    }
    if (!self.ekEvent) {
        self.ekEvent = [EKEvent eventWithEventStore:eventStore];
        self.ekEvent.calendar = [eventStore defaultCalendarForNewEvents];
        self.ekEvent.location = self.location;
        self.ekEvent.title = self.title;
        self.ekEvent.endDate = self.endDate;
        self.ekEvent.startDate = self.startDate;
        self.ekEvent.notes = self.summary;
        self.ekEvent.allDay = [self.allDay boolValue];
    }
    
    return self.ekEvent;
}

- (UIViewController *)eventViewController
{
    EKEventEditViewController *evc = [[[EKEventEditViewController alloc] init] autorelease];
    evc.event = [self eventForEventStore];
    evc.eventStore = self.dataManager.eventStore;
    evc.editViewDelegate = self;
    return evc;
}

// EKEventEditViewDelegate
- (void)eventEditViewController:(EKEventEditViewController *)controller 
          didCompleteWithAction:(EKEventEditViewAction)action
{
    switch (action) {
        case EKEventEditViewActionSaved:
            self.ekIdentifier = self.ekEvent.eventIdentifier;
            break;
        case EKEventEditViewActionDeleted:
            self.ekIdentifier = nil;
            break;
        default:
            break;
    }
    self.ekEvent = nil;
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)willSave
{
    if ([self isDeleted]) {
        // TODO: come up with a way to preserve id's between
        // the same event
        //[self deleteFromEventStore];
    }
}

#pragma mark - 

- (BOOL)isBookmarked
{
    return [self.bookmarked boolValue];
}

- (void)addBookmark
{
    self.bookmarked = [NSNumber numberWithBool:YES];
    [[CoreDataManager sharedManager] saveData];
}

- (void)removeBookmark
{
    self.bookmarked = [NSNumber numberWithBool:NO];
    [[CoreDataManager sharedManager] saveData];
}

@end

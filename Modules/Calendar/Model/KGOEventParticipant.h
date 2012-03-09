#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KGOEventContactInfo, KGOEventParticipantRelation;

@interface KGOEventParticipant : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * attendeeType;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* contactInfo;

// new in v3. gone: events
@property (nonatomic, retain) NSSet* attendedEvents;
@property (nonatomic, retain) NSSet* organizedEvents;


@end

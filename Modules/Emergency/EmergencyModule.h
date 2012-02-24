#import "KGOModule.h"
#import "KGORequestManager.h"

extern NSString * const EmergencyContactsPathPageName;

@interface EmergencyModule : KGOModule {
    BOOL noticeFeedExists;
    BOOL contactsFeedExists;
	
}

@property (nonatomic) BOOL noticeFeedExists;
@property (nonatomic) BOOL contactsFeedExists;
@end


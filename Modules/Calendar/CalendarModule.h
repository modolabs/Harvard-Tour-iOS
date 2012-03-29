#import <Foundation/Foundation.h>
#import "KGOModule.h"
#import "KGORequestManager.h"
#import "CalendarDataManager.h"
#import "CalendarDayViewController.h"

@class CalendarDataManager;

@interface CalendarModule : KGOModule <KGORequestDelegate> {

    CalendarDataManager *_dataManager;
    KGOCalendarBrowseMode _defaultBrowseMode;
    BOOL _suppressSectionTitles;
	
}

@property (nonatomic, retain) KGORequest *request;
@property (nonatomic, readonly) CalendarDataManager *dataManager;

- (NSString *)defaultCalendar;

@end


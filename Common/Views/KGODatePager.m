#import "KGODatePager.h"
#import "KGOTheme.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "UIKit+KGOAdditions.h"

@implementation KGODatePager

@synthesize delegate, contentsController;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        self.backgroundColor = [[KGOTheme sharedTheme] backgroundColorForDatePager];
        self.incrementUnit = NSDayCalendarUnit;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{    
    self = [super initWithFrame:frame];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        self.backgroundColor = [[KGOTheme sharedTheme] backgroundColorForDatePager];
        self.incrementUnit = NSDayCalendarUnit;
    }
    return self;
}

- (void)dealloc {
    [_dateFormatter release];
    [_displayDate release];
    [_date release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIImage *dropShadowImage = [[[KGOTheme sharedTheme] backgroundImageForSearchBarDropShadow] stretchableImageWithLeftCapWidth:5
                                                                                                                   topCapHeight:5];
    if (dropShadowImage) {
        dropShadow.image = dropShadowImage;
    } else {
        [dropShadow removeFromSuperview];
    }

    [nextButton setBackgroundImage:[UIImage imageWithPathName:@"common/toolbar-button-next"]
                          forState:UIControlStateNormal];
    [nextButton setBackgroundImage:[UIImage imageWithPathName:@"common/toolbar-button-next-pressed"]
                          forState:UIControlStateHighlighted];
    
    [prevButton setBackgroundImage:[UIImage imageWithPathName:@"common/toolbar-button-previous"]
                          forState:UIControlStateNormal];
    [prevButton setBackgroundImage:[UIImage imageWithPathName:@"common/toolbar-button-previous-pressed"]
                          forState:UIControlStateHighlighted];
    
    [calendarButton setBackgroundImage:[UIImage imageWithPathName:@"common/toolbar-button"]
                              forState:UIControlStateNormal];
    [calendarButton setBackgroundImage:[UIImage imageWithPathName:@"common/toolbar-button-pressed"]
                              forState:UIControlStateHighlighted];
    [calendarButton setImage:[UIImage imageWithPathName:@"common/subheadbar_calendar"]
                    forState:UIControlStateNormal];
}

- (IBAction)buttonPressed:(id)sender {
    if (sender == calendarButton || sender == dateButton) {
        DatePickerViewController *pickerVC = [[[DatePickerViewController alloc] init] autorelease];
        pickerVC.delegate = self;
        pickerVC.date = self.date;
        
        [self.contentsController presentModalViewController:pickerVC animated:YES];
        
    } else {
        // previous or next date
        NSInteger offset = (sender == prevButton) ? -1 : 1;
        NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
        if (_incrementUnit & NSDayCalendarUnit)   [components setDay:offset];
        if (_incrementUnit & NSWeekCalendarUnit)  [components setWeek:offset];
        if (_incrementUnit & NSMonthCalendarUnit) [components setMonth:offset];
        if (_incrementUnit & NSYearCalendarUnit)  [components setYear:offset];
        
        self.date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:0];
    }
}


- (NSDate *)displayDate {
    return _displayDate;
}

- (void)setDisplayDate:(NSDate *)aDate {
    if (![_displayDate isEqualToDate:aDate]) {
        [_displayDate release];
        _displayDate = [aDate retain];
        
        NSString *dateText = [_dateFormatter stringFromDate:_displayDate];
        [dateButton setTitle:dateText forState:UIControlStateNormal];
    }
}

- (NSDate *)date {
    return _date;
}

- (void)setDate:(NSDate *)aDate {
    if (![_date isEqualToDate:aDate]) {
        [_date release];
        _date = [aDate retain];
        self.displayDate = aDate;
        [self.delegate pager:self didSelectDate:_date];
    }
}

- (NSCalendarUnit)incrementUnit {
    return _incrementUnit;
}

- (void)setIncrementUnit:(NSCalendarUnit)unitFlags {
    _incrementUnit = unitFlags;
    if (_incrementUnit & NSDayCalendarUnit)        [_dateFormatter setDateFormat:@"EEEE M/d"];
    else if (_incrementUnit & NSWeekCalendarUnit)  [_dateFormatter setDateFormat:@"EEEE M/d"];
    else if (_incrementUnit & NSMonthCalendarUnit) [_dateFormatter setDateFormat:@"yyyy MMM"];
    else if (_incrementUnit & NSYearCalendarUnit)  [_dateFormatter setDateFormat:@"yyyy"];
}

#pragma mark DatePickerViewControllerDelegate functions

- (void)datePickerViewControllerDidCancel:(DatePickerViewController *)controller {
    self.displayDate = self.date;
    [self.contentsController dismissModalViewControllerAnimated:YES];
}

- (void)datePickerViewController:(DatePickerViewController *)controller didSelectDate:(NSDate *)date {
    self.date = date;
    
    [self.contentsController dismissModalViewControllerAnimated:YES];
}

- (void)datePickerViewController:(DatePickerViewController *)controller valueChanged:(NSDate *)date {
    self.displayDate = date;
}


@end

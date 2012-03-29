#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"

@class KGODatePager;

@protocol KGODatePagerDelegate

- (void)pager:(KGODatePager *)pager didSelectDate:(NSDate *)date;

@end


@interface KGODatePager : UIView <DatePickerViewControllerDelegate> {
    
    NSDate *_date;
    NSDate *_displayDate;
    NSDateFormatter *_dateFormatter;
    NSCalendarUnit _incrementUnit;
    BOOL _showsDropShadow;
}

- (IBAction)buttonPressed:(id)sender;

@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *prevButton;
@property (nonatomic, retain) IBOutlet UIButton *dateButton;
@property (nonatomic, retain) IBOutlet UIButton *calendarButton;
@property (nonatomic, retain) IBOutlet UIImageView *dropShadow;


@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *displayDate;

@property (nonatomic) NSCalendarUnit incrementUnit;
@property (nonatomic, assign) id<KGODatePagerDelegate> delegate;
@property (nonatomic, assign) UIViewController *contentsController;

@property (nonatomic) BOOL showsDropShadow;

@end

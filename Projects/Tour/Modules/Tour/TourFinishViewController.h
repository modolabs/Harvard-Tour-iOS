
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <UIKit/UIKit.h>
#import "HTMLTemplateBasedViewController.h"

@protocol TourFinishControllerDelegate

- (void)startOver;
- (UIView *)contentView;

@end


@interface TourFinishViewController : HTMLTemplateBasedViewController <UIActionSheetDelegate>
{

}

@property (assign) id<TourFinishControllerDelegate> delegate;

@end

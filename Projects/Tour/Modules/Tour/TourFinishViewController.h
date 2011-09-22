//
//  TourFinishViewController.h
//  Tour
//
//  Created by Jim Kang on 6/14/11.
//  Copyright 2011 Modo Labs. All rights reserved.
//

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

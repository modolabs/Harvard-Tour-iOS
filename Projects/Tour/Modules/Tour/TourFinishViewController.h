//
//  TourFinishViewController.h
//  Tour
//
//  Created by Jim Kang on 6/14/11.
//  Copyright 2011 Modo Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourWalkingPathViewController.h"
//#import "KGOTabbedControl.h"

@interface TourFinishViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIScrollView *scrollView;
}

@property (nonatomic, retain) NSMutableArray *linkLaunchers;
@property (nonatomic, retain) IBOutlet UIWebView * webView;

@end

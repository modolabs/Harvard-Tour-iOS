//
//  TourFinishViewController.m
//  Tour
//
//  Created by Jim Kang on 6/14/11.
//  Copyright 2011 Modo Labs. All rights reserved.
//

#import "TourFinishViewController.h"
#import "TourDataManager.h"
#import "LinkLauncher.h"
#import "TourUnderLineLabel.h"
#import "UIKit+KGOAdditions.h"

static const CGFloat kDefaultLinkLabelHeight = 44.0f;
static const CGFloat kSpaceBetweenLinkLabels = 4.0f;


@implementation TourFinishViewController
       
@synthesize webView;

- (void)dealloc
{
    [webView release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark HTMLTemplateBasedViewController
// The template file under resources/modules/tour.
- (NSString *)templateFilename {
    return @"finish_template.html";
}

// Keys: Stubs to replace in the template. Values: Strings to replace them.
- (NSDictionary *)replacementsForStubs {
    NSDictionary *replacementsDict = nil;    
    NSArray *finishTextArray = 
    [[TourDataManager sharedManager] pagesTextArray:@"finish"];
    
    if ((finishTextArray.count > 1) && 
        [finishTextArray objectAtIndex:1]) {
        
        replacementsDict = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         
         [finishTextArray objectAtIndex:0], @"__DESCRIPTION_TEXT__",
         
         [[super class] htmlForContactsSection:
          [finishTextArray objectAtIndex:1]], @"__LINKS__",
         
         nil];
    }
    return replacementsDict;
}


@end

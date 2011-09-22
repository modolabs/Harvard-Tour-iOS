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
@synthesize delegate;

- (void)dealloc
{
    [webView release];
    self.delegate = nil;
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

#pragma - mark UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self.delegate startOver];
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIWebView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL* url = request.URL;
    
    if ([url.scheme isEqualToString:@"yardtour"]) {
        if ([url.resourceSpecifier isEqualToString:@"//startover"]) {
            NSString *title = @"Are you sure you want to restart the tour?";
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Yes", nil];
            
            [actionSheet showInView:self.delegate.contentView];
            [actionSheet release];
        }
        return NO;
    } 
    else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        // Send all links in these web views to their respective proper handlers.
        // e.g. Phone for tel://, Mail for mailto://, Safari for http://.
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

@end

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

@interface TourFinishViewController (Private)

- (void)addLinksFromArray:(NSArray *)links startingAtY:(CGFloat)topY;
// Will use sizeToFit, so frame may not end up differing from initial frame.
- (UILabel *)linkLabelForLinkDefinition:(NSDictionary *)linkDefinition
                       withInitialFrame:(CGRect)frame;

@end

@implementation TourFinishViewController (Private)

- (void)addLinksFromArray:(NSArray *)links startingAtY:(CGFloat)topY {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];    
    for (NSDictionary *linkDefinition in links) {        
        UILabel *linkLabel = 
        [self 
         linkLabelForLinkDefinition:linkDefinition 
         withInitialFrame:CGRectMake(5, 
                                     topY, 
                                     self.view.frame.size.width, 
                                     kDefaultLinkLabelHeight)];
        [scrollView addSubview:linkLabel];
        topY += (linkLabel.frame.size.height + kSpaceBetweenLinkLabels);
    }
    [pool release];
}

- (UILabel *)linkLabelForLinkDefinition:(NSDictionary *)linkDefinition
                       withInitialFrame:(CGRect)frame {
    TourUnderLineLabel *label = [[[TourUnderLineLabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    
    label.text = [linkDefinition objectForKey:@"title"];
    label.textColor = [UIColor colorWithHexString:@"#800000"];
    [label sizeToFit];
    NSString *urlString = [linkDefinition objectForKey:@"url"];
    if (urlString.length > 0) {
        label.userInteractionEnabled = YES;
        LinkLauncher *launcher = [LinkLauncher launcherWithURLString:urlString];
        [self.linkLaunchers addObject:launcher];
        [label addGestureRecognizer:
         [[[UITapGestureRecognizer alloc] 
           initWithTarget:launcher action:@selector(launchLink)] autorelease]];
    }
    return label;
}

@end


@implementation TourFinishViewController
       
@synthesize linkLaunchers;
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.linkLaunchers = [NSMutableArray arrayWithCapacity:8];
    }
    return self;
}

- (void)dealloc
{
    [linkLaunchers release];
    [self.webView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
    NSArray *finishTextArray = 
    [[TourDataManager sharedManager] pagesTextArray:@"finish"];
    NSString *htmlString = @"<html><body>";
    if (finishTextArray.count > 0) {
        htmlString = [htmlString stringByAppendingString:[finishTextArray objectAtIndex:0]];
        //htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    //thankYouLabel.text = [TourDataManager stripHTMLTagsFromString:message];
    htmlString = [htmlString stringByAppendingString:@"</body></html>"];
    
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.userInteractionEnabled = NO;
    self.webView.opaque = NO;
    [self.webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] resourceURL]];
    
    // Add links only when the webView has finished loading (in the webViewDelegate function below
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
    navigationType:(UIWebViewNavigationType)navigationType
{
   // if ([[[request URL] absoluteString]
     //   return YES;
    
    NSRange rangeHTTP = [[[request URL] absoluteString] rangeOfString:@"http"];
    NSRange rangeWWW = [[[request URL] absoluteString] rangeOfString:@"www"];
    
    if ((rangeHTTP.location != NSNotFound) || (rangeWWW.location != NSNotFound))
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        
        return NO;
    }
    
    return YES;
    //NSLog(@"\nResource URL: %@\n", [[[NSBundle mainBundle] resourceURL] absoluteString]);
    //NSLog(@"request URL: %@\n", [[request URL] absoluteString]);
    

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // Re-sizing webView to fit the content. THis only works if the webView 
    //is set to minimum height (1) right before calling sizeThatFits
    
    CGRect frame = self.webView.frame;
    frame.size.height = 1;
    self.webView.frame = frame;
    CGSize fittingSize = [self.webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    self.webView.frame = frame;
    
    // noew place the links in the right places
    NSArray *finishTextArray = 
    [[TourDataManager sharedManager] pagesTextArray:@"finish"];
    
    // Add links.
    if (finishTextArray.count > 1) {
        [self 
         addLinksFromArray:[finishTextArray objectAtIndex:1] 
         startingAtY:self.webView.frame.size.height + kSpaceBetweenLinkLabels];
    }
    scrollView.contentSize = CGSizeMake(280, 640);
    
}

@end

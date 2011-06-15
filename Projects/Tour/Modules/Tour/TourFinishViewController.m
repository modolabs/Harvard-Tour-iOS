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
         withInitialFrame:CGRectMake(0, 
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
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.text = [linkDefinition objectForKey:@"title"];
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
    NSArray *finishTextArray = [[TourDataManager sharedManager] finishText];
    NSString *message = @"";
    if (finishTextArray.count > 0) {
        message = [finishTextArray objectAtIndex:0];
    }
    thankYouLabel.text = [TourDataManager stripHTMLTagsFromString:message];
    [thankYouLabel sizeToFit];
    
    // Add links.
    if (finishTextArray.count > 1) {
        [self 
         addLinksFromArray:[finishTextArray objectAtIndex:1] 
         startingAtY:thankYouLabel.frame.size.height + kSpaceBetweenLinkLabels];
    }
    scrollView.contentSize = CGSizeMake(280, 640);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

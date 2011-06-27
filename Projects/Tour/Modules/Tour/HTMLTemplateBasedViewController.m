//
//  HTMLTemplateBasedViewController.m
//  Tour
//

#import "HTMLTemplateBasedViewController.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "TourModule.h"

@implementation HTMLTemplateBasedViewController (Protected)

- (void)setUpWebViewLayout 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *templateFilename = [self templateFilename];
    NSDictionary *replacementsForStubs = [self replacementsForStubs];
    
    if (templateFilename && replacementsForStubs)
    {        
        NSString *htmlString = [[self class] 
                                htmlForPageTemplateFileName:templateFilename
                                replacementsForStubs:replacementsForStubs];
        [self.webView 
         loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] resourceURL]];        
    }

    [pool release];    
}

@end


@implementation HTMLTemplateBasedViewController

@synthesize webView;

#pragma mark NSObject

- (void)dealloc
{
    [webView dealloc];
    [super dealloc];
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // TourModule's module tag in the config and app delegate is "home".    
    [self setUpWebViewLayout];
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

#pragma mark "pure virtual" methods
// The template file under resources/modules/tour.
- (NSString *)templateFilename
{
    NSAssert(NO, @"Should be overridden.");
    return nil;
}

// Keys: Stubs to replace in the template. Values: Strings to replace them.
- (NSDictionary *)replacementsForStubs
{
    NSAssert(NO, @"Should be overridden.");
    return nil;
}

#pragma mark Formatting utils

+ (NSString *)fillOutTemplate:(NSString *)templateString 
         replacementsForStubs:(NSDictionary *)replacementsForStubs {
    
    NSMutableString *mutableString = 
    [NSMutableString stringWithString:templateString];
    
    for (NSString *stub in replacementsForStubs) {
        [mutableString 
         replaceOccurrencesOfString:stub
         withString:[replacementsForStubs objectForKey:stub]
         options:NSLiteralSearch 
         range:NSMakeRange(0, [mutableString length])];
    }
    return mutableString;        
}

// topicDicts should be an array of dictionaries.
+ (NSString *)htmlForPageTemplateFileName:(NSString *)pageTemplateFilename
                     replacementsForStubs:(NSDictionary *)replacementsForStubs {
    
    NSError *error = nil;
    NSURL *baseURL = 
    [[NSURL 
      fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES]
     URLByAppendingPathComponent:@"modules/tour/"];
    NSString *pageTemplate = 
    [NSString 
     stringWithContentsOfURL:
     [baseURL URLByAppendingPathComponent:pageTemplateFilename] 
     encoding:NSUTF8StringEncoding error:&error];
    
    NSString *htmlString = 
    [[self class] 
     fillOutTemplate:pageTemplate replacementsForStubs:replacementsForStubs];
    return htmlString;
}

// topicDicts should be an array of dictionaries.
+ (NSString *)htmlForTopicSection:(NSArray *)topicDicts {
    NSMutableString *topicsString = [NSMutableString string];
    
    NSURL *baseURL = 
    [[NSURL 
      fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES]
     URLByAppendingPathComponent:@"modules/tour/"];
    
    NSError *error = nil;
    NSString *topicTemplate = 
    [NSString 
     stringWithContentsOfURL:
     [baseURL URLByAppendingPathComponent:@"topic_template.html"] 
     encoding:NSUTF8StringEncoding error:&error];
    
    for (NSDictionary *topicDict in topicDicts) {
        NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];
        
        NSString *topicId = [topicDict objectForKey:@"id"];
        NSString *topicText = [topicDict objectForKey:@"name"];
        NSString *topicTextDetails = [topicDict objectForKey:@"description"];
        
        // <Image> [Lens-Name]: [Lens-Description] in HTML
        [topicsString appendString:
         [[self class]
          fillOutTemplate:topicTemplate 
          replacementsForStubs:
          [NSDictionary dictionaryWithObjectsAndKeys:
           topicId, @"__TOPIC_ID__", topicText, @"__TOPIC_TEXT__", 
           topicTextDetails, @"__TOPIC_DEFAILS__", nil]]];
        
        [innerPool release];
    }
    return topicsString;
}

@end

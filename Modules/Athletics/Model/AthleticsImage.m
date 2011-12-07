#import "AthleticsImage.h"
#import "AthleticsStory.h"
NSString * const AthleticsImageEntityName = @"AthleticsImage";

@implementation AthleticsImage
@synthesize height;
@synthesize data;
@synthesize width;
@synthesize ordinality;
@synthesize credits;
@synthesize caption;
@synthesize url;
@synthesize title;
@synthesize link;
@synthesize thumbParent;
@synthesize featuredParent;


- (void)dealloc {
    self.height = nil;
    self.data = nil;
    self.width = nil;
    self.ordinality = nil;
    self.credits = nil;
    self.caption = nil;
    self.url = nil;
    self.title = nil;
    self.link = nil;
    self.thumbParent = nil;
    self.featuredParent = nil;

    [super dealloc];
}
@end

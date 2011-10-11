
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "LinkLauncher.h"


@implementation LinkLauncher

@synthesize urlStringToLaunch;

- (void)dealloc {
    [urlStringToLaunch release];
    [super dealloc];
}

+ (LinkLauncher *)launcherWithURLString:(NSString *)urlString {
    LinkLauncher *launcher = [[[LinkLauncher alloc] init] autorelease];
    launcher.urlStringToLaunch = urlString;
    return launcher;
}

- (void)launchLink {
    [[UIApplication sharedApplication] 
     openURL:[NSURL URLWithString:self.urlStringToLaunch]];
}

@end

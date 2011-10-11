
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <Foundation/Foundation.h>


@interface LinkLauncher : NSObject {
    
}

@property (nonatomic, retain) NSString *urlStringToLaunch;

+ (LinkLauncher *)launcherWithURLString:(NSString *)urlString;

- (void)launchLink;

@end

//
//  LinkLauncher.h
//  Tour
//

#import <Foundation/Foundation.h>


@interface LinkLauncher : NSObject {
    
}

@property (nonatomic, retain) NSString *urlStringToLaunch;

+ (LinkLauncher *)launcherWithURLString:(NSString *)urlString;

- (void)launchLink;

@end

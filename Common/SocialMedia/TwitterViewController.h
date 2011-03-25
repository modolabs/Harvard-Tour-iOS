#import <UIKit/UIKit.h>
#import "MGTwitterEngine.h"
#import "ConnectionWrapper.h"
#import "KGOSocialMediaController.h"

// TODO: make dependence on bit.ly optional
@interface TwitterViewController : UIViewController <UITextFieldDelegate,
TwitterWrapperDelegate, BitlyWrapperDelegate> {
	NSString *message;
	NSString *longURL;
    NSString *shortURL;
	
	UILabel *usernameLabel;
    UILabel *counterLabel;
	UIView *contentView;
	UINavigationItem *navigationItem;
	UIButton *signOutButton;
	
	UITextField *usernameField;
	UITextField *passwordField;
	
	UITextField *messageField;
	
	MGTwitterEngine *twitterEngine;
    OAToken *token;
	BOOL authenticationRequestInProcess;
    
    ConnectionWrapper *connection;
}

- (id) initWithMessage:(NSString *)aMessage url:(NSString *)longURL;

@property (nonatomic, retain) ConnectionWrapper *connection;
@property (nonatomic, retain) UIView *contentView;

@end
#import "KGOModule.h"
#import "KGORequestManager.h"
#import "VideoDataManager.h"

@interface VideoModule : KGOModule <VideoDataDelegate> {

}

@property (nonatomic, retain) VideoDataManager *dataManager;
@property (nonatomic, retain) NSString *searchSection;

@end

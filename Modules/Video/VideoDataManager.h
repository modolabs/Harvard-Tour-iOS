#import <Foundation/Foundation.h>
#import "KGORequestManager.h"
#import "Video.h"

@class VideoDataManager, VideoModule;

@protocol VideoDataDelegate <NSObject>

@optional

- (void)dataManager:(VideoDataManager *)manager didReceiveSections:(NSArray *)sections;
- (void)dataManager:(VideoDataManager *)manager didReceiveVideos:(NSArray *)videos;
- (void)dataManager:(VideoDataManager *)manager didReceiveVideo:(Video *)video;

@end


typedef void (^VideoDataRequestResponse)(id result);

@interface VideoDataManager : NSObject<KGORequestDelegate> {
    
    KGORequest *_sectionsRequest;
    KGORequest *_videosRequest;
    KGORequest *_detailRequest;
    
}

#pragma mark Public
- (BOOL)requestSections;
- (BOOL)searchSection:(NSString *)section forQuery:(NSString *)query;
- (BOOL)requestVideosForSection:(NSString *)section;
- (BOOL)requestVideoForSection:(NSString *)section videoID:(NSString *)videoID;

- (NSArray *)bookmarkedVideos;
- (void)pruneVideos; 

@property (nonatomic, retain) VideoModule *module;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSMutableArray *videos;
@property (nonatomic, retain) NSMutableArray *videosFromCurrentSearch;
@property (nonatomic, retain) Video *detailVideo;

@property (nonatomic, assign) id<VideoDataDelegate> delegate;




@end

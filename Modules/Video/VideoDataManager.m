#import "VideoDataManager.h"
#import "CoreDataManager.h"
#import "Foundation+KGOAdditions.h"
#import "Video.h"
#import "VideoTag.h"
#import "VideoModule.h"

NSString * const KurogoVideoSectionsArrayKey = @"Kurogo video sections array";

#pragma mark Private methods


@implementation VideoDataManager

@synthesize module;
@synthesize sections;
@synthesize videos;
@synthesize videosFromCurrentSearch;
@synthesize detailVideo;
@synthesize delegate;


#pragma mark NSObject

- (id)init
{
    self = [super init];
	if (self) {
        self.videos = [NSMutableArray arrayWithCapacity:30];
        self.videosFromCurrentSearch = [NSMutableArray arrayWithCapacity:30];
    }
	return self;
}

- (void)dealloc {
    [_sectionsRequest cancel];
    [_videosRequest cancel];
    [_detailRequest cancel];
    
    [videosFromCurrentSearch release];
    [module release];
    [sections release];
    [detailVideo release];
    [super dealloc];
}

#pragma mark Public

- (BOOL)requestSections
{
    BOOL succeeded = NO;
    
    if (_sectionsRequest) {
        return succeeded;
    }
    
    if (![[KGORequestManager sharedManager] isReachable]) {
        // Get last saved sections.
        self.sections = [[NSUserDefaults standardUserDefaults] objectForKey:KurogoVideoSectionsArrayKey];        
        if (self.sections && [self.delegate respondsToSelector:@selector(dataManager:didReceiveSections:)]) {
            [self.delegate dataManager:self didReceiveSections:self.sections];
        }

    } else {
        _sectionsRequest = [[KGORequestManager sharedManager] requestWithDelegate:self
                                                                           module:self.module.tag
                                                                             path:@"sections"
                                                                          version:1
                                                                           params:nil];
        _sectionsRequest.expectedResponseType = [NSArray class];

        succeeded = [_sectionsRequest connect];
    } 
    
    return succeeded;
}

- (BOOL)requestVideosForSection:(NSString *)section
{
    BOOL succeeded = NO;
    
    if (_videosRequest) {
        [_videosRequest cancel];
    }
    
    if (![[KGORequestManager sharedManager] isReachable]) {
        
        _videosRequest = nil;
        
        // Get last saved videos for this section.
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"source == %@", section];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
        NSArray *fetchedVideos = [[CoreDataManager sharedManager] objectsForEntity:@"Video" 
                                                                 matchingPredicate:pred
                                                                   sortDescriptors:[NSArray arrayWithObject:sort]];
        if (fetchedVideos) {
            [self.videos addObjectsFromArray:fetchedVideos];
        }
        
        if ([self.delegate respondsToSelector:@selector(dataManager:didReceiveVideos:)]) {
            [self.delegate dataManager:self didReceiveVideos:self.videos];
        }

    }    
    else {
        NSDictionary *params = [NSDictionary dictionaryWithObject:section forKey:@"section"];
        _videosRequest = [[KGORequestManager sharedManager] requestWithDelegate:self
                                                                        module:self.module.tag 
                                                                          path:@"videos"
                                                                       version:1
                                                                        params:params];
        _videosRequest.expectedResponseType = [NSArray class];
        
        succeeded = [_videosRequest connect];
    }    
    
    return succeeded;
}

// TODO: make this method also fetch from core data in offline conditions
- (BOOL)requestVideoForSection:(NSString *)section videoID:(NSString *)videoID
{
    BOOL succeeded = NO;
    
    if (_detailRequest) {
        [_detailRequest cancel];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            section, @"section", videoID, @"videoid", nil];
    
    _detailRequest = [[KGORequestManager sharedManager] requestWithDelegate:self
                                                                    module:self.module.tag 
                                                                      path:@"detail"
                                                                   version:1
                                                                    params:params];
    _detailRequest.expectedResponseType = [NSDictionary class];

    succeeded = [_detailRequest connect];

    return succeeded;
}

- (BOOL)searchSection:(NSString *)section forQuery:(NSString *)query
{
    BOOL succeeded = NO;
    
    if (_videosRequest) {
        [_videosRequest cancel];
    }
    
    if (![[KGORequestManager sharedManager] isReachable]) {
        // Get last searched-for videos.
        NSPredicate *pred = [NSPredicate predicateWithFormat:
                             @"source == 'search: %@|%@'", query, section];
        NSArray *fetchedVideos = [[CoreDataManager sharedManager] objectsForEntity:@"Video" 
                                                                 matchingPredicate:pred];
        if (fetchedVideos) {
            [self.videosFromCurrentSearch addObjectsFromArray:fetchedVideos];
        }
        
        if ([self.delegate respondsToSelector:@selector(dataManager:didReceiveVideos:)]) {
            [self.delegate dataManager:self didReceiveVideos:self.videosFromCurrentSearch];
        }
    }    
    else {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                query, @"q",
                                section, @"section",
                                nil];
        _videosRequest = [[KGORequestManager sharedManager] requestWithDelegate:self 
                                                                         module:self.module.tag 
                                                                           path:@"search"
                                                                        version:1
                                                                         params:params];
        _videosRequest.expectedResponseType = [NSArray class];
        
        succeeded = [_videosRequest connect];
    } 
    return succeeded;
}

- (NSArray *)bookmarkedVideos
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"bookmarked == YES"];
    return [[CoreDataManager sharedManager] objectsForEntity:@"Video" matchingPredicate:pred];
}


- (void)pruneVideos
{
    NSPredicate *bookmarked = [NSPredicate predicateWithFormat:@"bookmarked == YES"];
    self.videos = [NSMutableArray arrayWithArray:[self.videos filteredArrayUsingPredicate:bookmarked]];
    
    NSPredicate *notBookmarked = [NSPredicate predicateWithFormat:@"bookmarked != YES"];
    NSArray *nonBookmarkedVideos = [[CoreDataManager sharedManager] objectsForEntity:@"Video"
                                                                   matchingPredicate:notBookmarked];

    [[CoreDataManager sharedManager] deleteObjects:nonBookmarkedVideos];
}


#pragma mark KGORequestDelegate

- (void)requestWillTerminate:(KGORequest *)request
{
    if (request == _sectionsRequest) {
        _sectionsRequest = nil;
    } else if (request == _detailRequest) {
        _detailRequest = nil;
    } else if (request == _videosRequest) {
        _videosRequest = nil;
    }
}

- (void)request:(KGORequest *)request didReceiveResult:(id)result
{
    if (request == _sectionsRequest) {
#pragma mark Request result - sections
        self.sections = result;
        [[NSUserDefaults standardUserDefaults] setObject:self.sections
                                                  forKey:KurogoVideoSectionsArrayKey];
        
        if ([self.delegate respondsToSelector:@selector(dataManager:didReceiveSections:)]) {
            [self.delegate dataManager:self didReceiveSections:self.sections];
        }

    } else if (request == _detailRequest) {
#pragma mark Request result - detail
        Video *video = [Video videoWithDictionary:result];
        video.moduleTag = self.module.tag;
        video.source = [request.getParams objectForKey:@"section"];
        self.detailVideo = video;
        [[CoreDataManager sharedManager] saveData];
        
        
        if ([self.delegate respondsToSelector:@selector(dataManager:didReceiveVideo:)]) {
            [self.delegate dataManager:self didReceiveVideo:video];
        }

    } else if (request == _videosRequest) {
#pragma mark Request result - videos
        // queue unneeded videos to be deleted.
        // if new results still contain videos with the same id, we will take them out of the remove queue
        NSString *query = [_videosRequest.getParams objectForKey:@"q"];
        NSMutableArray *activeVideos = nil;
        NSMutableDictionary *removedVideos = [NSMutableDictionary dictionary];
        if (!query) {
            activeVideos = self.videos;;
        } else {
            activeVideos = self.videosFromCurrentSearch;
        }
        [activeVideos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Video *video = (Video *)obj;
            [removedVideos setObject:video forKey:video.videoID];
        }];
        activeVideos = [NSMutableArray array];
        
        NSInteger order = 0;
        for (NSDictionary *dict in result) {
            Video *video = [Video videoWithDictionary:dict];
            if (video) {
                video.moduleTag = self.module.tag;

                NSString *section = [_videosRequest.getParams objectForKey:@"section"];
                if (query) { // this is a search
                    video.source = [NSString stringWithFormat:@"search: %@|%@", query, section];
                } else {
                    video.source = section;
                    video.sortOrder = [NSNumber numberWithInt:order++];
                }
                
                [activeVideos addObject:video];
                [removedVideos removeObjectForKey:video.videoID];
            }
        }

        if (query) {
            self.videosFromCurrentSearch = activeVideos;
        } else {
            self.videos = activeVideos;
        }
        
        [removedVideos enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [[CoreDataManager sharedManager] deleteObject:obj];
        }];
        
        [[CoreDataManager sharedManager] saveData];
        
        if ([self.delegate respondsToSelector:@selector(dataManager:didReceiveVideos:)]) {
            [self.delegate dataManager:self didReceiveVideos:activeVideos];
        }
    }
    
}

@end

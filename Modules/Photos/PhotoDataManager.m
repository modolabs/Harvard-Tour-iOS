#import "PhotoDataManager.h"

@implementation PhotoDataManager

@synthesize moduleTag, delegate;

- (void)fetchAlbums
{
    if (!_albumsRequest) {
        _albumsRequest = [[KGORequestManager sharedManager] requestWithDelegate:self
                                                                         module:self.moduleTag
                                                                           path:@"albums"
                                                                        version:1
                                                                         params:nil];
        _albumsRequest.expectedResponseType = [NSDictionary class];
        //_albumsRequest.minimumDuration = 3600; // TODO
        [_albumsRequest connect];
    }
}

- (void)fetchPhotosForAlbum:(NSString *)album
{
    if (!_photosRequest) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:album, @"id", nil];
        _photosRequest = [[KGORequestManager sharedManager] requestWithDelegate:self
                                                                         module:self.moduleTag
                                                                           path:@"list"
                                                                        version:1
                                                                         params:params];
        _photosRequest.expectedResponseType = [NSDictionary class];
        [_photosRequest connect];
    }
}

- (void)requestWillTerminate:(KGORequest *)request
{
    if (request == _photosRequest) {
        _photosRequest = nil;
    } else if (request == _albumsRequest) {
        _albumsRequest = nil;
    }
}

- (void)request:(KGORequest *)request didReceiveResult:(id)result
{
    if (request == _photosRequest) {
        NSArray *photoData = [result arrayForKey:@"photos"];
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:photoData.count];
        for (NSDictionary *photoDict in photoData) {
            Photo *aPhoto = [Photo photoWithDictionary:photoDict];
            if (aPhoto) {
                [photos addObject:aPhoto];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(photoDataManager:didReceivePhotos:forAlbum:)]) {
            [self.delegate photoDataManager:self didReceivePhotos:photos];
        }
        
    } else if (request == _albumsRequest) {
        // TODO: the API should say something other than "photos"
        NSArray *albumData = [result arrayForKey:@"photos"];
        NSMutableArray *albums = [NSMutableArray arrayWithCapacity:albumData.count];
        for (NSDictionary *albumDict in albumData) {
            PhotoAlbum *anAlbum = [PhotoAlbum albumWithDictionary:albumDict];
            if (anAlbum) {
                [albums addObject:anAlbum];
            }
        }

        if ([self.delegate respondsToSelector:@selector(photoDataManager:didReceiveAlbums:)]) {
            [self.delegate photoDataManager:self didReceiveAlbums:albums];
        }
    }
}

- (void)dealloc
{
    if (_albumsRequest) {
        [_albumsRequest cancel];
    }
    if (_photosRequest) {
        [_photosRequest cancel];
    }
    self.moduleTag = nil;
    self.delegate = nil;
    [super dealloc];
}

@end

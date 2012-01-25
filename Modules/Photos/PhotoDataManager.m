#import "PhotoDataManager.h"
#import "CoreDataManager.h"

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

- (void)fetchPhotosForAlbum:(NSString *)albumName
{
    if (_photosRequest) {
        return;
    }
    
    PhotoAlbum *album = [PhotoAlbum albumWithID:albumName canCreate:NO];
    if ([album.lastUpdate timeIntervalSinceNow] < -3600) { // TODO
        [[CoreDataManager sharedManager] deleteObjects:[album.photos allObjects]];
        album.photos = nil;
    }
    
    if (album.photos.count && album.photos.count == [album.totalItems integerValue]) {
        if ([self.delegate respondsToSelector:@selector(photoDataManager:didReceivePhotos:)]) {
            [self.delegate photoDataManager:self didReceivePhotos:album.photos];
        }

    } else {
        NSString *start = [NSString stringWithFormat:@"%d", album.photos.count];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                albumName, @"id",
                                start, @"start",
                                @"20", @"limit",
                                nil];
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
        
        if ([self.delegate respondsToSelector:@selector(photoDataManager:didReceivePhotos:)]) {
            [self.delegate photoDataManager:self didReceivePhotos:photos];
        }
        
    } else if (request == _albumsRequest) {
        NSArray *albumData = [result arrayForKey:@"albums"];
        NSMutableArray *albums = [NSMutableArray arrayWithCapacity:albumData.count];
        for (NSDictionary *albumDict in albumData) {
            PhotoAlbum *anAlbum = [PhotoAlbum albumWithDictionary:albumDict];
            if (anAlbum) {
                anAlbum.sortOrder = [NSNumber numberWithInt:albums.count];
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

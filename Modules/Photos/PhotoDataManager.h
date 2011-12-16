#import "KGORequestManager.h"
#import "PhotoAlbum.h"
#import "Photo.h"

@class PhotoDataManager;

@protocol PhotoDataManagerDelegate <NSObject>

@optional

- (void)photoDataManager:(PhotoDataManager *)manager didReceiveAlbums:(NSArray *)albums;
- (void)photoDataManager:(PhotoDataManager *)manager didReceivePhotos:(NSArray *)photos;
/*
- (void)photoDataManager:(PhotoDataManager *)manager
        didReceivePhotos:(NSArray *)photos
                forAlbum:(PhotoAlbum *)album;
*/
@end


@interface PhotoDataManager : NSObject <KGORequestDelegate> {
    
    KGORequest *_albumsRequest;
    KGORequest *_photosRequest;
    
}

- (void)fetchAlbums;
- (void)fetchPhotosForAlbum:(NSString *)album;

@property (nonatomic, retain) NSString *moduleTag;
@property (nonatomic, assign) id<PhotoDataManagerDelegate> delegate;

@end


/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "TourMediaItem.h"
#import "CoreDataManager.h"
#import "TourConstants.h"
#import <CommonCrypto/CommonDigest.h>

@implementation TourMediaItem
@dynamic URL;

+ (TourMediaItem *)mediaItemForURL:(NSString *)url {
    TourMediaItem *mediaItem = [[CoreDataManager sharedManager] getObjectForEntity:TourMediaItemEntityName attribute:@"URL" value:url];
    
    if (!mediaItem) {
        mediaItem = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:TourMediaItemEntityName];
        mediaItem.URL = url;
    }
    return mediaItem;
}

/*
 *
 */
- (NSString *)mediaFilePath {
    // compute the MD5 checksum of url to find the media files path
    // we use MD5 checksum just because it creates a safe file name
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    NSData* data = [self.URL dataUsingEncoding:NSUTF8StringEncoding];
    CC_MD5_Update(&md5, [data bytes], [data length]);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
 	CC_MD5_Final(digest, &md5);
    NSString *md5Hash = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
        digest[0], digest[1],
        digest[2], digest[3],
        digest[4], digest[5],
        digest[6], digest[7],
        digest[8], digest[9],
        digest[10], digest[11],
        digest[12], digest[13],
        digest[14], digest[15]];
   
    NSString *cacheName = nil;
    NSArray *components = [self.URL componentsSeparatedByString:@"."];
    if(components.count > 1) {
        cacheName = [NSString stringWithFormat:@"%@.%@", md5Hash, [components lastObject]];
    } else {
        cacheName = md5Hash;
    }
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:
                           [NSString stringWithFormat:@"data/media/%@", cacheName]];
}

/*
 * Use this if the media represents a photo
 */
- (UIImage *)image {
    return [UIImage imageWithContentsOfFile:[self mediaFilePath]];
}
@end


/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/


#import "BeamAnnotation.h"


@implementation BeamAnnotation

#pragma mark NSObject
- (id)init {
    self = [super init];
    if (self)
    {
        self.latitude = 0.0f;
        self.longitude = 0.0f;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark MKAnnotation

- (CLLocationCoordinate2D)coordinate {
    coordinate.latitude = self.latitude;
    coordinate.longitude = self.longitude;
    return coordinate;
}

- (void)setLatitude:(CGFloat)aLatitude {
    [self willChangeValueForKey:@"coordinate"];
    [self willChangeValueForKey:@"latitude"];
    latitude = aLatitude;
    [self didChangeValueForKey:@"coordinate"];
    [self didChangeValueForKey:@"latitude"];
}

- (CGFloat)latitude {
    return latitude;
}

- (void)setLongitude:(CGFloat)aLongitude {
    [self willChangeValueForKey:@"coordinate"];
    [self willChangeValueForKey:@"longitude"];
    longitude = aLongitude;
    [self didChangeValueForKey:@"coordinate"];
    [self didChangeValueForKey:@"longitude"];
}

- (CGFloat)longitude {
    return longitude;
}

@end

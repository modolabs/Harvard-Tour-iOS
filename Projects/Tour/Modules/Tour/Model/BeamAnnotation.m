//
//  BeamAnnotation.m
//  Tour
//

#import "BeamAnnotation.h"


@implementation BeamAnnotation

@synthesize latitude;
@synthesize longitude;

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


@end

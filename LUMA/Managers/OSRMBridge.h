#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoutingResult : NSObject
@property (nonatomic, readonly, nullable) NSArray<NSValue *> *coordinates;
@property (nonatomic, readonly, nullable) NSArray<NSString *> *instructions;
@property (nonatomic, readonly, nullable) NSString *errorMessage;
@property (nonatomic, readonly) BOOL success;

+ (instancetype)successWithCoordinates:(NSArray<NSValue *> *)coordinates 
                          instructions:(NSArray<NSString *> *)instructions;
+ (instancetype)failureWithMessage:(NSString *)message;
@end

@interface OSRMBridge : NSObject

/**
 * Initializes the OSRM engine with a bundled .osrm file.
 * @param path The absolute path to the .osrm base file.
 */
- (nullable instancetype)initWithOSRMFile:(NSString *)path;

/**
 * Calculates a route between two coordinates.
 * @param start Starting coordinate.
 * @param end Destination coordinate.
 * @return A RoutingResult containing coordinates and instructions or an error message.
 */
- (RoutingResult *)calculateRouteFrom:(CLLocationCoordinate2D)start 
                                   to:(CLLocationCoordinate2D)end;

@end

NS_ASSUME_NONNULL_END

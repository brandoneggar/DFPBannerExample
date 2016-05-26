//
//  RFMFastLane.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 12/8/15.
//  Copyright © 2015 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMAdRequest.h"

@class RFMAdView;

/**
 * FastLane protocol for the receiving of fastlane callbacks or notifications.
 *
 * The fastlane delegate should conform to this protocol.
 */
@protocol RFMFastLaneDelegate <NSObject>

/**
 * Delegate callback when an ad has been successfully prefetched.
 *
 * @param adInfo dictionary that contains information pertaining to ad, 
 *          such as fastlane bid range
 * @see didFailToReceiveFastLaneAdWithReason:
 */
- (void)didReceiveFastLaneAdInfo:(NSDictionary *)adInfo;

/**
 * **Optional** Delegate callback when the SDK failed to prefetch an ad.
 *
 * @param errorReason The reason for failure to load an ad
 * @see didReceiveFastLaneAdInfo:
 */
- (void)didFailToReceiveFastLaneAdWithReason:(NSString *)errorReason;

@end

/**
 * RFMFastLane class that handles fastlane prefetching and callbacks.
 *
 * After creating an instance of RFMFastLane, make a call to prefetch an ad.
 * It is recommended to move the primary SDK request call into the didReceiveFastLaneAdInfo: method.
 */
@interface RFMFastLane : NSObject

/**
 * Create an instance of RFMFastLane.
 *
 * @param adView The adView that will be used to initialize the fastlane request
 * @param delegate The delegate that conforms to RFMFastLaneDelegate
 * @see preFetchAdWithParams:
 */
- (id)initWithAdView:(UIView*)adView
            delegate:(id<RFMFastLaneDelegate>)delegate;

/**
 * Create an instance of RFMFastLane.
 *
 * @param size The size of the adview that will be used for the fastlane request
 * @param delegate The delegate that conforms to RFMFastLaneDelegate
 * @see preFetchAdWithParams:
 */
- (id)initWithSize:(CGSize)size
          delegate:(id<RFMFastLaneDelegate>)delegate;

/**
 * Prefetch ad for fastlane.
 *
 * @param requestParams The request parameters associated with the fastlane request
 * @see initWithAdView:delegate:
 */
- (BOOL)preFetchAdWithParams:(RFMAdRequest *)requestParams;

@end

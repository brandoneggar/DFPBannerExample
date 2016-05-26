//
//  MFPAmazonBanner.h
//
//  Copyright (c) 2015 MyFitnessPal. All rights reserved.
//

#import "MFPAmazonBanner.h"
#import "MPLogging.h"
#import <AmazonAd/AmazonAdRegistration.h>
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdError.h>

@interface MFPAmazonBanner () <AmazonAdViewDelegate>
@property (nonatomic, strong) AmazonAdView *amazonAdView;
@property (nonatomic, assign) BOOL didTrackImpression;
@property (nonatomic, assign) BOOL didTrackClick;
@end

@implementation MFPAmazonBanner

- (void)dealloc {
  self.amazonAdView.delegate = nil;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
  // Set the application ID
  [[AmazonAdRegistration sharedRegistration] setAppKey:@"35eafcf3e00b4e689e27981bd8a74103"]; // the MFP ad unit ID
  
  
  self.amazonAdView = [AmazonAdView amazonAdViewWithAdSize:size];
  AmazonAdOptions *adOptions = [AmazonAdOptions options];
  adOptions.timeout = 6;
  
  // IMPORTANT - During development you should always set this flag to true.
  // Test traffic that doesn’t include this flag can result in blocked requests, fraud investigation, and potential account termination.
  adOptions.isTestRequest = [[info objectForKey:@"test_mode"] boolValue];
  self.amazonAdView.delegate = self;
  [self.amazonAdView loadAd:adOptions];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
  return NO;
}

#pragma mark - AmazonAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView {
  return [self.delegate viewControllerForPresentingModalView];
}

- (void)adViewWillExpand:(AmazonAdView *)view {
  // Amazon will present modal view for an ad. Its time to pause other activities.
  [self.delegate bannerCustomEventWillBeginAction:self];
  if (!self.didTrackClick) {
    MPLogInfo(@"%@ banner was clicked.", NSStringFromClass(self.class));
    [self.delegate trackClick];
    self.didTrackClick = YES;
  } else {
    MPLogInfo(@"%@ banner ignoring duplicate click", NSStringFromClass(self.class));
  }
}

- (void)adViewDidCollapse:(AmazonAdView *)view {
  // Amazon modal view has been dismissed, it's time to resume the paused activities.
  [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adViewDidLoad:(AmazonAdView *)view {
  // Amazon successfully loaded an ad
  [self.delegate bannerCustomEvent:self didLoadAd:self.amazonAdView];
  if (!self.didTrackImpression) {
    [self.delegate trackImpression];
    self.didTrackImpression = YES;
  }
}

- (void)adViewDidFailToLoad:(AmazonAdView *)view withError:(AmazonAdError *)error {
  // Amazon failed to load an ad
  [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

@end

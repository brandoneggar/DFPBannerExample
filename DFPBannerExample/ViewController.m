//
//  ViewController.m
//  DFPBannerExample
//
//  Created by Brandon Fields on 5/25/16.
//  Copyright © 2016 MyFitnessPal. All rights reserved.
//

#import "ViewController.h"
#import "MPLogging.h"
#import "asl.h"

@import GoogleMobileAds;

#define kBannerAdWidth 320
#define kBannerAdHeight 50
#define kTextViewHeight 150
#define kPadding 25

@interface ViewController () <GADBannerViewDelegate, GADAppEventDelegate, GADAdSizeDelegate>

@property (strong, nonatomic) DFPBannerView  *bannerView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *refreshButton;
@property (strong, nonatomic) UIButton *dfpPathButton;

@property (strong, nonatomic) NSString *selectedPath;
@property (strong, nonatomic) NSArray *dfpPaths;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSLog(@"Google Mobile Ads SDK version: %@", [DFPRequest sdkVersion]);

  self.selectedPath = @"/17729925/UACF_M/MFP/Diary";
  
  self.dfpPaths = @[self.selectedPath,
                    @"/17729925/test/MFP/AdCom",
                    @"/17729925/test/MFP/AdMob",
                    @"/17729925/test/MFP/Facebook",
                    @"/17729925/test/MFP/Millennial",
                    @"/17729925/test/MFP/MoPub",
                    @"/17729925/test/MFP/Rubicon",
                    @"/17729925/test/MFP/Verve"];
  
  MPLogSetLevel(MPLogLevelDebug);
  
  self.bannerView = [[DFPBannerView alloc] initWithFrame:CGRectMake(0, 0, kBannerAdWidth, kBannerAdHeight)];
  self.bannerView.backgroundColor = [UIColor lightGrayColor];
  //self.bannerView.validAdSizes = @[ NSValueFromGADAdSize(kGADAdSizeLargeBanner), NSValueFromGADAdSize(kGADAdSizeBanner) ];
  self.bannerView.adUnitID = self.selectedPath;
  self.bannerView.rootViewController = self;
  self.bannerView.delegate = self;
  self.bannerView.appEventDelegate = self;
  self.bannerView.adSizeDelegate = self;
  [self.bannerView loadRequest:[DFPRequest request]];
  [self.view addSubview:self.bannerView];
  
  self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
  self.textView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
  self.textView.textColor = [UIColor blackColor];
  self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.textView.layer.borderWidth = 1.0;
  [self.view addSubview:self.textView];

  self.refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.refreshButton setTitle:@"Refresh Ad" forState:UIControlStateNormal];
  [self.refreshButton addTarget:self action:@selector(refreshPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.refreshButton];

  self.dfpPathButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.dfpPathButton setTitle:self.selectedPath forState:UIControlStateNormal];
  [self.dfpPathButton addTarget:self action:@selector(selectDFPPath:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.dfpPathButton];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];

  self.bannerView.frame = CGRectMake(self.view.frame.size.width/2-kBannerAdWidth/2, 2*kPadding, kBannerAdWidth, kBannerAdHeight);
  self.textView.frame = CGRectMake(kPadding, self.bannerView.frame.origin.y+self.bannerView.frame.size.height+kPadding, self.view.frame.size.width-2*kPadding, kTextViewHeight);
  self.refreshButton.frame = CGRectMake(kPadding, self.textView.frame.origin.y+self.textView.frame.size.height+kPadding, self.view.frame.size.width-2*kPadding, kPadding);
  self.dfpPathButton.frame = CGRectMake(kPadding, self.refreshButton.frame.origin.y+self.refreshButton.frame.size.height+kPadding, self.view.frame.size.width-2*kPadding, kPadding);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)selectDFPPath:(id)sender {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DFP Path" message:@"Pick a path" preferredStyle:UIAlertControllerStyleAlert];
  for (NSString *path in self.dfpPaths) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:path style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull handlerAction) {
      self.selectedPath = handlerAction.title;
      [self.dfpPathButton setTitle:self.selectedPath forState:UIControlStateNormal];
      self.bannerView.adUnitID = self.selectedPath;
      [self.bannerView loadRequest:[DFPRequest request]];
    }];
    [alert addAction:action];
  }
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshPressed:(id)sender {
  [self.bannerView loadRequest:[DFPRequest request]];
}

#pragma mark - GADBannerViewDelegate

/// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
/// the banner view to the view hierarchy if it hasn't been added yet.
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
  static int count = 0;
  count += 1;
  NSString *msg = [NSString stringWithFormat:@"adViewDidReceiveAd:\n\ncount = %@", [NSNumber numberWithInt:count]];
  NSLog(@"%@", msg);
  self.textView.textColor = [UIColor greenColor];
  self.textView.text = msg;
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
  NSString *msg = [NSString stringWithFormat:@"adViewDidFailToReceiveAdWithError:\n\n%@", error.localizedDescription];
  NSLog(@"%@", msg);
  self.textView.textColor = [UIColor redColor];
  self.textView.text = msg;
}

#pragma mark - GADBannerViewDelegate: Click-Time Lifecycle Notifications

/// Tells the delegate that a full screen view will be presented in response to the user clicking on
/// an ad. The delegate may want to pause animations and time sensitive interactions.
- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
  NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full screen view has been dismissed. The delegate should restart
/// anything paused while handling adViewWillPresentScreen:.
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that the user click will open another app, backgrounding the current
/// application. The standard UIApplicationDelegate methods, like applicationDidEnterBackground:,
/// are called immediately before this method is called.
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
  NSLog(@"adViewWillLeaveApplication");
}

#pragma mark - GADAppEventDelegate

/// Called when the banner receives an app event.
- (void)adView:(GADBannerView *)banner didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info {
  NSLog(@"adView:didReceiveAppEvent:withInfo:\n%@\n%@", name, info);
}

/// Called when the interstitial receives an app event.
- (void)interstitial:(GADInterstitial *)interstitial didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info {
  NSLog(@"interstitial:didReceiveAppEvent:withInfo:\n%@\n%@", name, info);
}

#pragma mark - GADAdSizeDelegate

/// Called before the ad view changes to the new size.
- (void)adView:(GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size {
  NSLog(@"adView:willChangeAdSizeTo: %f,%f", size.size.width, size.size.height);
}

@end

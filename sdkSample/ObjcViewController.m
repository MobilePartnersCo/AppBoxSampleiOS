//
//  ObjcViewController.m
//  sdkSample
//
//  Created by mobilePartners on 12/3/24.
//

#import "ObjcViewController.h"

@interface ObjcViewController ()

@end

@implementation ObjcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // -----------------------------------------------------------------------------------------
    // AppBox WebConfig 설정
    // -----------------------------------------------------------------------------------------
    AppBoxWebConfig *appBoxWebConfig = [[AppBoxWebConfig alloc] init];
    WKWebViewConfiguration *wkWebViewConfig = [[WKWebViewConfiguration alloc] init];
    
    
    if (@available(iOS 14.0, *)) {
        wkWebViewConfig.defaultWebpagePreferences.allowsContentJavaScript = true;
    } else {
        wkWebViewConfig.preferences.javaScriptEnabled = true;
    }
    
    appBoxWebConfig.wKWebViewConfiguration = wkWebViewConfig;
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // AppBox 초기화
    // -----------------------------------------------------------------------------------------
    [[AppBox shared]
     initSDKWithBaseUrl:@"https://www.example.com"
     webConfig:appBoxWebConfig
     debugMode:true
    ];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // AppBox 푸시 토큰 설정
    // -----------------------------------------------------------------------------------------
    [[AppBox shared] setPushToken:@"푸시 토큰 값"];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // AppBox 인트로 설정
    // -----------------------------------------------------------------------------------------
    AppBoxIntro *appBoxIntroItem1 = [[AppBoxIntro alloc] initWithImageUrl:@"https://www.example.com/example1.png"];
    AppBoxIntro *appBoxIntroItem2 = [[AppBoxIntro alloc] initWithImageUrl:@"https://www.example.com/example2.png"];
    
    NSArray *items = [[NSArray alloc] initWithObjects:appBoxIntroItem1, appBoxIntroItem2, nil];
    [[AppBox shared] setIntro:items];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // AppBox 당겨서 새로고침 설정
    // -----------------------------------------------------------------------------------------
    [[AppBox shared] setPullDownRefreshWithUsed:true];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // AppBox 실행
    // -----------------------------------------------------------------------------------------
    [[AppBox shared] startFrom:self completion:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            // 실행 성공 처리
            NSLog(@"AppBox:: SDK 실행 성공");
        } else {
            // 실행 실패 처리
            if (error != nil) {
                NSLog(@"error : %@", error.localizedDescription);
            } else {
                NSLog(@"error : unkown Error");
            }
        }
    }];
    // -----------------------------------------------------------------------------------------
}

@end

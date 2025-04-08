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
    // AppBox WebConfig 설정 (AppDelegate 설정 필수)
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
    // AppBox 초기화 (AppDelegate 설정 필수)
    // -----------------------------------------------------------------------------------------
    [[AppBox shared]
     initSDKWithBaseUrl:@"https://www.example.com"
     projectId:@"프로젝트 아이디"
     webConfig:appBoxWebConfig
     debugMode:true
    ];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // AppBox BaseUrl 설정
    // -----------------------------------------------------------------------------------------
    [[AppBox shared] setBaseUrlWithBaseUrl:@"https://www.example.com"];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // AppBox Debug 설정
    // -----------------------------------------------------------------------------------------
    [[AppBox shared] setDebugWithDebugMode:true];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // AppBox 인트로 설정
    // -----------------------------------------------------------------------------------------
    AppBoxIntroItems *appBoxIntroItem1 = [[AppBoxIntroItems alloc] initWithImageUrl:@"https://example.com/image.jpg"];
    NSArray *items = [[NSArray alloc] initWithObjects:appBoxIntroItem1, nil];
    AppBoxIntro *intro = [[AppBoxIntro alloc] initWithItem:items];
    [[AppBox shared] setIntro:intro];
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

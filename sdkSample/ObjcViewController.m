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
   
    // [AppBox 기본 WebView] Objective-C 프로젝트에서 AppBox 기본 WebView 방식을 붙이는 예시입니다.
    // -----------------------------------------------------------------------------------------
    // AppBox WebConfig 설정 (AppDelegate 설정 필수)
    // -----------------------------------------------------------------------------------------
    AppBoxWebConfig *appBoxWebConfig = [[AppBoxWebConfig alloc] init];
    WKWebViewConfiguration *wkWebViewConfig = [[WKWebViewConfiguration alloc] init];
    
    
    // [AppBox 기본 WebView] bridge 호출을 위해 WKWebView의 JavaScript 실행을 허용합니다.
    if (@available(iOS 14.0, *)) {
        wkWebViewConfig.defaultWebpagePreferences.allowsContentJavaScript = true;
    } else {
        wkWebViewConfig.preferences.javaScriptEnabled = true;
    }
    
    appBoxWebConfig.wKWebViewConfiguration = wkWebViewConfig;
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox 초기화 (AppDelegate 설정 필수)
    // 실제 앱에서는 AppDelegate 등 앱 시작 시점에서 한 번만 초기화하는 것을 권장합니다.
    // -----------------------------------------------------------------------------------------
    [[AppBox shared]
     initSDKWithBaseUrl:@"https://www.example.com"
     projectId:@"프로젝트 아이디"
     webConfig:appBoxWebConfig
     debugMode:true
    ];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox BaseUrl 설정
    // initSDK 이후 다른 URL로 테스트해야 할 때 baseUrl을 덮어씁니다.
    // -----------------------------------------------------------------------------------------
    [[AppBox shared] setBaseUrlWithBaseUrl:@"https://www.example.com"];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox Debug 설정
    // -----------------------------------------------------------------------------------------
    [[AppBox shared] setDebugWithDebugMode:true];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox 인트로 설정
    // 인트로는 선택 기능이며 이미지 URL 배열로 구성합니다.
    // -----------------------------------------------------------------------------------------
    AppBoxIntroItems *appBoxIntroItem1 = [[AppBoxIntroItems alloc] initWithImageUrl:@"https://example.com/image.jpg"];
    NSArray *items = [[NSArray alloc] initWithObjects:appBoxIntroItem1, nil];
    AppBoxIntro *intro = [[AppBoxIntro alloc] initWithItem:items];
    [[AppBox shared] setIntro:intro];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox 당겨서 새로고침 설정
    // -----------------------------------------------------------------------------------------
    [[AppBox shared] setPullDownRefreshWithUsed:true];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox 실행
    // 현재 Objective-C 화면 위에 AppBox 관리 WebView를 표시합니다.
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

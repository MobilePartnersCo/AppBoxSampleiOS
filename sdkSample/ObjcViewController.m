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
    // SDK 초기화는 AppDelegate의 AppBox.initialize에서 한 번만 수행합니다.
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox BaseUrl 설정
    // 초기화 이후 다른 URL로 테스트해야 할 때 baseUrl을 덮어씁니다.
    // -----------------------------------------------------------------------------------------
    [AppBox setBaseURL:@"https://www.example.com"];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox Debug 설정
    // -----------------------------------------------------------------------------------------
    [AppBox setDebugMode:true];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox 인트로 설정
    // 인트로는 선택 기능이며 이미지 URL 배열로 구성합니다.
    // -----------------------------------------------------------------------------------------
    AppBoxIntroItems *appBoxIntroItem1 = [[AppBoxIntroItems alloc] initWithImageUrl:@"https://example.com/image.jpg"];
    NSArray *items = [[NSArray alloc] initWithObjects:appBoxIntroItem1, nil];
    AppBoxIntro *intro = [[AppBoxIntro alloc] initWithItem:items];
    [AppBox setIntro:intro];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox 당겨서 새로고침 설정
    // -----------------------------------------------------------------------------------------
    [AppBox setPullDownRefreshUsed:true];
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    // [AppBox 기본 WebView] AppBox 실행
    // 현재 Objective-C 화면 위에 AppBox 관리 WebView를 표시합니다.
    // -----------------------------------------------------------------------------------------
    [AppBox startFrom:self completion:^(BOOL isSuccess, NSError *error) {
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

#import "ObjcViewController.h"

@interface ObjcViewController ()
@property (nonatomic, strong) UILabel *resultLabel;
@end

@implementation ObjcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WebView · Objective-C";
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = @"SDK 초기화는 Swift AppDelegate에서 한 번만 수행합니다. 이 화면은 현재 공개 Objective-C selector로 AppBox WebView를 실행합니다.";
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    descriptionLabel.adjustsFontForContentSizeCategory = YES;
    descriptionLabel.textColor = UIColor.secondaryLabelColor;

    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [startButton setTitle:@"AppBox WebView 실행" forState:UIControlStateNormal];
    startButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    startButton.titleLabel.adjustsFontForContentSizeCategory = YES;
    startButton.backgroundColor = UIColor.secondarySystemBackgroundColor;
    startButton.layer.cornerRadius = 10.0;
    startButton.contentEdgeInsets = UIEdgeInsetsMake(12, 16, 12, 16);
    [startButton addTarget:self
                    action:@selector(startAppBoxWebView)
          forControlEvents:UIControlEventTouchUpInside];
    startButton.accessibilityLabel = @"AppBox WebView 실행";

    self.resultLabel = [[UILabel alloc] init];
    self.resultLabel.text = @"아직 실행한 동작이 없습니다.";
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.resultLabel.adjustsFontForContentSizeCategory = YES;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        descriptionLabel,
        startButton,
        self.resultLabel
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16.0;
    [self.view addSubview:stack];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16]
    ]];
}

- (void)startAppBoxWebView {
    [AppBox startFrom:self completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                self.resultLabel.text = @"WebView 실행 요청이 성공했습니다.";
                self.resultLabel.textColor = UIColor.labelColor;
            } else {
                self.resultLabel.text = error.localizedDescription ?: @"WebView 실행에 실패했습니다. SDK 설정 상태를 확인하세요.";
                self.resultLabel.textColor = UIColor.systemRedColor;
            }
            self.resultLabel.accessibilityLabel = [@"실행 결과, " stringByAppendingString:self.resultLabel.text];
        });
    }];
}

@end

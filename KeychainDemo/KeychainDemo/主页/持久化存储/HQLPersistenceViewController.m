//
//  HQLPersistenceViewController.m
//  HQLTableViewDemo
//
//  Created by Qilin Hu on 2019/10/30.
//  Copyright © 2019 ToninTech. All rights reserved.
//

#import "HQLPersistenceViewController.h"

static NSString * const selectedSegmentKey = @"selectedSegmentKey";
static NSString * const spinnerAnimatingKey = @"spinnerAnimatingKey";
static NSString * const switchEnabledKey = @"SwitchEnabledKey";
static NSString * const progressBarKey = @"progressBarKey";
static NSString * const textFieldKey = @"textFieldKey";
static NSString * const slider1Key = @"slider1Key";
static NSString * const slider2Key = @"slider2Key";
static NSString * const slider3Key = @"slider3Key";
static NSString * const sliderValueKey = @"sliderValueKey";
static NSString * const textViewComponent = @"textViewComponent";
static NSString * const controlStateComponent = @"controlStateComponent";
static NSString * const archivedDataComponent = @"archivedDataComponent";

// 声明遵守 UITextViewDelegate、UITextFieldDelegate 协议
@interface HQLPersistenceViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segments;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIButton *spinningButton;
@property (strong, nonatomic) IBOutlet UISwitch *cSwitch;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UISlider *slider1;
@property (strong, nonatomic) IBOutlet UISlider *slider2;
@property (strong, nonatomic) IBOutlet UISlider *slider3;
@property (strong, nonatomic) IBOutlet UITextView *textView;

// 声明两个可变词典类型属性，用来保存数据。
@property (strong, nonatomic) NSMutableDictionary *controlState;
@property (strong, nonatomic) NSMutableDictionary *sliderValue;

@end

@implementation HQLPersistenceViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置代理
    self.textField.delegate = self;
    self.textView.delegate = self;
    
    // 设置textView背景色，textField占位符。
    self.textView.backgroundColor = [UIColor lightGrayColor];
    self.textField.placeholder = @"Text Field";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:true];
    
    // 读取偏好设置中segment设置。
    NSInteger selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:selectedSegmentKey];
    self.segments.selectedSegmentIndex = selectedSegmentIndex;
    
    // 恢复偏好设置中spinner状态设置。
    if ([[NSUserDefaults standardUserDefaults] boolForKey:spinnerAnimatingKey] == true)
    {
        [self.spinner startAnimating];
        [self.spinningButton setTitle:@"Stop Animating" forState:UIControlStateNormal];
    }
    else
    {
        [self.spinner stopAnimating];
        [self.spinningButton setTitle:@"Start Animating" forState:UIControlStateNormal];
    }
    
    // 从 plist 恢复 controlState 词典。
    NSURL *controlStateURL = [self urlForDocumentDirectoryWithPathComponent:controlStateComponent];
    if (controlStateURL) {
        // 如果url存在，读取保存的数据。
        self.controlState = [NSMutableDictionary dictionaryWithContentsOfURL:controlStateURL];
    }
    if ([[self.controlState allKeys] count] != 0)
    {
        // 如果词典不为空，恢复数据。
        [self.cSwitch setOn:[[self.controlState objectForKey:switchEnabledKey] boolValue]];
        self.progressBar.progress = [[self.controlState objectForKey:progressBarKey] floatValue];
        self.textField.text = [self.controlState objectForKey:textFieldKey];
    }
    
    // 读取归档，恢复sliderValue词典内容。
    NSURL *dataURL = [self urlForDocumentDirectoryWithPathComponent:archivedDataComponent];
    if (dataURL) {
        // 如果url存在，读取保存的数据。
        NSMutableData *data = [[NSMutableData alloc] initWithContentsOfURL:dataURL];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.sliderValue = [unarchiver decodeObjectForKey:sliderValueKey];
    }
    if (self.sliderValue.allKeys.count != 0)
    {
        // 如果词典不为空，恢复数据。
        self.slider1.value = [[self.sliderValue objectForKey:slider1Key] floatValue];
        self.slider2.value = [[self.sliderValue objectForKey:slider2Key] floatValue];
        self.slider3.value = [[self.sliderValue objectForKey:slider3Key] floatValue];
    }
    
    // 读取文本文件，恢复textView内容。
    NSURL *textViewContentsURL = [self urlForDocumentDirectoryWithPathComponent:textViewComponent];
    if (textViewContentsURL) {
        NSString *textViewContents = [NSString stringWithContentsOfURL:textViewContentsURL encoding:NSUTF8StringEncoding error:nil];
        self.textView.text = textViewContents;
    }
}

#pragma mark - Custom Accessors

- (NSMutableDictionary *)controlState {
    if (!_controlState) {
        _controlState = [NSMutableDictionary dictionary];
    }
    return _controlState;
}

- (NSMutableDictionary *)sliderValue {
    if (!_sliderValue) {
        _sliderValue = [NSMutableDictionary dictionary];
    }
    return _sliderValue;
}

#pragma mark - IBActions

// spinner 部分
- (IBAction)toggleSpinner:(id)sender {
    // 控制「活动指示器」的旋转、暂停
    if (self.spinner.isAnimating) {
        [self.spinner stopAnimating];
        [self.spinningButton setTitle:@"开始动画" forState:UIControlStateNormal];
    } else {
        [self.spinner startAnimating];
        [self.spinningButton setTitle:@"结束动画" forState:UIControlStateNormal];
    }
    
    // 使用偏好设置保存「活动指示器」当前状态
    [[NSUserDefaults standardUserDefaults] setBool:[self.spinner isAnimating]
                                            forKey:spinnerAnimatingKey];
}

// segment control 部分
- (IBAction)controlValueChanged:(id)sender {
    if (sender == self.segments) {
        // 使用偏好设置保存 segment 当前状态
        NSInteger selectedSegment = ((UISegmentedControl *)sender).selectedSegmentIndex;
        [[NSUserDefaults standardUserDefaults] setInteger:selectedSegment
                                                   forKey:selectedSegmentKey];
    } else if (sender == self.cSwitch) {
        [self.controlState setValue:[NSNumber numberWithBool:self.cSwitch.isOn] forKey:switchEnabledKey];
    } else if (sender == self.textField) {
        [self.controlState setValue:self.textField.text forKey:textFieldKey];
    } else if (sender == self.slider1) {
        [self.sliderValue setValue:[NSNumber numberWithFloat:self.slider1.value] forKey:slider1Key];
        
        // 根据 slider1 的值更新 progress 进度条
        [self.progressBar setProgress:self.slider1.value];
        [self.controlState setValue:[NSNumber numberWithFloat:self.progressBar.progress] forKey:progressBarKey];
    }else if (sender == self.slider2) {
        [self.sliderValue setValue:[NSNumber numberWithFloat:self.slider2.value] forKey:slider2Key];
    }else if (sender == self.slider3) {
        [self.sliderValue setValue:[NSNumber numberWithFloat:self.slider3.value] forKey:slider3Key];
    }
    
    // 使用 plist 保存 controlState 词典
    NSURL *controlStateURL = [self urlForDocumentDirectoryWithPathComponent:controlStateComponent];
    [self.controlState writeToURL:controlStateURL atomically:YES];
    
    // 使用归档保存 sliderValue 词典
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.sliderValue forKey:sliderValueKey];
    [archiver finishEncoding];
    
    NSURL *dataURL = [self urlForDocumentDirectoryWithPathComponent:archivedDataComponent];
    if (![data writeToURL:dataURL atomically:YES]) {
        NSLog(@"Couldn't write to dataURL");
    }
}

#pragma mark - Private

- (NSURL *)urlForDocumentDirectoryWithPathComponent:(NSString *)pathComponent {
    // Documents 目录：NSDocumentDirectory
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return [documentsURL URLByAppendingPathComponent:pathComponent];
}


#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    // 编辑完成后，保存文本文件。
    NSString *textViewContents = textView.text;
    NSURL *fileURL = [self urlForDocumentDirectoryWithPathComponent:textViewComponent];
    [textViewContents writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


#pragma mark - UITextFieldDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return true;
}

// 隐藏键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end

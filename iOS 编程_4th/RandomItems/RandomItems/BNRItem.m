//
//  BNRItem.m
//  RandomItems
//
//  Created by Qilin Hu on 2019/11/5.
//  Copyright © 2019 Tonintech. All rights reserved.
//

// #import 和 C 语言中的 #include 作用相同，差别是 #import 可以确保不会重复导入同一个文件！
#import "BNRItem.h"

/// BNRItem.m 是实现文件（@implementation file），包含 BNRItem 类所实现的方法的全部代码。
@implementation BNRItem

#pragma mark - Initialize

+ (instancetype)randomItem {
    // 创建不可变数组对象，包含三个形容词
    NSArray *randomAdjectiveList = @[@"Fluffy", @"Rusty", @"Shiny"];
    // 创建不可变数组对象，包含三个名词
    NSArray *randomNounList = @[@"Bear", @"Spork", @"Mac"];
    
    // 根据数组对象所包含的对象个数，得到随机索引
    // 注意：运算符 % 是模运算符，运算后得到的是余数
    // 因此 adjectiveIndex 是一个 0 ～ 2 （包括 2）的随机数
    NSInteger adjectiveIndex = arc4random() % [randomAdjectiveList count];
    NSInteger nounIndex = arc4random() % [randomNounList count];
    // 注意：类型为 NSInteger 的变量不是对象
    // NSInteger 是一种针对 unsigned long （无符号长整数）的类型定义
    NSString *randomName = [NSString stringWithFormat:@"%@ %@",
                            [randomAdjectiveList objectAtIndex:adjectiveIndex],
                            [randomNounList objectAtIndex:nounIndex]];
    
    int randomValue = arc4random() % 100;
    
    NSString *randomSerialNumber = [NSString stringWithFormat:@"%c%c%c%c%c",
                                    '0' + arc4random() % 10,
                                    'A' + arc4random() % 26,
                                    '0' + arc4random() % 10,
                                    'A' + arc4random() % 26,
                                    '0' + arc4random() % 10];
    
    // 调用指定初始化方法，并传入上面步骤创建好的随机数据作为参数。
    BNRItem *newItem = [[self alloc] initWithItemName:randomName
                                       valueInDollars:randomValue
                                         serialNumber:randomSerialNumber];
    return newItem;
}

- (instancetype)initWithItemName:(NSString *)name
                  valueInDollars:(int)value
                    serialNumber:(NSString *)sNumber
{
    // 调用父类的指定初始化方法，并将得到的返回值赋值给 self 变量。
    self = [super init];
    // 确认 self 变量是否为 nil，以判断：父类的指定初始化方法是否成功创建了父类对象
    if (self) {
        // 为实例变量设定初始值
        // 在初始化方法中，应该直接访问实例变量。
        _itemName = name;
        _serialNumber = sNumber;
        _valueInDollars = value;
        // 设置 _dateCreated 的值为系统当前时间
        _dateCreated = [[NSDate alloc] init];
    }
    // 返回初始化后的对象的新地址
    return self;
}

- (instancetype)initWithItemName:(NSString *)name
{
    return [self initWithItemName:name
                   valueInDollars:0
                     serialNumber:@""];
}

/*
 覆盖子类的 init 方法，将其与指定初始化方法“串联”起来。
 
 串联（ chain）使用初始化方法的机制可以减少错误，也更容易维护代码。
 在创建类时，需要先确定指定初始化方法，然后只在指定初始化方法中编写初始化的核心代码，其他初始化方法只需要调用指定初始化方法（直接或间接）并传入默认值即可。
 */
- (instancetype)init {
    return [self initWithItemName:@"item"];
}

#pragma mark - Custom Accessors

// 存方法将传入的参数赋给了实例变量。
- (void)setItemName:(NSString *)str {
    _itemName = str;
}

// 取方法则返回实例变量的值。
- (NSString *)itemName {
    return _itemName;
}

- (void)setSerialNumber:(NSString *)str {
    _serialNumber = str;
}

- (NSString *)serialNumber {
    return _serialNumber;
}

- (void)setValueInDollars:(int)v {
    _valueInDollars = v;
}

- (int)valueInDollars {
    return _valueInDollars;
}

- (NSDate *)dateCreated {
    return _dateCreated;
}

#pragma mark - Override

// 子类覆盖父类的方法
// 使用存取方法访问实例变量是良好的编程习惯，即使是访问对象自身的实例变量，也应该使用存取方法。
- (NSString *)description {
    NSString *descriptionString = [[NSString alloc] initWithFormat:@"%@ (%@):Worth $%d, recorded on %@",
                                   self.itemName,
                                   self.serialNumber,
                                   self.valueInDollars,
                                   self.dateCreated];
    return  descriptionString;
}

@end

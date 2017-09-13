//
//  webViewController.h
//  selfwebview
//
//  Created by Frank on 2017/4/13.
//  Copyright © 2017年 Frank. All rights reserved.
//

/*
 涉及字段	文章标题、文章正文
 文章正文-特殊格式	"图片
 小标题
 加粗
 超链接
 正文
 引用
 
 文章表中对应“正文”字段数据转义后显示"
 单击-超链接	"如果是文章详情页【】或者黑镜详情页【】或者快讯详情页【】的地址，则跳转原生页面
 如果是其他页面，则跳转进入外部浏览器"
 */

#import <UIKit/UIKit.h>

@interface webViewController : UIViewController

@property (nonatomic, copy)  NSString  * pathStr;

@end

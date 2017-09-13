//
//  PYArticleDetailController.h
//  PYPingWestProject
//
//  Created by Frank on 2017/4/12.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYArticleDetailController : UIViewController

@property (nonatomic, strong) NSURL *url;

// Init Method
- (id)initWithURL:(NSURL *)url;
- (id)initWithURLString:(NSString *)urlString;

@end

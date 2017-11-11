//
//  ArticleDetailViewController.h
//  SafeNightOut
//
//  Created by Evan Yeung on 4/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleDetailViewController : UIViewController
@property (strong, nonatomic)NSString *content;

@property (weak, nonatomic) IBOutlet UIImageView *bigImage;
@property (weak, nonatomic) IBOutlet UITextView *article;

//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

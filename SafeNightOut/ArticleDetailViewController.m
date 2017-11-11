//
//  ArticleDetailViewController.m
//  SafeNightOut
//
//  Created by Evan Yeung on 4/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "ArticleDetailViewController.h"

@interface ArticleDetailViewController ()

@end

@implementation ArticleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [(UIScrollView *)self.view setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];

    self.article.text = self.content;
    self.bigImage.layer.cornerRadius = 15;
    self.bigImage.clipsToBounds = YES;

    
    [self.view addSubview:self.bigImage];
    [self.view addSubview:self.article];
    

    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

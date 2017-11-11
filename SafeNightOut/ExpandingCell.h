//
//  ExpandingCell.h
//  SafeNightOut
//
//  Created by Evan Yeung on 7/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *classImage;
@property (weak, nonatomic) IBOutlet UILabel *className;
@property (weak, nonatomic) IBOutlet UIImageView *sizeImg1;
@property (weak, nonatomic) IBOutlet UIImageView *sizeImg2;
@property (weak, nonatomic) IBOutlet UIImageView *sizeImg3;
@property (weak, nonatomic) IBOutlet UILabel *sizeText1;
@property (weak, nonatomic) IBOutlet UILabel *sizeText2;
@property (weak, nonatomic) IBOutlet UILabel *sizeText3;

@property (weak, nonatomic) IBOutlet UIButton *size1AddBtn;
@property (weak, nonatomic) IBOutlet UIButton *size2AddBtn;
@property (weak, nonatomic) IBOutlet UIButton *size3AddBtn;

@end

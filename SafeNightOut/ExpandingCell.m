//
//  ExpandingCell.m
//  SafeNightOut
//
//  Created by Evan Yeung on 7/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "ExpandingCell.h"

@implementation ExpandingCell
@synthesize classImage,className,sizeImg1,sizeImg2,sizeImg3,sizeText1,sizeText2,sizeText3,size1AddBtn,size2AddBtn,size3AddBtn;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

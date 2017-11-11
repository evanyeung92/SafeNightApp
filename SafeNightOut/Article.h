//
//  Article.h
//  SafeNightOut
//
//  Created by Evan Yeung on 4/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (strong, nonatomic)NSString *article_id;
@property (strong, nonatomic)NSString *title;
@property (strong, nonatomic)NSString *content;
@property (strong, nonatomic)NSString *image;

- (id)initWithId:(NSString *)aId
      title:(NSString *)aTitle
      content:(NSString *)aContent
      image:(NSString *)aImage;

@end

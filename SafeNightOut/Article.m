//
//  Article.m
//  SafeNightOut
//
//  Created by Evan Yeung on 4/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "Article.h"

@implementation Article

- (id)initWithId:(NSString *)aId
           title:(NSString *)aTitle
         content:(NSString *)aContent
           image:(NSString *)aImage{
    self = [super init];
    
    if (self) {
        self.article_id = aId;
        self.title = aTitle;
        self.content = aContent;
        self.image = aImage;
    }
    
    return self;
}
@end

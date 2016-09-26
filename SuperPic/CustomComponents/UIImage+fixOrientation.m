//
//  UIImage+fixOrientation.m
//  SuperPic
//
//  Created by Prince on 9/5/16.
//  Copyright © 2016 Eric. All rights reserved.
//

#import "UIImage+fixOrientation.h"
@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (self.size.height < self.size.width)
    {
        transform = CGAffineTransformTranslate(transform, 0, self.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);

    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    if (self.size.height < self.size.width)
    {
        
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
    }else{
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
        
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
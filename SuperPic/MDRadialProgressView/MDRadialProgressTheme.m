//
//  MDRadialProgressTheme.m
//  MDRadialProgress
//
//  Created by Marco Dinacci on 07/10/2013.
//  Copyright (c) 2013 Marco Dinacci. All rights reserved.
//

#import "MDRadialProgressTheme.h"


// The font size is automatically adapted but this is the maximum it will get
// unless overridden by the user.
static const int kMaxFontSize = 64;


@implementation MDRadialProgressTheme

+ (id)themeWithName:(const NSString *)themeName
{
	return [[MDRadialProgressTheme alloc] init];
}

+ (id)standardTheme
{
	return [MDRadialProgressTheme themeWithName:STANDARD_THEME];
}

- (id)init
{
	self = [super init];
	if (self) {
		// View
        self.completedColor = [UIColor whiteColor];
        self.incompletedColor = HEXCOLOR(0xeaa1a1ff);
		self.sliceDividerColor = [UIColor whiteColor];
        self.centerColor = HEXCOLOR(0xe85b5bff);
		self.thickness = 15;
		self.sliceDividerHidden = NO;
		self.sliceDividerThickness = 0;
		
		// Label
		self.labelColor = HEXCOLOR(0xe85b5bff);
		self.dropLabelShadow = NO;
		self.labelShadowColor = HEXCOLOR(0xe85b5bff);
		self.labelShadowOffset = CGSizeMake(0, 0);
		self.font = [UIFont systemFontOfSize:kMaxFontSize];
	}
	
	return self;
}

@end

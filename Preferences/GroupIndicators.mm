#import <Preferences/Preferences.h>

@interface GroupIndicatorsListController: PSListController {
}
@end

@implementation GroupIndicatorsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"GroupIndicators" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc

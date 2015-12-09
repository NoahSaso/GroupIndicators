@interface CKConversationListCell : UITableViewCell {
	UILabel *_summaryLabel;
}
@end

@interface CKConversationList : NSObject
+ (id)sharedConversationList;
- (id)conversations;
@end

@interface IMChat : NSObject
@property(readonly, nonatomic) NSArray *participants;
@property(readonly, nonatomic) NSString *displayName;
@end

@interface CKConversation : NSObject
@property(retain, nonatomic) IMChat *chat;
@end

static BOOL colorEnabled = YES, labelEnabled = NO;
static NSString *labelText = @"Group";

static CGFloat groupRed = 0.f, groupGreen = 0.75f, groupBlue = 0.5f, groupAlpha = 0.2f,
				nonGroupRed = 0.f, nonGroupGreen = 1.f, nonGroupBlue = 0.f, nonGroupAlpha = 0.15f;

#define GROUP_COLOR [UIColor colorWithRed:groupRed green:groupGreen blue:groupBlue alpha:groupAlpha]
#define NON_GROUP_COLOR [UIColor colorWithRed:nonGroupRed green:nonGroupGreen blue:nonGroupBlue alpha:nonGroupAlpha]

static UIColor *groupColor = [UIColor colorWithRed:0.f green:0.75f blue:1.f alpha:0.2f],
				*nonGroupColor = [UIColor colorWithRed:0.f green:1.f blue:0.f alpha:0.15f];

#define UILABEL_TAG 670

%hook CKConversationListController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *realCell = %orig;
	// If not CKConversationListCell, don't try to get conversation
	if(![realCell isKindOfClass:[%c(CKConversationListCell) class]]) return realCell;

	// Create variable of type CKConversationListCell
	CKConversationListCell *cell = (CKConversationListCell *)realCell;

	// Get conversation and people inside chat
	CKConversation *conversation = [[[%c(CKConversationList) sharedConversationList] conversations] objectAtIndex:indexPath.row];
	int people = conversation.chat.participants.count;

	// If people in chat > 1, it's a group
	// Make G label
	if(people > 1) {
		NSLog(@"[GroupIndicators] Found group: %@", conversation.chat.displayName);
		// Pull existing label
		UILabel *gLabel = [cell.contentView viewWithTag:UILABEL_TAG];
		if(labelEnabled) {
			// If label doesn't exist, create it
			if(!gLabel) gLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, cell.contentView.frame.size.height + 10, cell.contentView.frame.size.width - 8, 20)];
			// Do it again to verify it's correct
			gLabel.tag = UILABEL_TAG;
			gLabel.text = labelText;
			gLabel.font = [UIFont systemFontOfSize:12.5f];
			gLabel.textColor = MSHookIvar<UILabel *>(cell, "_summaryLabel").textColor;
			// Add label to cell
			[cell.contentView addSubview:gLabel];
		}else {
			if(gLabel) [gLabel removeFromSuperview];
		}
		cell.backgroundColor = colorEnabled ? GROUP_COLOR : [UIColor clearColor];
	}else {
		cell.backgroundColor = colorEnabled ? NON_GROUP_COLOR : [UIColor clearColor];
		// If label for some reason exists in a non-group conversation, remove it
		UILabel *gLabel = [cell viewWithTag:UILABEL_TAG];
		if(gLabel) [gLabel removeFromSuperview];
	}

	return cell;

}

%end

#define prefsID CFSTR("com.noahsaso.groupindicators")

static void reloadPrefs() {
	// Get prefs
	NSDictionary *prefs = nil;
	CFArrayRef keyList = CFPreferencesCopyKeyList(prefsID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if(keyList) {
		prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, prefsID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if(!prefs) prefs = [NSDictionary new];
		CFRelease(keyList);
	}
	// Set prefs
	colorEnabled = prefs[@"ColorEnabled"] ? [prefs[@"ColorEnabled"] boolValue] : YES;
	labelEnabled = prefs[@"LabelEnabled"] ? [prefs[@"LabelEnabled"] boolValue] : NO;
	labelText = prefs[@"LabelText"] ?: @"Group";
	// Set colors
	groupRed = prefs[@"GroupRed"] ? [prefs[@"GroupRed"] floatValue] : 0.f;
	groupGreen = prefs[@"GroupGreen"] ? [prefs[@"GroupGreen"] floatValue] : 0.75f;
	groupBlue = prefs[@"GroupBlue"] ? [prefs[@"GroupBlue"] floatValue] : 0.5f;
	groupAlpha = prefs[@"GroupAlpha"] ? [prefs[@"GroupAlpha"] floatValue] : 0.2f;
	// Non groups
	nonGroupRed = prefs[@"NonGroupRed"] ? [prefs[@"NonGroupRed"] floatValue] : 0.f;
	nonGroupGreen = prefs[@"NonGroupGreen"] ? [prefs[@"NonGroupGreen"] floatValue] : 1.f;
	nonGroupBlue = prefs[@"NonGroupBlue"] ? [prefs[@"NonGroupBlue"] floatValue] : 0.f;
	nonGroupAlpha = prefs[@"NonGroupAlpha"] ? [prefs[@"NonGroupAlpha"] floatValue] : 0.15f;
}

%ctor {
	reloadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
	        (CFNotificationCallback)reloadPrefs,
	        CFSTR("com.noahsaso.groupindicators.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

#define kPrefsPlistPath  @"/var/mobile/Library/Preferences/com.mvincentm.myname.plist"
#define kSettingsFilePath "/var/mobile/Library/Preferences/com.mvincentm.myname.plist"
#define kSettingsIdentifier "com.mvincentm.myname"
NSDictionary *saved;
NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:@"/private/var/preferences/SystemConfiguration/preferences.plist"];
NSString *operatorName_;
NSString *MyNameText;
BOOL isEnabled;
NSString *UserAssignedDeviceName = [plist valueForKeyPath:@"System.System.ComputerName"];
id arg;
NSString *operatorDefault;
BOOL state = true;
@interface SBTelephonyManager
-(void)_setOperatorName:(NSString *)arg1 inSubscriptionContext:(id)arg2;
+(id)sharedTelephonyManager;
@end

static void LoadSettings()
{
	if (kCFCoreFoundationVersionNumber >= 1000.0) {
		CFArrayRef keys = CFPreferencesCopyKeyList(CFSTR(kSettingsIdentifier), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		if (keys) {
			saved = (NSDictionary *)CFPreferencesCopyMultiple(keys, CFSTR(kSettingsIdentifier), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost) ?: [[NSDictionary alloc] init];
			CFRelease(keys);
		} else {
			saved = [[NSDictionary alloc] init];
		}
	} else {
		saved = [[NSDictionary alloc] initWithContentsOfFile:@kSettingsFilePath] ?: [[NSDictionary alloc] init];
	}

	MyNameText = saved[@"MyNameText"]  ? saved[@"MyNameText"] : @"";
	isEnabled = saved[@"Enabled"] ? [saved[@"Enabled"] boolValue] : FALSE;
}

%hook SBTelephonyManager
-(void)_setOperatorName:(NSString *)arg1 inSubscriptionContext:(id)arg2 {
	if(state)
	{
		arg = arg2;
		operatorDefault = arg1;
	}
	if(isEnabled)
	{
		if([MyNameText isEqual:@""]) operatorName_ = UserAssignedDeviceName;
		else operatorName_ = MyNameText;
		%orig(operatorName_,arg2);
	}
	else %orig;
}
%end

static void updateSettings(CFNotificationCenterRef center, void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo) {
	state = false;
	LoadSettings();
	[[%c(SBTelephonyManager) sharedTelephonyManager] _setOperatorName:operatorDefault inSubscriptionContext:arg];
}

%ctor {
	LoadSettings();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &updateSettings, CFSTR("com.mvincentm.myname.settings-changed"), NULL, 0);
}
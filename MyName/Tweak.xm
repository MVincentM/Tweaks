

%hook SBTelephonyManager
-(id) operatorName {

NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.mvincentm.myname.plist"];


NSString *operatorName_;

NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/preferences/SystemConfiguration/com.apple.mobilegestalt.plist"];

NSString *UserAssignedDeviceName = [[NSString alloc]init];

UserAssignedDeviceName=[plist objectForKey:@"UserAssignedDeviceName"];

if([[dict objectForKey:@"enabled"] boolValue])
{
    
        operatorName_ = [NSString stringWithFormat:@"%@", UserAssignedDeviceName];
        } 
else {
        operatorName_ = %orig;
        }
        return operatorName_;
}
%end


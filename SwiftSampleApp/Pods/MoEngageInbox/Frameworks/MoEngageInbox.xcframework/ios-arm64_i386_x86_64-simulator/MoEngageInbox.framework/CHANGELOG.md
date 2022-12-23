# MoEngageInbox
===========================

## Change Log:
### Version 2.1.0 *(13th December, 2022)*
-------------------------------------------
* Added dSYM file support for debugging.

### Version 2.0.0 *(7th December, 2022)*
-------------------------------------------
* All the classes and modules are prefixed with `MoEngage`.

### Version 1.4.1  *(30th November, 2022)*
-------------------------------------------
* BugFix: Handled removing of duplicate inbox messages when received via sync API.
* BugFix: Updated the logic for persistent storage of inbox messages.

### Version 1.4.0  *(18th October, 2022)*
-------------------------------------------
* Updated the dependency to MoEngage-iOS-SDK 8.4.0

### Version 1.3.1 *(22nd September, 2022)*
-------------------------------------------
* Added completionHandler for  API `markInboxNotificationClicked`, `removeInboxMessage` and `removeInboxMessages`.
* On calling `trackInboxClick`, the notification will be marked as read.

### Version 1.3.0 *(20th July, 2022)*
-------------------------------------------
* Updated the dependency to MoEngage-iOS-SDK 8.3.0

### Version 1.2.1 *(22nd June, 2022)*
-------------------------------------------
* Fixed the lldb issue when integrating MoEngage-iOS-SDK to Swift application.
* BugFix - Handled customization of `navigationBarColor` when pushing the InboxController. 

### Version 1.2.0 *(7th June, 2022)*
-------------------------------------------
* Updated the dependency to MoEngage-iOS-SDK 8.2.0
* Provided Swift Package manager support to install the SDK.
* Breaking Inbox from the main SDK.


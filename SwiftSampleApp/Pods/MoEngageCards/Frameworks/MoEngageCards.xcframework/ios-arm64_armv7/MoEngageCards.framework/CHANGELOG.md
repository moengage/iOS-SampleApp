# MoEngageCards
=================================

## Change Log:
### Version 4.1.0 *(13th December, 2022)*
-------------------------------------------
* Bugfix - Handle sorting of self handled cards based on the pinned cards and updated time for cards.
* Bugfix - Cards clicked status is not being updated for self handled cards.

### Version 4.0.0 *(7th December, 2022)*
-------------------------------------------
* All the classes and modules are prefixed with `MoEngage`.

### Version 3.4.2  *(11th November, 2022)*
-------------------------------------------
* Handled the "All" category in Cards UI to be hidden by default for landscape mode.

### Version 3.4.1  *(28th October, 2022)*
-------------------------------------------
* Handled the "All" category in Cards UI to be hidden by default.

### Version 3.4.0  *(18th October, 2022)*
-------------------------------------------
* Updated the dependency to MoEngage-iOS-SDK 8.4.0

### Version 3.3.0 *(20th July, 2022)*
-------------------------------------------
* Updated the dependency to MoEngage-iOS-SDK 8.3.0
* BugFix - Fixed issue in UIRefreshControl

### Version 3.2.1  *(22nd June, 2022)*
-------------------------------------------
* Fixed the lldb issue when integrating MoEngage-iOS-SDK to Swift application.
* BugFix - Handled the customization of `cardSelectionTintColor` and `navigationBarColor` when presenting and pushing the CardsController.

### Version 3.2.0  *(7th June, 2022)*
-------------------------------------------
* Updated the dependency to MoEngage-iOS-SDK 8.2.0.
* Renamed the module to MoEngageCards.
* Provided  Swift Package manager support to install the SDK.

### Version 3.1.0  *(29th March, 2022)*
-------------------------------------------
* Updated the dependency to MoEngage-iOS-SDK 8.1.0.

### Version 3.0.0  *(16th March, 2022)*
-------------------------------------------
* Renamed the module to MoEngageCards.

### Version 2.2.1  *(11th February, 2022)*
-------------------------------------------
* BugFix SUP-8627 - Handled crash in CardsController in 12.4 OS version.

### Version 2.2.0  *(31st January, 2022)*
-------------------------------------------
* Added `Capacitor` integration type.

### Version 2.1.0  *(27th August, 2021)*
-------------------------------------------
* Releasing module as XCFramework.

### Version 2.0.5  *(5th August, 2021)*
-------------------------------------------
* Image resource, deeplinks and richlanding URLs are percentage encoded if not already and then processed.

### Version 2.0.3  *(31st March, 2021)*
-------------------------------------------
* Additional UIConfigurations added to change `New Updates` button title.
* Changed the behaviour to load the cards on inbox fetch instead of showing `New Updates` button, in case of empty inbox.
* Added check for updates on `viewDidAppear`, to handle TabBarController use cases.

### Version 2.0.2  *(25th February, 2021)*
-------------------------------------------
* Additional UIConfigurations added to enable/disable Pull to refresh and Delete/Cancel action sheet texts.
* Showing empty screen on deletion of last card.

### Version 2.0.1  *(10th February, 2021)*
-------------------------------------------
* MoEngage-iOS-SDK Dependency updates

### Version 2.0.0  *(18th January, 2021)*
-------------------------------------------
* Changes to support  MoEngage-iOS-SDK 7.0.0

### Version 1.2.0  *(17th December, 2020)*
-------------------------------------------
* Changes to support  `enableSDK()` and `disableSDK()` methods for blocking/unblocking SDK features

### Version 1.1.0  *(24th November, 2020)*
-------------------------------------------
* `BUILD_LIBRARY_FOR_DISTRIBUTION` enabled for Cards.
* `MOCards` class renamed to `MoEngageCards` because of an [issue](https://developer.apple.com/documentation/xcode-release-notes/xcode-11_2-release-notes#Swift) in Xcode.

### Version 1.0.2  *(12th November, 2020)*
-------------------------------------------
* Swift ModuleMap for Simulator architecture was not merged to the final build.
* Whitelisted Cards Events for GDPR opt-outs

### Version 1.0.1  *(2nd November, 2020)*
-------------------------------------------
* Xcode 12 Build settings changes to exclude arm64 architecture for Simulator.

### Version 1.0.0  *(2nd July, 2020)*
-------------------------------------------
* First release for supporting Cards Campaign in App - [doc](https://docs.moengage.com/docs/ios-cards)


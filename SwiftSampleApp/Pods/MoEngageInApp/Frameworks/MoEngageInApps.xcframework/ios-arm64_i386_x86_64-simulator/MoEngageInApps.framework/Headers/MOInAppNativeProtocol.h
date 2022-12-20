//
//  MOInAppNativeProtocol.h
//  MoEngage
//
//  Created by Chengappa C D on 01/11/21.
//  Copyright © 2021 MoEngage. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MoEngageInApps/MOInAppCampaign.h>
#import <MOCore/MOCore-Swift.h>

#ifndef MOInAppNativeProtocol_h
#define MOInAppNativeProtocol_h
#endif

/// NudgePosition Enumerator to show Nudge InApp Campaigns at Top/Bottom position in a screen.
typedef enum{
    NudgePositionTop,
    NudgePositionBottom
}NudgePosition;


NS_ASSUME_NONNULL_BEGIN

/// Completion Block for getting the Nudge InApp Campaign, which is used in case an inApp has to be embedded in your screen.
/// It gives nudge UIView instance and MOInAppCampaign instance giving campaign info.
typedef void(^NudgeCreationCompletionBlock)(UIView * _Nullable nudgeView, MOInAppCampaign* _Nullable campaignInfo, MOAccountMeta* _Nullable accountMeta);

#pragma mark - InApp Protocol
/**
 Confirm to this protocol to get all the inApp campaigns related callbacks
 */
@protocol MOInAppNativDelegate <NSObject>
@optional

/// This method will be called when an inApp Campaign is shown by the SDK
/// @param inappCampaign MOInAppCampaign instance providing the info of the campaign currently being shown
/// @param accountMeta  MOAccountMeta instance providing the info of the MoEngage Account to which the campaign belongs
-(void)inAppShownWithCampaignInfo:(MOInAppCampaign*)inappCampaign forAccountMeta:(MOAccountMeta*)accountMeta;

/// This method will be called when a inApp is clicked by the user to perform a navigation action
/// @param inappCampaign MOInAppCampaign instance providing the info of the campaign which is clicked by the user
/// @param navigationAction MOInAppAction instance giving navigation action info along with key-value pairs provided while creating the campaign
/// @param accountMeta  MOAccountMeta instance providing the info of the MoEngage Account to which the campaign belongs
-(void)inAppClickedWithCampaignInfo:(MOInAppCampaign*)inappCampaign andNavigationActionInfo:(MOInAppAction*)navigationAction forAccountMeta:(MOAccountMeta*)accountMeta;;

/// This method will be called when an inApp Campaign is clicked by the user to perform Custom Action
/// @param inappCampaign MOInAppCampaign instance providing the info of the campaign which is clicked by the user
/// @param customAction MOInAppAction instance giving custom action info along with key-value pairs provided while creating the campaign
/// @param accountMeta  MOAccountMeta instance providing the info of the MoEngage Account to which the campaign belongs
-(void)inAppClickedWithCampaignInfo:(MOInAppCampaign*)inappCampaign andCustomActionInfo:(MOInAppAction*)customAction forAccountMeta:(MOAccountMeta*)accountMeta;;

/// This method will be called when an inApp is dismissed
/// @param inappCampaign MOInAppCampaign instance providing the info of the campaign which is being dissmissed by the user
/// @param accountMeta  MOAccountMeta instance providing the info of the MoEngage Account to which the campaign belongs
-(void)inAppDismissedWithCampaignInfo:(MOInAppCampaign*)inappCampaign forAccountMeta:(MOAccountMeta*)accountMeta;;

/// This method will be only be called when a self handled inApp is triggered by an event
/// @param inappCampaign MOInAppSelfHandledCampaign instance with self handled inApp info
/// @param accountMeta  MOAccountMeta instance providing the info of the MoEngage Account to which the campaign belongs
-(void)selfHandledInAppTriggeredWithInfo:(MOInAppSelfHandledCampaign*)inappCampaign forAccountMeta:(MOAccountMeta*)accountMeta;;

@end

NS_ASSUME_NONNULL_END

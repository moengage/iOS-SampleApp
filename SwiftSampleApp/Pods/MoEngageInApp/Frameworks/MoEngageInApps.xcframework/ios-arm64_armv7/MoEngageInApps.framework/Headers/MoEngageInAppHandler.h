//
//  MoEngageInAppHandler.h
//  MoEngageInApps
//
//  Created by Chengappa C D on 20/10/21.
//  Copyright © 2021 MoEngage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MoEngageInApps/MoEngageNudgePosition.h>
#import <MoEngageCore/MoEngageCore-Swift.h>

@class MoEngageInAppCampaign;
@class MoEngageInAppSelfHandledCampaign;
@protocol MoEngageInAppNativeDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface MoEngageInAppHandler : NSObject

#pragma mark- Initialize

/// Shared Instance for using InApp module features
+(instancetype)sharedInstance;

#pragma mark- InApp Delegate Handling
/// Method to set delegate for the inApp Callbacks
/// @param delegate MoEngageInAppNativDelegate which will all the callbacks
/// @param appID MoEngage Account Identifier.
-(void)setInAppDelegate:(id<MoEngageInAppNativeDelegate> _Nullable)delegate forAppID:(NSString* _Nullable)appID;

/// Method to reset the inApp Delegate
/// @param appID MoEngage Account Identifier.
-(void)resetInAppDelegateForAppID:(NSString* _Nullable)appID;

#pragma mark- Context Methods

/// Method to set the current inApp contexts, this is so that campaign with contexts will only be shown when the current context contains the campaign context
/// @param contexts Array of contexts
/// @param appID MoEngage Account Identifier.
-(void)setCurrentInAppContexts:(NSArray*)contexts forAppID:(NSString* _Nullable)appID;

/// Call this methods to invalidate/reset the contexts set currently in the app.
/// @param appID MoEngage Account Identifier.
-(void)invalidateInAppContextsForAppID:(NSString* _Nullable)appID;

#pragma mark- Show In-App Pop

/// Call this method to show Pop-up OR Fullscreen InApps inside the app.
/// @param appID MoEngage Account Identifier.
-(void)showInAppCampaignForAppID:(NSString* _Nullable)appID;

/// Call this method to block InApps in a particular ViewController
/// @param viewController UIViewController instance where InApps have to be blocked
/// @param appID MoEngage Account Identifier.
-(void)blockInAppInViewController:(UIViewController* _Nonnull)viewController forAppID:(NSString* _Nullable)appID;

#pragma mark- Nudge Campaign

/// Method to show Nudge campaign at the specified position
/// @param nudgePosition specifies the position where the nudge has to be showed Top/Bottom.
/// @param appID MoEngage Account Identifier.
-(void)showNudgeAtPosition:(MoEngageNudgePosition)nudgePosition forAppID:(NSString* _Nullable)appID;

/// Method to get the UIView instance of the nudge to embed it anywhere inside the app
/// @param appID MoEngage Account Identifier.
/// @param completionBlock Completion Block for getting the Nudge InApp Campaign, which is used in case an inApp has to be embedded in your screen.
/// -- It gives nudge UIView instance and MoEngageInAppCampaign instance giving campaign info.
-(void)getNudgeViewForAppID:(NSString* _Nullable)appID withCompletionBlock:(NudgeCreationCompletionBlock)completionBlock;

/// Incase Nudge campaign is obtained using getNudgeViewWithCompletionBlock: and embedded by developers in the app, this method has to be called to inform if the nudge is shown successfully to the user.
/// @param campaignInfo MoEngageInAppCampaign instance with the campaign info.
/// @param appID MoEngage Account Identifier.
-(void)nudgeCampaignShownWithCampaignInfo:(MoEngageInAppCampaign* _Nullable)campaignInfo forAppID:(NSString* _Nullable)appID;

#pragma mark- SelfHandled Campaign

/// Method to obtain self-handled inApp Campaign.
/// @param appID MoEngage Account Identifier.
/// @param completionBlock Completion Block which provides MoEngageInAppSelfHandledCampaign* instance(campaignInfo), incase one is active and satisfies all the rule checks OR else campaignInfo will be nil.
-(void)getSelfHandledInAppForAppID:(NSString* _Nullable)appID withCompletionBlock:(void(^)(MoEngageInAppSelfHandledCampaign* _Nullable campaignInfo, MoEngageAccountMeta* _Nullable accountMeta)) completionBlock;

/// Method to be called if a self-handled InApp is shown inside the app
/// @param campaignInfo MoEngageInAppSelfHandledCampaign instance with the campaign info.
/// @param appID MoEngage Account Identifier.
-(void)selfHandledShownWithCampaignInfo:(MoEngageInAppSelfHandledCampaign*)campaignInfo forAppID:(NSString* _Nullable)appID;

/// Method to be called if a self-handled InApp is clicked by the user
/// @param campaignInfo MoEngageInAppSelfHandledCampaign instance with the campaign info.
/// @param appID MoEngage Account Identifier.
-(void)selfHandledClickedWithCampaignInfo:(MoEngageInAppSelfHandledCampaign*)campaignInfo forAppID:(NSString* _Nullable)appID;

/// Method to be called if a self-handled InApp is dismissed by the user
/// @param campaignInfo MoEngageInAppSelfHandledCampaign instance with the campaign info.
/// @param appID MoEngage Account Identifier.
-(void)selfHandledDismissedWithCampaignInfo:(MoEngageInAppSelfHandledCampaign*)campaignInfo forAppID:(NSString* _Nullable)appID;

#pragma mark- Disable InApps

/// Method to disable inApps module
/// @param appID MoEngage Account Identifier.
-(void)disableInAppsForAppID:(NSString* _Nullable)appID;

@end

NS_ASSUME_NONNULL_END

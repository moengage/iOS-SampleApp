//
//  MOInApp.h
//  MoEngageInApps
//
//  Created by Chengappa C D on 20/10/21.
//  Copyright © 2021 MoEngage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MoEngageInApps/MOInAppCampaign.h>
#import <MoEngageInApps/MOInAppNativeProtocol.h>
#import <MOCore/MOCore-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOInApp : NSObject

#pragma mark- Initialize

/// Shared Instance for using InApp module features
+(instancetype)sharedInstance;

#pragma mark- InApp Delegate Handling
/// Method to set delegate for the inApp Callbacks
/// @param delegate MOInAppNativDelegate which will all the callbacks
/// @param appID MoEngage Account Identifier.
-(void)setInAppDelegate:(id<MOInAppNativDelegate> _Nullable)delegate forAppID:(NSString* _Nullable)appID;

/// Method to reset the inApp Delegate
/// @param appID MoEngage Account Identifier.
-(void)resetInAppDelegateForAppID:(NSString* _Nullable)appID;

/// Method to set delegate for the inApp Callbacks for Default Instance
/// @param delegate MOInAppNativDelegate which will all the callbacks
-(void)setInAppDelegate:(id<MOInAppNativDelegate>)delegate;

/// Method to reset the inApp Delegate for Default Instance
-(void)resetInAppDelegate;

#pragma mark- Context Methods

/// Method to set the current inApp contexts, this is so that campaign with contexts will only be shown when the current context contains the campaign context
/// @param contexts Array of contexts
/// @param appID MoEngage Account Identifier.
-(void)setCurrentInAppContexts:(NSArray*)contexts forAppID:(NSString* _Nullable)appID;

/// Method to set the current inApp contexts for Default MoEngage Instance, this is so that campaign with contexts will only be shown when the current context contains the campaign context
/// @param contexts Array of contexts
-(void)setCurrentInAppContexts:(NSArray*)contexts;


/// Call this methods to invalidate/reset the contexts set currently in the app.
/// @param appID MoEngage Account Identifier.
-(void)invalidateInAppContextsForAppID:(NSString* _Nullable)appID;

/// Call this methods to invalidate/reset the contexts set currently in the app for Default MoEngage Instance.
-(void)invalidateInAppContexts;

#pragma mark- Show In-App Pop

/// Call this method to show Pop-up OR Fullscreen InApps inside the app.
/// @param appID MoEngage Account Identifier.
-(void)showInAppCampaignForAppID:(NSString* _Nullable)appID;

/// Call this method to show Pop-up OR Fullscreen InApps inside the app for Default MoEngage Instance
-(void)showInAppCampaign;

/// Call this method to block InApps in a particular ViewController
/// @param viewcontroller ViewController instance where InApps have to be blocked
/// @param appID MoEngage Account Identifier.
-(void)blockInAppInViewController:(UIViewController* _Nonnull)viewcontroller forAppID:(NSString* _Nullable)appID;

/// Call this method to block InApps in a particular ViewController for Default MoEngage Instance
/// @param viewcontroller ViewController instance where InApps have to be blocked
-(void)blockInAppInViewController:(UIViewController* _Nonnull)viewcontroller;

#pragma mark- Nudge Campaign

/// Method to show Nudge campaign at the specified position
/// @param nudgePosition specifies the position where the nudge has to be showed Top/Bottom.
/// @param appID MoEngage Account Identifier.
-(void)showNudgeAtPosition:(NudgePosition)nudgePosition forAppID:(NSString* _Nullable)appID;

/// Method to show Nudge campaign at the specified position for Default MoEngage Instance
/// @param nudgePosition specifies the position where the nudge has to be showed Top/Bottom.
-(void)showNudgeAtPosition:(NudgePosition)nudgePosition;

/// Method to get the UIView instance of the nudge to embed it anywhere inside the app
/// @param appID MoEngage Account Identifier.
/// @param completionBlock Completion Block for getting the Nudge InApp Campaign, which is used in case an inApp has to be embedded in your screen.
/// -- It gives nudge UIView instance and MOInAppCampaign instance giving campaign info.
-(void)getNudgeViewForAppID:(NSString* _Nullable)appID withCompletionBlock:(NudgeCreationCompletionBlock)completionBlock;

/// Method to get the UIView instance of the nudge to embed it anywhere inside the app for Default MoEngage Instance
/// @param completionBlock Completion Block for getting the Nudge InApp Campaign, which is used in case an inApp has to be embedded in your screen.
-(void)getNudgeViewWithCompletionBlock:(NudgeCreationCompletionBlock)completionBlock;

/// Incase Nudge campaign is obtained using getNudgeViewWithCompletionBlock: and embedded by developers in the app, this method has to be called to inform if the nudge is shown successfully to the user.
/// @param campaignInfo MOInAppCampaign instance with the campaign info.
/// @param appID MoEngage Account Identifier.
-(void)nudgeCampaignShownWithCampaignInfo:(MOInAppCampaign*)campaignInfo forAppID:(NSString* _Nullable)appID;

/// Incase Nudge campaign is obtained for Default MoEngage Instance using getNudgeViewWithCompletionBlock: and embedded by developers in the app, this method has to be called to inform if the nudge is shown successfully to the user.
/// @param campaignInfo MOInAppCampaign instance with the campaign info.
-(void)nudgeCampaignShownWithCampaignInfo:(MOInAppCampaign*)campaignInfo;

#pragma mark- SelfHandled Campaign

/// Method to obtain self-handled inApp Campaign.
/// @param appID MoEngage Account Identifier.
/// @param completionBlock Completion Block which provides MOInAppSelfHandledCampaign* instance(campaignInfo), incase one is active and satisfies all the rule checks OR else campaignInfo will be nil.
-(void)getSelfHandledInAppForAppID:(NSString* _Nullable)appID withCompletionBlock:(void(^)(MOInAppSelfHandledCampaign* _Nullable campaignInfo, MOAccountMeta* _Nullable accountMeta)) completionBlock;

/// Method to obtain self-handled inApp Campaign for Default MoEngage Instance.
/// @param completionBlock Completion Block which provides MOInAppSelfHandledCampaign* instance(campaignInfo), incase one is active and satisfies all the rule checks OR else campaignInfo will be nil.
-(void)getSelfHandledInAppWithCompletionBlock:(void(^)(MOInAppSelfHandledCampaign* _Nullable campaignInfo, MOAccountMeta* _Nullable accountMeta))completionBlock;


/// Method to be called if a self-handled InApp is shown inside the app
/// @param campaignInfo MOInAppSelfHandledCampaign instance with the campaign info.
/// @param appID MoEngage Account Identifier.
-(void)selfHandledShownWithCampaignInfo:(MOInAppSelfHandledCampaign*)campaignInfo forAppID:(NSString* _Nullable)appID;

/// Method to be called if a self-handled InApp is shown inside the app for Default MoEngage Instance
/// @param campaignInfo MOInAppSelfHandledCampaign instance with the campaign info.
-(void)selfHandledShownWithCampaignInfo:(MOInAppSelfHandledCampaign*)campaignInfo;


/// Method to be called if a self-handled InApp is clicked by the user
/// @param campaignInfo MOInAppSelfHandledCampaign instance with the campaign info.
/// @param appID MoEngage Account Identifier.
-(void)selfHandledClickedWithCampaignInfo:(MOInAppSelfHandledCampaign*)campaignInfo forAppID:(NSString* _Nullable)appID;

/// Method to be called if a self-handled InApp is clicked by the user for Default MoEngage Instance
/// @param campaignInfo MOInAppSelfHandledCampaign instance with the campaign info.
-(void)selfHandledClickedWithCampaignInfo:(MOInAppSelfHandledCampaign*)campaignInfo;

/// Method to be called if a self-handled InApp is dismissed by the user
/// @param campaignInfo MOInAppSelfHandledCampaign instance with the campaign info.
/// @param appID MoEngage Account Identifier.
-(void)selfHandledDismissedWithCampaignInfo:(MOInAppSelfHandledCampaign*)campaignInfo forAppID:(NSString* _Nullable)appID;

/// Method to be called if a self-handled InApp is dismissed by the user for Default MoEngage Instance
/// @param campaignInfo MOInAppSelfHandledCampaign instance with the campaign info.
-(void)selfHandledDismissedWithCampaignInfo:(MOInAppSelfHandledCampaign*)campaignInfo;

#pragma mark- Disable InApps

/// Method to disable inApps module
/// @param appID MoEngage Account Identifier.
-(void)disableInAppsForAppID:(NSString* _Nullable)appID;

/// Method to disable inApps module for Default MoEngage Instance
-(void)disableInApps;

@end

NS_ASSUME_NONNULL_END

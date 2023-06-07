//
//  UserRegistrationUtils.swift
//  MoEngageiOSSampleApp
//
//  Created by Rakshitha on 07/06/23.
//

import Foundation
import MoEngageSDK

class UserRegistrationUtils {
    func getJwtId(completionHandler: @escaping(String?)->()) {

        getMoEngageDeviceId { deviceId in
            guard let deviceId = deviceId
            else {
                completionHandler(nil)
                return
            }
            let pushToken = self.getPushToken()
            let customerId = self.getCustomerId()
            
            //  generate jwt id :  ["deviceId": deviceId,"pushToken": pushToken,"moEngageCustId": customerId]
            // dummy value added just for reference.
            let jwtId: String = "12345"
            completionHandler(jwtId)
        }
    }
    
    func getMoEngageDeviceId(completionHandler: @escaping(String?)->()) {
        MoEngageSDKCore.sharedInstance.getMoEngageDeviceId { userInfo in
            completionHandler(userInfo.uniqueId)
        }
    }
    
    func getCustomerId() -> String {
        // Add your logic to return customer id.
        return "123"
    }
    
     func getPushToken() -> String {
        // Add your logic to return Push token
        return "123"
    }
}
 

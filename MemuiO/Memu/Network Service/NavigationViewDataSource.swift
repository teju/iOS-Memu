//
//  NavigationViewDataSource.swift
//  Memu
//
//  Created by Tejaswini N on 15/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SwiftyJSON
import SwiftLocation
import CoreLocation
extension RestDataSource {

/// performs email exists or not
/// /// - Parameters:
///   - mobileNo: mobileNo
///API Used:  POST https://memu.world/api/web/user/login

    static func mapFeedsList(address : [String: Any]) -> Observable<MapFeedsResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "location_details":address]
        return json(.post, "map-feeds/data",
                    parameters: sendParameters)
            .map { json in
                MapFeedsResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func mapFeedspopupList() -> Observable<AlertMapFeedsResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id]
        return json(.post, "map-feeds",
                    parameters: sendParameters)
            .map { json in
                AlertMapFeedsResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func getVehicleList() -> Observable<VehicleListResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id]
        return json(.post, "user/pooler-vehicle-list",
                    parameters: sendParameters)
            .map { json in
                VehicleListResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postUserMainData(user_id : String) -> Observable<UserMainData> {
        
        let sendParameters: [String: Any] = [
            "user_id": user_id]
        return json(.post, "profile/user-main-data",
                    parameters: sendParameters)
            .map { json in
                UserMainData(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postWalletData(user_id : String) -> Observable<WalletBalance> {
        
        let sendParameters: [String: Any] = [
            "user_id": user_id]
        return json(.post, "payment/wallet-balance",
                    parameters: sendParameters)
            .map { json in
                WalletBalance(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postpayment(wallet : [String : Any],mode : String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,"wallet_details":wallet,"payment_details":[String : Any](),"mode":"wallet"]
        return json(.post, "payment/pay",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postTopEarners(user_id : String) -> Observable<TopEarners> {
        
        let sendParameters: [String: Any] = [
            "user_id": user_id]
        return json(.post, "profile/top-earners",
                    parameters: sendParameters)
            .map { json in
                TopEarners(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postchecksum(paytm_params : [String: Any]) -> Observable<CheckSum> {
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,"paytm_params":paytm_params]
        return json(.post, "payment/initiate-transaction",
                parameters: sendParameters)
                    .map { json in
                        CheckSum(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postgetProfile(user_id : String) -> Observable<UserProfile> {
        
        let sendParameters: [String: Any] = [
            "user_id": user_id]
        return json(.post, "profile/user-details",
                    parameters: sendParameters)
            .map { json in
                UserProfile(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
     static func postsaveProfile(userInfo : [String : Any]) -> Observable<ResponceResult> {
           return json(.post, "profile/user-update",
                       parameters: userInfo)
               .map { json in
                   ResponceResult(json: JSON(json.dictionaryObject!))
           }
           .restSend()
       }
    static func getWalletBalance(user_id : String) -> Observable<WalletResponse> {
        let sendParameters: [String: Any] = [
            "user_id": user_id]
        return json(.post, "payment/wallet-balance",
                    parameters: sendParameters)
            .map { json in
                WalletResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postPayment(mode:String,payment_details:[String: Any],wallet_details:[String: Any]) -> Observable<ResponceResult> {
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,"mode":mode,"payment_details":payment_details,"wallet_details":wallet_details]
        return json(.post, "payment/pay",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postPendingList(type : String , request : String) -> Observable<FriendsListResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,"offset":0,
            "limit":10000,"type":type,"request":request]
        return json(.post, "profile/friend-pending-list",
                    parameters: sendParameters)
            .map { json in
                FriendsListResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postAcceptRemove(type : String ,freind_id : String,status : String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,"offset":0,
            "limit":10000,"type":type,"freind_id":freind_id,"status":status]
        return json(.post, "profile/accept-friend-request",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postusermapfeedlike(flag : String,user_map_feed_id : String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,"flag":flag,
            "user_map_feed_id":user_map_feed_id]
        return json(.post, "profile/user-map-feed-like",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postFriendList(type : String , request : String,search_word :String,searchByLoc : Int,user_id : String) -> Observable<FriendsListResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": user_id,"offset":0,
            "limit":10000,"type":type,"request":request,"search_word":search_word,"searchByLoc":searchByLoc]
        return json(.post, "profile/friend-list",
                    parameters: sendParameters)
            .map { json in
                FriendsListResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postUserWall(type : String ,friend_id : String) -> Observable<UserWallResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,"offset":0,
            "limit":10000,"type":type,"freind_id":friend_id]
        return json(.post, "profile/activities",
                    parameters: sendParameters)
            .map { json in
                UserWallResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postFriendRequest(type : String ,friend_id : String) -> Observable<AddFriend> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,"offset":0,
            "limit":10000,"type":type,"freind_id":friend_id]
        return json(.post, "profile/friend-request",
                    parameters: sendParameters)
            .map { json in
                AddFriend(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postSearchFriendList(search_word :String) -> Observable<FriendsListResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,"offset":0,
            "limit":10000,"search_word":search_word]
        return json(.post, "profile/search-user",
                    parameters: sendParameters)
            .map { json in
                FriendsListResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func startTrip(trip_id : String,no_of_kms:String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "no_of_kms":no_of_kms,
            "user_id": UserDefaults.user_id,
            "trip_id":trip_id]
        return json(.post, "booking/start-trip",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func startTripCustomer(trip_id : String,no_of_kms:String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "no_of_kms":no_of_kms,
            "user_id": UserDefaults.user_id,
            "trip_rider_id":trip_id]
        return json(.post, "booking/customer-checkin",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func endTripCustomer(trip_id : String,trip_rider_id:String,no_of_kms:String) -> Observable<EndTripID> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "trip_rider_id": trip_rider_id,
            "no_of_kms":no_of_kms,
            "trip_id":trip_id]
        return json(.post, "booking/customer-end-trip",
                    parameters: sendParameters)
            .map { json in
                EndTripID(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func endTripCustomerID(trip_rider_id:String) -> Observable<EndTripID> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "trip_rider_id": trip_rider_id]
        return json(.post, "booking/customer-end-trip-id",
                    parameters: sendParameters)
            .map { json in
                EndTripID(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func newstartshortestpathTrip(action : String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "action":action]
        return json(.post, "profile/shortest-path-start-stop",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func endtTrip(trip_id : String,no_of_kms :String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "trip_id":trip_id,
            "no_of_kms":no_of_kms]
        return json(.post, "booking/end-trip",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func getTripSummary(trip_id : String,type : String) -> Observable<TripSummary> {
        
        let sendParameters: [String: Any] = [
            "type":type,
            "user_id": UserDefaults.user_id,
            "trip_id":trip_id]
        return json(.post, "booking/trip-summary",
                    parameters: sendParameters)
            .map { json in
                TripSummary(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postEditRecuring(id : String,date:String,type:String,no_of_seats:String,vehicle_id :String,status : String,is_recurring_ride : String,days : String,from : Address,to : Address,time : String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "id":id,
            "date":date,
            "time":time,
            "type":type,
            "no_of_seats":no_of_seats,
            "vehicle_id":vehicle_id,
            "status":status,
            "is_recurring_ride":is_recurring_ride,
            "days":days,
            "from":from.toParams2(),
            "to":to.toParams2()]

        return json(.post, "booking/edit-recuring-rides",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func getHistoryList(url : String) -> Observable<HistoryResponse> {
           
           let sendParameters: [String: Any] = [
               "user_id": UserDefaults.user_id,
                "offset":0,
                "limit":10000]
        
           return json(.post, url,
                       parameters: sendParameters)
               .map { json in
                   HistoryResponse(json: JSON(json.dictionaryObject!))
           }
           .restSend()
       }
    static func getRecurryingList() -> Observable<HistoryResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
             "offset":0,
             "limit":10000]
     
        return json(.post, "booking/my-recuring-rides",
                    parameters: sendParameters)
            .map { json in
                HistoryResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postRequestRide(to_user_id : String,type : String,id : String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
             "to_user_id":to_user_id,
            "id":id,
             "type":type]
     
        return json(.post, "booking/request-push-notification-to-ridetaker-pooler",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func postRequestApproveReject(statusType : String,type : String,trip_id : String,trip_rider_id:String) -> Observable<ResponceResult> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
             "status":statusType,
                "trip_id":trip_id,
            "trip_rider_id":trip_rider_id,
             "type":type]
     
        return json(.post, "booking/ride-approve-reject",
                    parameters: sendParameters)
            .map { json in
                ResponceResult(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func matchingBuddiesList(trip_or_rider_id : String,type : String) -> Observable<MatchingBuddiesResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "trip_or_rider_id":trip_or_rider_id,
             "type":type,
             "offset":0,
             "limit":10000]
        return json(.post, "booking/ride-taker-pooler-suggession",
                    parameters: sendParameters)
            .map { json in
                MatchingBuddiesResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func addmapFeeds(address : [String: Any],feed_id : String) -> Observable<AlertMapFeedsResponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "feed_id":feed_id,
            "Address":address]
        return json(.post, "map-feeds/add",
                    parameters: sendParameters)
            .map { json in
                AlertMapFeedsResponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
    static func findOfferRide(date : String,time : String,no_of_seats:Int,is_recuring_ride:String,type:String,no_of_kms:String,toaddress : [String: Any],fromaddress : [String: Any],days : String,vehicle_id : String,rs_per_kms: String) -> Observable<FindOfferRideREsponse> {
        
        let sendParameters: [String: Any] = [
            "user_id": UserDefaults.user_id,
            "date":date,
            "time":time,
            "no_of_seats":no_of_seats,
            "is_recuring_ride":is_recuring_ride,
            "type":type,
            "no_of_kms":no_of_kms,
            "to":toaddress,
            "from":fromaddress,
            "vehicle_id":vehicle_id,
            "rs_per_kms":rs_per_kms,
            "days":days]
        
        return json(.post, "booking/offer-find-ride",
                    parameters: sendParameters)
            .map { json in
                FindOfferRideREsponse(json: JSON(json.dictionaryObject!))
        }
        .restSend()
    }
}

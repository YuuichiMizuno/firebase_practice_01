//
//  ViewController.swift
//  firebase_practice_01
//
//  Created by yuichi.watanabe on 2016/11/15.
//  Copyright © 2016年 yuichi.watanabe. All rights reserved.
//
/*
 * note: シュミレーターでは、エラーになったので、実機で確認
 *        忘れてて、急にあたふたするあるある
 *       順番が守られていないようである。
 *       こちらでソートが必要になる
 *
 *       変わったインデントをしていますが、これは私が見やすくて好きだからです
 */

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase  // すでに含まれていますがあえて
import FirebaseAnalytics // すでに含まれていますがあえて

class ViewController: JSQMessagesViewController
{
//    var messages: [JSQMessage] = [
//        JSQMessage(senderId: "Dummy",  displayName: "A", text: "こんにちは!"),
//        JSQMessage(senderId: "Dummy2", displayName: "B", text: "こんにちは♪")
//    ]
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages() // // //
    }
    
    
    // MARK: - JSQMessagesViewController  override
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        inputToolbar.contentView.textView.text = ""
        sendMessage(messageText: text, senderId: senderId, senderDisplayName: senderDisplayName, date: date) // // //
    }
    
    // MARK: - collectionView delegate
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.row].senderId == senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(
                with: UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(
                with: UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell
        if messages[indexPath.row].senderId == senderId {
            cell?.textView?.textColor = UIColor.white
        } else {
            cell?.textView?.textColor = UIColor.darkGray
        }
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return JSQMessagesAvatarImageFactory.avatarImage(
            withUserInitials: messages[indexPath.row].senderDisplayName,
            backgroundColor: UIColor.lightGray, textColor: UIColor.white,
            font: UIFont.systemFont(ofSize: 10), diameter: 30)
    }
    
    
    
    
    
    // MARK: - private

    // MARK: - firebase database
    fileprivate func sendMessage(messageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let ref = FIRDatabase.database().reference()
            ref.child("messages").childByAutoId().setValue(["senderId": senderId, "text": text, "displayName": senderDisplayName])
            // 指定したパスの(child)新しい子供オブジェクトを(childByAutoId)データベースに書き込みます(setValue)
        
        
        // test
        analyticsEventAll()
    }
    
    fileprivate func loadMessages()
    {
//        senderDisplayName   = "A"
//        senderId            = "Dummy"
                senderDisplayName   = "B"
                senderId            = "Dummy2"
        let ref = FIRDatabase.database().reference()
            ref.observe(.value, with: { snapshot in
                guard let dic = snapshot.value as? Dictionary<String, AnyObject> else {
                    return
                }
                guard let posts = dic["messages"] as? Dictionary<String, Dictionary<String, String>> else {
                    return
                }
                self.messages   = posts.values.map { dic in
                    let senderId    = dic["senderId"] ?? ""
                    let text        = dic["text"] ?? ""
                    let displayName = dic["displayName"] ?? ""
                    return JSQMessage(senderId: senderId,  displayName: displayName, text: text)
                }
                self.collectionView.reloadData()
            })
            // データ変更をリスンします(データを読み取る主な方法)
            // ブロックスで結果を取得、ビューを再描画しています
            // `JSQMessage`クラスは、単一のユーザメッセージを表すメッセージモデルオブジェクトの具体的なクラスです
    }
    

    // MARK: - firebase analytics
    fileprivate func analyticsEvent() {
        
    }
    
    fileprivate func analyticsEventAll() {
        
        FIRAnalytics.setScreenName("view_first_root", screenClass: "NormalUIViewController")
        
        FIRAnalytics.setUserPropertyString("111", forName: "dailyLoginBonusCount")
        FIRAnalytics.setUserPropertyString("true", forName: "firstGenarationUser")
        
        FIRAnalytics.logEvent(withName: "kFIREventAddPaymentInfo", parameters: nil)
        FIRAnalytics.logEvent(withName: "kFIREventAddToCart", parameters: [
            kFIRParameterQuantity:NSNumber(value:1),
            kFIRParameterItemID:"123" as NSObject,
            kFIRParameterItemName:"nameabc" as NSObject
            ])
        FIRAnalytics.logEvent(withName: "kFIREventAddToWishlist", parameters: [
            kFIRParameterQuantity:NSNumber(value:123),
            kFIRParameterPrice:NSNumber(value:123)
            ])
//        FIRAnalytics.logEvent(withName: "kFIREventAppOpen", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventBeginCheckout", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventEarnVirtualCurrency", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventEcommercePurchase", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventGenerateLead", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventJoinGroup", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventLevelUp", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventLogin", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventPostScore", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventPresentOffer", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventPurchaseRefund", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventSearch", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventSelectContent", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventShare", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventSignUp", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventSpendVirtualCurrency", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventTutorialBegin", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventTutorialComplete", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventUnlockAchievement", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventViewItem", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventViewItemList", parameters: <#T##[String : NSObject]?#>)
//        FIRAnalytics.logEvent(withName: "kFIREventViewSearchResults", parameters: <#T##[String : NSObject]?#>)
        
        FIRAnalytics .setUserID("ID1231231234")
        
        
    }
    
    
    
    
}




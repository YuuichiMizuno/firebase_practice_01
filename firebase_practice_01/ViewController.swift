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
 */

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase

class ViewController: JSQMessagesViewController
{
//    var messages: [JSQMessage] = [
//        JSQMessage(senderId: "Dummy",  displayName: "A", text: "こんにちは!"),
//        JSQMessage(senderId: "Dummy2", displayName: "B", text: "こんにちは♪")
//    ]
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //senderDisplayName   = "A"
        //senderId            = "Dummy"
        loadMessages()
    }

    
    
    
    // MARK: - JSQMessagesViewController  override
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        inputToolbar.contentView.textView.text = ""
        let ref = FIRDatabase.database().reference()
        ref.child("messages").childByAutoId().setValue(
            ["senderId": senderId, "text": text, "displayName": senderDisplayName])
    }
    
    // MARK:  JSQMessagesViewController  private
    fileprivate func loadMessages() {
        senderDisplayName   = "A"
        senderId            = "Dummy"
        
//        senderDisplayName   = "B"
//        senderId            = "Dummy2"
        
        let ref = FIRDatabase.database().reference()
            ref.observe(.value, with: { snapshot in
                guard let dic = snapshot.value as? Dictionary<String, AnyObject> else {
                    return
                }
                guard let posts = dic["messages"] as? Dictionary<String, Dictionary<String, String>> else {
                    return
                }
                self.messages = posts.values.map { dic in
                    let senderId = dic["senderId"] ?? ""
                    let text = dic["text"] ?? ""
                    let displayName = dic["displayName"] ?? ""
                    return JSQMessage(senderId: senderId,  displayName: displayName, text: text)
                }
                self.collectionView.reloadData()
            })
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
}




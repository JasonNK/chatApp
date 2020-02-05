//
//  HomeViewController.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/27/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase
import Popover

class FeedViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var feeds: [[String: Any]] = []
    let databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    let popover = Popover()
    var curUserId: String?
    var curSelectedUserId: String?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .lightGray
        
        if let userId = Auth.auth().currentUser?.uid {
            self.curUserId = userId
        } else {
            print("Not login yet")
        }
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFeeds()
    }
    let listGroup = DispatchGroup()
    func getFeeds() {
        
        // 1. get all the data TODO why observerSingleEvent here
        // let userInfoGroup = DispatchGroup()

        var results = [[String:Any]]()
        databaseRef.child("Post").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let feeds = dataSnapshot.value as? [String:Any] else { return }
            
            for feed in feeds {
                self.listGroup.enter()
                var curResultDict = [String:Any]()
                let curFeedKey = feed.key
                let curFeed = feeds[curFeedKey] as! [String:Any] // TODO
                let curUserId = curFeed["userId"] as! String
                let curDesc = curFeed["desc"] as! String
                let curTime = curFeed["time"] as! String
                curResultDict["userId"] = curUserId
                curResultDict["desc"] = curDesc
                curResultDict["time"] = curTime
                // get feed pic
                self.storageRef.child("Feed").child(String(curFeedKey)).getData(maxSize: 2500000) { [unowned self](data, error) in
                    
                    if error != nil {
                        print("error in fetching feed image")
                        let feedImage = UIImage.init(data: data ?? Data())
                        curResultDict["feedImage"] = feedImage
                        
                    } else {
                        let feedImage = UIImage.init(data: data ?? Data())
                        curResultDict["feedImage"] = feedImage
                        
                    }
                    
                    self.databaseRef.child("User").child(curUserId).observeSingleEvent(of: .value) { (dataSnapshot) in
                        
                        guard let userData = dataSnapshot.value as? [String: Any] else { self.listGroup.leave(); print("error occurs when fetching user data"); return }
                        let userName = userData["FirstName"] as! String
                        curResultDict["userName"] = userName
                        print(curUserId)
                        self.storageRef.child("User/\(curUserId)").getData(maxSize: 5000000) { (data, error) in
                            
                            if error != nil {
                                print("error in fetching user image")
                                let userImage = UIImage.init(data: data ?? Data())
                                curResultDict["userImage"] = userImage
                                
                            } else {
                                let userImage = UIImage.init(data: data ?? Data())
                                curResultDict["userImage"] = userImage
                                
                            }
                            print("hehe")
                            results.append(curResultDict)
                            self.listGroup.leave()
                        }
                    }
                }
                
            }
            self.listGroup.notify(queue: .main) {
                results.sort { (dict1, dict2) -> Bool in
                    (dict1["time"] as! String) > (dict2["time"] as! String)
                }
                self.feeds = results
                self.collectionView.reloadData()
                
            }
        }
    }
    
}



extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    @objc func addFriendButtonInPopover(_ gesture: UITapGestureRecognizer) {
        databaseRef.child("Friends").child(self.curUserId!).child(self.curSelectedUserId!).setValue("friendID")
        popover.dismiss()
    }
    
    @objc func removeFriendButtonInPopover(_ gesture: UITapGestureRecognizer) {
        databaseRef.child("Friends").child(self.curUserId!).child(self.curSelectedUserId!).removeValue()
        popover.dismiss()
    }
    
    
    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {

        let curStartPoint = gesture.location(in: self.collectionView)
        let curPointInWindow = gesture.location(in: self.view)
        let curIndex = self.collectionView.indexPathForItem(at: curStartPoint)
        let curFeed = self.feeds[curIndex!.row]
        let curCellUserId = curFeed["userId"] as! String
        
        self.curSelectedUserId = curCellUserId
        
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: self.view.frame.width / 5))
        if curCellUserId == self.curUserId {
            // TODO it is me here
            print("Hi")
            return
        } else {
        databaseRef.child("Friends").child(self.curUserId!).child(self.curSelectedUserId!).observeSingleEvent(of: .value) { (dataSnapshot) in
            if let curFriendStatus = dataSnapshot.value as? String {
                    let curLabel = UILabel.init(frame: CGRect(x: aView.frame.minX + 5, y: aView.frame.minY + 15, width: aView.frame.width / 1.5, height: aView.frame.height / 2))
                    curLabel.text = "You are already friends!"
                    aView.addSubview(curLabel)
                    let btn = UIButton.init(frame: CGRect(x: curLabel.frame.minX, y: curLabel.frame.minY + 15, width: aView.frame.width / 1.5, height: aView.frame.height / 2))
                    btn.setTitle("Remove Friend", for: .normal)
                    btn.setTitleColor(.red, for: .normal)
                    btn.addTarget(self, action: #selector(self.removeFriendButtonInPopover), for: .touchDown)
                    aView.addSubview(btn)
                } else {
                    // if you are not friends
                    let btn = UIButton.init(frame: CGRect(x: aView.frame.minX + 5, y: aView.frame.minY + 15, width: aView.frame.width / 2, height: aView.frame.height / 2))
                    btn.setTitle("Add Friend", for: .normal)
                    btn.setTitleColor(.blue, for: .normal)
                    btn.addTarget(self, action: #selector(self.addFriendButtonInPopover(_:)), for: .touchDown)
                    aView.addSubview(btn)
                }
                
            self.popover.show(aView, point: curPointInWindow)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count", self.feeds)
        return self.feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as! CustomFeedCollectionViewCell

        let curData = self.feeds[indexPath.row]
        // TODO using curData to update the cell
        cell.updateCell(userId: curData["userId"] as? String, userFirstName: curData["userName"] as? String, desc: curData["desc"] as? String, feedImage: curData["feedImage"] as? UIImage, userImage: curData["userImage"] as? UIImage, time: curData["time"] as? String)
        if (curData["userId"] as! String) != self.curUserId {
            cell.deleteBtn.isHidden = true
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(imageTapped(_:)))
        cell.userImg.isUserInteractionEnabled = true
        cell.userImg.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
}

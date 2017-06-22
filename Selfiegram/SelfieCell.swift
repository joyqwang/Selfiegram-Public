//
//  SelfieCell.swift
//  Selfiegram
//
//  Created by Joy Qiaoyi Wang on 2017-05-31.
//  Copyright © 2017 Joy Qiaoyi Wang. All rights reserved.
//

import UIKit
import Parse

class SelfieCell: UITableViewCell {

    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var heartAnimationView: UIImageView!
    
    
    var post:Post? {
    // didSet is run when we set this variable in FeedViewController
    didSet{
        if let post = post {
    
        // I've added this line to prevent flickering of images
        // We are inside the cellForRowAtIndexPath method that gets called everything we layout a cell
        // Because we are reusing "postCell" cells, a reused cell might have an image already set on it.
        // This always resets the image to blank, waits for the image to download, and then sets it
        selfieImageView.image = nil
    
        let imageFile = post.image
        imageFile.getDataInBackground(block: {(data, error) -> Void in
            if let data = data {
            let image = UIImage(data: data)
            self.selfieImageView.image = image
            }
        })
    
        usernameLabel.text = post.user.username
        commentLabel.text = post.comment
            
        // set the likeButton defaulted to false
        likeButton.isSelected = false
            
            
        // query the likes property on post
        let query = post.likes.query()
        query.findObjectsInBackground(block: { (users, error) -> Void in
                
            if let users = users as? [PFUser]{
            for user in users {
                // If we find that the current user's objectId in our collection
                // of likes we set the likeButton to selected
                // objectId is a great way to compare if two objects are equal
                if user.objectId == PFUser.current()?.objectId {
                    self.likeButton.isSelected = true
                }
                }
            }
            })
        }
    }
}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    @IBAction func likeButtonClicked(_ sender: UIButton) {
        // the ! symbol means NOT
        // We are therefore setting the button's selected state to
        // the opposite of what it was. This is a great way to toggle buttons
        //
        sender.isSelected = !sender.isSelected
        
        // Get rid of Optionals
        if let post = post,
            let user = PFUser.current() {
            
            // like button has been selected and we should add a like from currentUser
            if sender.isSelected {
                
                // PFRelation has a useful method called addObject that adds the unique element
                // you are passing in as the argument. It will never add multiple copies
                // of the same element (in this case user)
                post.likes.add(user)
                
                // We have modified the likes property on post. We must now save it to Parse
                post.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("like from user successfully saved")
                        
                        // Creating an row in the Activity table
                        // Saving it as a "like" type
                        let activity = Activity(type: "like", user: user, post: post)
                        activity.saveInBackground(block: { (success, error) -> Void in
                            print("activity successfully saved")
                        })
                        
                    }else{
                        print("error is \(error)")
                    }
                })
            }
            else { // like button has been deselected and we should remove the like
                
                // PFRelation also has a useful method called removeObject that removes
                // the element if there is an element to be removed.
                post.likes.remove(user)
                post.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("like from user successfully removed")
                        
                        //PFQuery to find the like activity
                        if let activityQuery = Activity.query(){
                            activityQuery.whereKey("post", equalTo: post)
                            activityQuery.whereKey("user", equalTo: user)
                            activityQuery.whereKey("type", equalTo: "like")
                            activityQuery.findObjectsInBackground(block: { (activities, error) -> Void in
                                
                                
                                // You should only have one like activity from a user
                                // but this is code is being safe and checking for one or multiple instances
                                // and then deleting all of them
                                if let activities = activities {
                                    for activity in activities {
                                        activity.deleteInBackground(block: { (success, error) -> Void in
                                            print("deleted activity")
                                        })
                                    }
                                }
                            })
                        }

                    }else{
                        print("error is \(error)")
                    }
                })
                
            }
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tapAnimation() {
        // set heartAnimationView to be very tiny and not hidden
        self.heartAnimationView.isHidden = false
        self.heartAnimationView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        //animation for 1 second, no delay
        UIView.animate(withDuration: 1.0, delay: 0, options: [], animations: { () -> Void in
            
            // during our animation change heartAnimationView to be 3X what it is on storyboard
            self.heartAnimationView.transform = CGAffineTransform(scaleX: 3, y: 3)
            
        }) { (success) -> Void in
            
            // when animation is complete set heartAnimationView to be hidden
            self.heartAnimationView.isHidden = true
        }
        
        likeButtonClicked(likeButton)
    }

}

//
//  FeedViewController.swift
//  Selfiegram
//
//  Created by Joy Qiaoyi Wang on 2017-05-29.
//  Copyright © 2017 Joy Qiaoyi Wang. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var posts = [Post]()
    
    func getPosts() {
        if let query = Post.query() {
            query.order(byDescending: "createdAt")
            query.includeKey("user")
            
            query.findObjectsInBackground(block: { (posts, error) -> Void in
                self.refreshControl?.endRefreshing()
                if let posts = posts as? [Post]{
                    self.posts = posts
                    self.tableView.reloadData()
                }
                
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "Selfigram-logo"))
        
    }
    
    @IBAction func refreshPulled(_ sender: UIRefreshControl) {
        getPosts()
    }
    
    
    @IBAction func doubleTappedSelfie(_ sender: UITapGestureRecognizer) {
        
        // get the location (x,y) position on our tableView where we have clicked
        let tapLocation = sender.location(in: tableView)
        
        // based on the x, y position we can get the indexPath for where we are at
        if let indexPathAtTapLocation = tableView.indexPathForRow(at: tapLocation){
            
            // based on the indexPath we can get the specific cell that is being tapped
            let cell = tableView.cellForRow(at: indexPathAtTapLocation) as! SelfieCell
            
            //run a method on that cell.
            cell.tapAnimation()
        }
    }
    
//        let me = User(aUsername: "Joy", aProfileImage: UIImage(named: "profpic")!)
//        let post0 = Post(image: UIImage(named: "pineapple")!, user: me, comment: "PINEAPPLES!!!!")
//        let post1 = Post(image: UIImage(named: "richmond1")!, user: me, comment: "w0w sitting on ground so hip")
//        let post2 = Post(image: UIImage(named: "heritage")!, user: me, comment: "camera always eats first")
//        let post3 = Post(image: UIImage(named: "bluewall")!, user: me, comment: "tbh almost peed my pants")
//        let post4 = Post(image: UIImage(named: "gastown")!, user: me, comment: "hip stuff instagrammers do")
//        
//        posts = [post0, post1, post2, post3, post4]
        
//        let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=c93a07fe9e3994c5f30c4ba5f2181f4a&tags=travel")!
//        
//        let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
//            
//            // convert Data to JSON
//            if let jsonUnformatted = try? JSONSerialization.jsonObject(with: data!, options: []) {
//                
//                let json = jsonUnformatted as? [String : AnyObject]
//                let photosDictionary = json?["photos"] as? [String : AnyObject]
//                if let photosArray = photosDictionary?["photo"] as? [[String : AnyObject]] {
//                    
//                    for photo in photosArray {
//                        
//                        if let farmID = photo["farm"] as? Int,
//                            let serverID = photo["server"] as? String,
//                            let photoID = photo["id"] as? String,
//                            let secret = photo["secret"] as? String {
//                            
//                            let photoURLString = "https://farm\(farmID).staticflickr.com/\(serverID)/\(photoID)_\(secret).jpg"
//                            print(photoURLString)
//                            
//                            if let photoURL = URL(string: photoURLString) {
//                                
//                                let me = User(aUsername: "sam", aProfileImage: UIImage(named: "Grumpy-Cat")!)
//                                let post = Post(imageURL: photoURL, user: me, comment: "A Flickr Selfie")
//                                self.posts.append(post)
//                            }
//                        }
//                        
//                    }
//                    // We use OperationQueue.main because we need update all UI elements on the main thread.
//                    // This is a rule and you will see this again whenever you are updating UI.
//                    OperationQueue.main.addOperation {
//                        self.tableView.reloadData()
//                    }
//                }
//                
//            }else{
//                print("error with response data")
//            }
//            
//        })
//        
//        // this is called to start (or restart, if needed) our task
//        task.resume()
        

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! SelfieCell
        
        let post = self.posts[indexPath.row]
        
        cell.post = post
        
        return cell
    }

    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        // 1: Create an ImagePickerController
        let pickerController = UIImagePickerController()
        
        // 2: Self in this line refers to this View Controller
        //    Setting the Delegate Property means you want to receive a message
        //    from pickerController when a specific event is triggered.
        pickerController.delegate = self
        
        if TARGET_OS_SIMULATOR == 1 {
            // 3. We check if we are running on a Simulator
            //    If so, we pick a photo from the simulator’s Photo Library
            // We need to do this because the simulator does not have a camera
            pickerController.sourceType = .photoLibrary
        } else {
            // 4. We check if we are running on an iPhone or iPad (ie: not a simulator)
            //    If so, we open up the pickerController's Camera (Front Camera, for selfies!)
            pickerController.sourceType = .camera
            pickerController.cameraDevice = .front
            pickerController.cameraCaptureMode = .photo
        }
        
        // Preset the pickerController on screen
        self.present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        // 1. When the delegate method is returned, it passes along a dictionary called info.
        //    This dictionary contains multiple things that maybe useful to us.
        //    We are getting an image from the UIImagePickerControllerOriginalImage key in that dictionary
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // setting the compression quality to 90%
            if let imageData = UIImageJPEGRepresentation(image, 0.9),
                let imageFile = PFFile(data: imageData),
                let user = PFUser.current() {

            //2. We create a Post object from the image
//            let me = User(aUsername: "sam", aProfileImage: UIImage(named: "Grumpy-Cat")!)
            let post = Post(image: imageFile, user: user, comment: "My Selfie")
            
            post.saveInBackground (block: {(success, error) -> Void in
                if success {
                    print ("Post succesfully saved in Parse")
                    
                    //3. Add post to our posts array, chose index 0 so that it will be added
                    //   to the top of your table instead of at the bottom (default behaviour)
                    self.posts.insert(post, at: 0)
                    
                    //4. Now that we have added a post, updating our table
                    //   We are just inserting our new Post instead of reloading our whole tableView
                    //   Both method would work, however, this gives us a cool animation for free
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            })
        }
    }
        
        //We remember to dismiss the Image Picker from our screen.
        dismiss(animated: true, completion: nil)
        
        //5. Now that we have added a post, reload our table
        tableView.reloadData()
        
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

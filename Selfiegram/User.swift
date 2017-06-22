//
//  User.swift
//  Selfiegram
//
//  Created by Joy Qiaoyi Wang on 2017-05-28.
//  Copyright © 2017 Joy Qiaoyi Wang. All rights reserved.
//

import Foundation
import UIKit

class User {
    let username: String
    let profileImage: UIImage
    
    init(aUsername: String, aProfileImage: UIImage) {
        username = aUsername
        profileImage = aProfileImage
    }
}

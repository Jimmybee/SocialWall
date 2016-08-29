//
//  DeviceControllerProtocol.swift
//  SocialWall
//
//  Created by James Birtwell on 08/06/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import Foundation

protocol DeviceController {
    func performSingleScreenOperations ()
    func performDualScreenOperations ()
    func removeDisplaysWhileLoading()
}

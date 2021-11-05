//
//  Listener.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/31/20.
//

import Foundation
import Logging

public protocol Listener
{
    func accept() -> Transmission.Connection
}

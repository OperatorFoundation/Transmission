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
    init?(port: Int, type: ConnectionType, logger: Logger?)
    func accept() -> Transmission.Connection
}

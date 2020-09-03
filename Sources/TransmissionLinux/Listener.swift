//
//  Listener.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/31/20.
//

import Foundation
import Socket
import Chord

public class Listener
{
    var socket: Socket
    
    public init?(port: Int)
    {
        guard let socket = try? Socket.create() else {return nil}
        self.socket = socket
        
        do
        {
            try socket.listen(on: port)
        }
        catch
        {
            return nil
        }
    }
    
    public func accept() -> Connection?
    {
        guard let newConnection = try? self.socket.acceptClientConnection(invokeDelegate: false) else {return nil}
        return Connection(socket: newConnection)
    }
}

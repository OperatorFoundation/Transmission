//
//  Listener.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/31/20.
//

import Foundation
import Network
import Chord

public class Listener
{
    let listener: NWListener
    let queue: BlockingQueue<Connection> = BlockingQueue<Connection>()
    let lock: DispatchGroup = DispatchGroup()
    
    public init?(port: Int)
    {
        let port16 = UInt16(port)
        let nwport = NWEndpoint.Port(integerLiteral: port16)
        
        guard let listener = try? NWListener(using: .tcp, on: nwport) else {return nil}
        self.listener = listener
        
        self.listener.newConnectionHandler =
        {
            nwconnection in
            
            guard let connection = Connection(connection: nwconnection) else {return}
            
            self.queue.enqueue(element: connection)
        }
        
        self.listener.start(queue: .global())
    }
    
    public func accept() -> Connection
    {
        return self.queue.dequeue()
    }
}

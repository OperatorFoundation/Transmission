//
//  Listener.swift
//
//
//  Created by Dr. Brandon Wiley on 8/31/20.
//

import Foundation
import Chord
import Logging

#if (os(macOS) || os(iOS) || os(watchOS) || os(tvOS))

import Network

public class TransmissionListener: Listener
{
    let listener: NWListener
    let queue: BlockingQueue<Connection> = BlockingQueue<Connection>()
    let lock: DispatchGroup = DispatchGroup()

    required public init?(port: Int, type: ConnectionType = .tcp, logger: Logger?)
    {
        let port16 = UInt16(port)
        let nwport = NWEndpoint.Port(integerLiteral: port16)

        var params: NWParameters!
        switch type
        {
            case .tcp:
                params = NWParameters.tcp
            case .udp:
                params = NWParameters.udp
        }

        guard let listener = try? NWListener(using: params, on: nwport) else {return nil}
        self.listener = listener

        self.listener.newConnectionHandler =
        {
            nwconnection in

            guard let connection = TransmissionConnection(transport: nwconnection, logger: logger) else {return}

            self.queue.enqueue(element: connection)
        }

        self.listener.start(queue: .global())
    }

    public func accept() -> Connection
    {
        return self.queue.dequeue()
    }
}

#else

@_exported import TransmissionLinux

#endif

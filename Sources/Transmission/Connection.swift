import Foundation
import Network
import Datable
import Transport
import Logging

public class Connection
{
    var connection: Transport.Connection
    var connectLock = DispatchGroup()
    var readLock = DispatchGroup()
    var writeLock = DispatchGroup()
    let log: Logger?

    public convenience init?(host: String, port: Int, type: ConnectionType = .tcp, logger: Logger? = nil)
    {
        
        let nwhost = NWEndpoint.Host(host)
        let port16 = UInt16(port)
        let nwport = NWEndpoint.Port(integerLiteral: port16)
        
        switch type
        {
            case .tcp:
                let nwconnection = NWConnection(host: nwhost, port: nwport, using: .tcp)
                self.init(connection: nwconnection, logger: logger)
            case .udp:
                let nwconnection = NWConnection(host: nwhost, port: nwport, using: .udp)
                self.init(connection: nwconnection, logger: logger)
        }
    }
    
    public convenience init?(connection: NWConnection, logger: Logger? = nil)
    {
        self.init(transport: connection, logger: logger)
    }

    public init?(transport: Transport.Connection, logger: Logger? = nil)
    {
        self.log = logger
        maybeLog(message: "Initializing Transmission connection", logger: self.log)
        
        self.connection = transport

        var success = false

        self.connectLock.enter()
        self.connection.stateUpdateHandler =
        {
            (state) in
            
            switch state
            {
                case .ready:
                    success = true
                    self.connectLock.leave()
                    return
                case .cancelled:
                    self.failConnect()
                    return
                case .failed(_):
                    self.failConnect()
                    return
                case .waiting(_):
                    self.failConnect()
                    return
                default:
                    return
            }
        }
                
        self.connection.start(queue: .global())
        
        connectLock.wait()

        guard success else {return nil}
    }

    func failConnect()
    {
        maybeLog(message: "Failed to make a Transmission connection", logger: self.log)
        self.connection.stateUpdateHandler = nil
        self.connection.cancel()
        self.connectLock.leave()
    }
    
    // Reads exactly size bytes
    public func read(size: Int) -> Data?
    {
        maybeLog(message: "Transmission read(size:) called \(Thread.current)", logger: self.log)
        var result: Data?
        
        self.readLock.enter()
        maybeLog(message: "Transmission read's connection.receive type: \(type(of: self.connection)) size: \(size)", logger: self.log)
        self.connection.receive(minimumIncompleteLength: size, maximumLength: size)
        {
            (maybeData, maybeContext, isComplete, maybeError) in
            
            maybeLog(message: "entered Transmission read's receive callback", logger: self.log)
            
            guard maybeError == nil else
            {
                maybeLog(message: "leaving Transmission read's receive callback with error: \(String(describing: maybeError))", logger: self.log)
                self.readLock.leave()
                return
            }
            
            if let data = maybeData
            {
                result = data
            }
            
            maybeLog(message: "leaving Transmission read's receive callback", logger: self.log)
            
            self.readLock.leave()
        }
        
        readLock.wait()
        
        maybeLog(message: "Transmission read finished!", logger: self.log)
        
        return result
    }
    
    // reads up to maxSize bytes
    public func read(maxSize: Int) -> Data?
    {
        maybeLog(message: "Transmission read(maxSize:) called \(Thread.current)", logger: self.log)
        var result: Data?
        
        self.readLock.enter()
        maybeLog(message: "Transmission read's connection.receive type: \(type(of: self.connection)) maxSize: \(maxSize)", logger: self.log)
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: maxSize)
        {
            (maybeData, maybeContext, isComplete, maybeError) in
            
            maybeLog(message: "entered Transmission read's receive callback", logger: self.log)
            
            guard maybeError == nil else
            {
                maybeLog(message: "leaving Transmission read's receive callback with error: \(String(describing: maybeError))", logger: self.log)
                self.readLock.leave()
                return
            }
            
            if let data = maybeData
            {
                result = data
            }
            
            maybeLog(message: "leaving Transmission read's receive callback", logger: self.log)
            
            self.readLock.leave()
        }
        
        readLock.wait()
        
        maybeLog(message: "Transmission read finished!", logger: self.log)
        
        return result
    }

    public func readWithLengthPrefix(prefixSizeInBits: Int) -> Data?
    {
        maybeLog(message: "Transmission readWithLengthPrefix called \(Thread.current)", logger: self.log)
        var result: Data?

        self.readLock.enter()

        var maybeCount: Int? = nil

        let countLock = DispatchGroup()
        countLock.enter()
        switch prefixSizeInBits
        {
            case 8:
                self.connection.receive(minimumIncompleteLength: 1, maximumLength: 1)
                {
                    (maybeData, maybeContext, isComplete, maybeError) in

                    guard maybeError == nil else
                    {
                        countLock.leave()
                        return
                    }

                    if let data = maybeData
                    {
                        if let count = data.maybeNetworkUint8
                        {
                             maybeCount = Int(count)
                        }
                    }
                    countLock.leave()
                }
            case 16:
                self.connection.receive(minimumIncompleteLength: 2, maximumLength: 2)
                {
                    (maybeData, maybeContext, isComplete, maybeError) in

                    guard maybeError == nil else
                    {
                        countLock.leave()
                        return
                    }

                    if let data = maybeData
                    {
                        if let count = data.maybeNetworkUint16
                        {
                            maybeCount = Int(count)
                        }
                    }
                    countLock.leave()
                }
            case 32:
                self.connection.receive(minimumIncompleteLength: 4, maximumLength: 4)
                {
                    (maybeData, maybeContext, isComplete, maybeError) in

                    guard maybeError == nil else
                    {
                        countLock.leave()
                        return
                    }

                    if let data = maybeData
                    {
                        if let count = data.maybeNetworkUint32
                        {
                            maybeCount = Int(count)
                        }
                    }
                    countLock.leave()
                }
            case 64:
                self.connection.receive(minimumIncompleteLength: 8, maximumLength: 8)
                {
                    (maybeData, maybeContext, isComplete, maybeError) in

                    guard maybeError == nil else
                    {
                        countLock.leave()
                        return
                    }

                    if let data = maybeData
                    {
                        if let count = data.maybeNetworkUint64
                        {
                            maybeCount = Int(count)
                        }
                    }
                    countLock.leave()
                }
            default:
                countLock.leave()
        }

        countLock.wait()

        guard let size = maybeCount else
        {
            readLock.leave()
            return nil
        }

        self.connection.receive(minimumIncompleteLength: size, maximumLength: size)
        {
            (maybeData, maybeContext, isComplete, maybeError) in

            guard maybeError == nil else
            {
                self.readLock.leave()
                return
            }

            if let data = maybeData
            {
                result = data
            }

            self.readLock.leave()
        }

        readLock.wait()

        return result
    }
    
    public func write(string: String) -> Bool
    {
        let data = string.data
        return write(data: data)
    }
    
    public func write(data: Data) -> Bool
    {
        maybeLog(message: "Transmission write called \(Thread.current)", logger: self.log)
        var success = false
        
        self.writeLock.enter()
        self.connection.send(content: data, contentContext: NWConnection.ContentContext.defaultMessage, isComplete: false, completion: NWConnection.SendCompletion.contentProcessed(
        {
            (maybeError) in
                
            guard maybeError == nil else
            {
                success = false
                self.writeLock.leave()
                return
            }
            
            success = true
            self.writeLock.leave()
            return
        }))
        
        self.writeLock.wait()
        
        maybeLog(message: "Transmission write finished \(Thread.current)", logger: self.log)
        
        return success
    }

    public func writeWithLengthPrefix(data: Data, prefixSizeInBits: Int) -> Bool
    {
        var maybeCountData: Data? = nil

        switch prefixSizeInBits
        {
            case 8:
                let count = UInt8(data.count)
                maybeCountData = count.maybeNetworkData
            case 16:
                let count = UInt16(data.count)
                maybeCountData = count.maybeNetworkData
            case 32:
                let count = UInt32(data.count)
                maybeCountData = count.maybeNetworkData
            case 64:
                let count = UInt64(data.count)
                maybeCountData = count.maybeNetworkData
            default:
                return false
        }

        guard let countData = maybeCountData else {return false}

        maybeLog(message: "Transmission writeWithLengthPrefix called \(Thread.current)", logger: self.log)
        var success = false

        self.writeLock.enter()

        self.connection.send(content: countData, contentContext: NWConnection.ContentContext.defaultMessage, isComplete: false, completion: NWConnection.SendCompletion.contentProcessed(
            {
                (maybeError) in

                guard maybeError == nil else
                {
                    success = false
                    self.writeLock.leave()
                    return
                }

                self.connection.send(content: data, contentContext: NWConnection.ContentContext.defaultMessage, isComplete: false, completion: NWConnection.SendCompletion.contentProcessed(
                    {
                        (maybeError) in

                        guard maybeError == nil else
                        {
                            success = false
                            self.writeLock.leave()
                            return
                        }

                        success = true
                        self.writeLock.leave()
                        return
                    }))
            }))

        self.writeLock.wait()

        maybeLog(message: "Transmission writeWithLengthPrefix finished \(Thread.current)", logger: self.log)

        return success
    }
}

public enum ConnectionType
{
    case udp
    case tcp
}

public func maybeLog(message: String, logger: Logger? = nil) {
    if logger != nil {
        logger!.debug("\(message)")
    } else {
        print(message)
    }
}

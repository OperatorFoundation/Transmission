import Foundation
import Network
import Datable

public class Connection
{
    var connection: NWConnection
    var connectLock = DispatchGroup()
    var readLock = DispatchGroup()
    var writeLock = DispatchGroup()

    public convenience init?(host: String, port: Int, type: ConnectionType = .tcp)
    {
        let nwhost = NWEndpoint.Host(host)
        
        let port16 = UInt16(port)
        let nwport = NWEndpoint.Port(integerLiteral: port16)
        
        switch type
        {
            case .tcp:
                let nwconnection = NWConnection(host: nwhost, port: nwport, using: .tcp)
                self.init(connection: nwconnection)
            case .udp:
                let nwconnection = NWConnection(host: nwhost, port: nwport, using: .udp)
                self.init(connection: nwconnection)
        }
    }
    
    init?(connection: NWConnection)
    {
        self.connection = connection

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
                    self.connectLock.leave()
                    return
                case .failed(_):
                    self.connectLock.leave()
                    return
                default:
                    return
            }
        }
                
        self.connection.start(queue: .global())
        
        connectLock.wait()

        guard success else {return nil}
    }
    
    public func read(size: Int) -> Data?
    {
        var result: Data?
        
        self.readLock.enter()
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
        var success = false
        
        self.writeLock.enter()
        self.connection.send(content: data, completion: NWConnection.SendCompletion.contentProcessed(
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
        
        return success
    }
}

public enum ConnectionType
{
    case udp
    case tcp
}

import Foundation
import Socket
import Datable
import Chord

public class Connection
{
    var connectLock = DispatchGroup()
    var readLock = DispatchGroup()
    var writeLock = DispatchGroup()

    let socket: Socket

    public init?(host: String, port: Int)
    {
        guard let socket = try? Socket.create() else {return nil}
        self.socket = socket
        
        do
        {
            try self.socket.connect(to: host, port: Int32(port))
        }
        catch
        {
            return nil
        }
    }
    
    public init(socket: Socket)
    {
        self.socket = socket
    }
    
    public func read(size: Int) -> Data?
    {
        var data = Data()
        
        do
        {
            let _ = try self.socket.read(into: &data)
        }
        catch
        {
            return nil
        }
        
        return data
    }
    
    public func write(string: String) -> Bool
    {
        let data = string.data
        return write(data: data)
    }
    
    public func write(data: Data) -> Bool
    {
        do
        {
            try self.socket.write(from: data)
        }
        catch
        {
            return false
        }
        
        return true
    }
}

public enum ConnectionType
{
    case udp
    case tcp
}

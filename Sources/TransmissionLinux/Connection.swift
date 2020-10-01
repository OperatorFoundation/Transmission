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
    var buffer: Data = Data()

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
        if size == 0
        {
            return nil
        }

        if size <= buffer.count
        {
            let result = Data(buffer[0..<size])
            buffer = Data(buffer[size..<buffer.count])

            return result
        }

        do
        {
            let _ = try self.socket.read(into: &buffer)

            guard size <= buffer.count else
            {
                return nil
            }

            let result = Data(buffer[0..<size])
            buffer = Data(buffer[size..<buffer.count])

            return result
        }
        catch
        {
            return nil
        }
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

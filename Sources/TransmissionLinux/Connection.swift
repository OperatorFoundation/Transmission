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
        print("1")
        if size == 0
        {
            return nil
        }

        var data = Data()
        print("2")

        do
        {
            let bytesRead = try self.socket.read(into: &data)
            print("3")
            buffer.append(data[0..<bytesRead])
            print("4")

            guard size <= buffer.count else
            {
                return nil
            }
            print("5")

            let result = buffer[0..<size]
            print("6")
            buffer = buffer[size..<buffer.count]
            print("7")

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

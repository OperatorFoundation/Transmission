import XCTest
import Foundation
@testable import Transmission

final class TransmissionTests: XCTestCase
{
    public func testConnection()
    {
        let lock = DispatchGroup()
        let queue = DispatchQueue(label: "testing")
        
        lock.enter()
        
        queue.async
        {
            self.runServer(lock)
        }
        
        lock.wait()
        
        runClient()
    }
    
    func runServer(_ lock: DispatchGroup)
    {
        guard let listener = TransmissionListener(port: 1234, logger: nil) else {return}
        lock.leave()

        let connection = listener.accept()
        let _ = connection.read(size: 4)
        let _ = connection.write(string: "back")
    }
    
    func runClient()
    {
        let connection = TransmissionConnection(host: "127.0.0.1", port: 1234, logger: nil)
        XCTAssertNotNil(connection)
        
        let writeResult = connection!.write(string: "test")
        XCTAssertTrue(writeResult)
        
        let result = connection!.read(size: 4)
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result!, "back")
    }
}

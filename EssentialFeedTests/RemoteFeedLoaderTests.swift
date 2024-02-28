//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by abbas on 09.12.23.
//

/// goal is to get rid of the singeltons ,
/// 1. make the shared instance a variable instead of let so it would not be anymore a singelton , now shared is a global state not a singelton
/// 2. move the test logic from remotefeedloader to httpclient
/// 3. Move the test logic to a new subclass of the HTTPClient , instead of directly touching the production code the goal is i want to access into my test target to test the code
/// 4. Done! We dont have a Singelton anymore and the test logic is now in a test type (the spy).
///
///  Refactoring Points
///  1. HTTPClient.shared.get is mixing the responsibilities here , looking for a method (get) in an object  and responsibility of locating this object using shared.
///  If we inject our client it would be more testable
///  So rather using Subclasing we can use composition , we can start injecting into the feedloader.
///  Now you can use protocol to define the interfacces because HTTPClient is an abstract class now
///  give a url from outside instead hardcoding inside the RemoteFeedLoader, we moved all the details to the test side and code is getting more generic
/// to remove the duplication of code use the factory method to make System Under Test SUT
///
///  outcomes :
/// 1.  singelton progression to eliminating the tight coupling by using dependency injection.
/// 2. there is no reason to make the httpclient a singelton or a shared instance apart from conveience to locate the instance directly.
///  3. for creation of singeltons you need to have a good reason for example you want to have only one HTTPClient per application.
///  4. by introducing the clean separation with protocols, we made the remotefeedloader more flexible, open for extension and more testable
///   5. refactoring by backing up by tests is a very power ful tool, without tests you will have a feat of change
///
/// when testing objects collaborating, asserting the values passed is not enough we also need to ask how many times as the method invoked?
/// mistakes like this happen all the time especially when merging the code

@testable import EssentialFeed
import XCTest

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url-com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURL() {
        let url = URL(string: "https://a-given-url-com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: 200, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data(bytes: "Invalid Data", count: 200)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        let emptyListJSON = Data(bytes: "{\"items\": []}".utf8)
        client.complete(withStatusCode: 200, data: emptyListJSON)
        
        XCTAssertEqual(capturedResults, [.success([])])
    }
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url-com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedErrors =  [RemoteFeedLoader.Result]()
        sut.load { capturedErrors.append($0) }
        
        action()
        
        XCTAssertEqual(capturedErrors, [.failure(error)], file: file, line: line)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}

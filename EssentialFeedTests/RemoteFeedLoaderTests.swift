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

import XCTest
@testable import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) =  makeSUT()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url-com")!
        let (sut, client) = makeSUT(url: url)
    
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url-com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}

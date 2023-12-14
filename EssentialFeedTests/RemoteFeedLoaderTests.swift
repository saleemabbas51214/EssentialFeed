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
///
///

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    func get(from url: URL) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}


final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-url-com")!
        _ =  RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-given-url-com")!
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
}

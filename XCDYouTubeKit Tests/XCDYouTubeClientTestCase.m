//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import "XCDYouTubeKitTestCase.h"

#import <XCDYouTubeKit/XCDYouTubeClient.h>
#import <XCDYouTubeKit/XCDYouTubeVideoOperation.h>

@interface XCDYouTubeClientTestCase : XCDYouTubeKitTestCase
@end

@implementation XCDYouTubeClientTestCase

- (void) testThatVideoIsAvailalbeOnDetailPageEventLabel
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"dQw4w9WgXcQ" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(error);
		XCTAssertNotNil(video);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testThatVideoHasMetadata
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"9TTioMbNT9I" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(error);
		XCTAssertEqualObjects(video.identifier, @"9TTioMbNT9I");
		XCTAssertEqualObjects(video.title, @"Super Mario Bros Theme Song on Wine Glasses and a Frying Pan (슈퍼 마리오 브라더스 - スーパーマリオブラザーズ - 超級瑪莉)");
		XCTAssertNotNil(video.thumbnailURL);
		XCTAssertTrue(video.streamURLs.count > 0);
		XCTAssertTrue(video.duration > 0);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testThatVideoHasOtherStreams
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"sBHFOh5qe20" completionHandler:^(XCDYouTubeVideo *mainVideo, NSError *error)
	{
		XCTAssertNil(error);
		XCTAssertNotNil(mainVideo.videoIdentifiers);
		
		NSMutableArray *operations = [NSMutableArray new];
		NSOperationQueue *queue = [NSOperationQueue new];
		queue.maxConcurrentOperationCount = 6;
		
		for (NSString *videoIdentifier in mainVideo.videoIdentifiers)
		{
			[operations addObject:[[XCDYouTubeVideoOperation alloc]initWithVideoIdentifier:videoIdentifier languageIdentifier:nil]];
		}
		
		XCTAssertTrue(operations.count != 0);
		[queue addOperations:operations waitUntilFinished:YES];
		
		for (XCDYouTubeVideoOperation *operation in operations)
		{
			XCTAssertNil(operation.error);
			XCTAssertNotNil(operation.video);
			XCTAssertTrue(operation.video.streamURLs.count > 0);
			XCTAssertTrue(operation.video.duration > 0);
			XCTAssertNotEqualObjects(operation.video, mainVideo, @"None of the `videoIdentifiers` returned from the `mainVideo` should be the same `videoIdentifier` was the `mainVideo`");
		}
		
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testVideoThatHasCaptions
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"_g8aLVGXyc0" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	 {
		 XCTAssertNotNil(video);
		 XCTAssertNotNil(video);
		 XCTAssertNotNil(video.captionURLs);
		 XCTAssertNotNil(video.autoGeneratedCaptionURLs);
		 XCTAssertNotEqual(video.autoGeneratedCaptionURLs[@"en"], video.captionURLs[@"en"]);
		 [expectation fulfill];
	 }];
	[self waitForExpectationsWithTimeout:5 handler:nil];
	
}

- (void)testVideoWithDashManifest
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"YLg-LCkYXbI" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	 {
		 XCTAssertNotNil(video);
		 XCTAssertNotNil(video.streamURLs[@299], @"Could not find Dash video 299 in `streamURLs`"); //itag=299: {'ext': 'mp4', 'height': 1080, 'format_note': 'DASH video', 'vcodec': 'h264', 'fps': 60}
		 [expectation fulfill];
	 }];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

//See -[XCDYouTubeVideoOperation handleConnectionError:requestType]
- (void)testConnectionErrorWithDashManifest
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"YLg-LCkYXbI" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	 {
		 XCTAssertNotNil(video);
		 XCTAssertNil(video.streamURLs[@299]);
		
		 [expectation fulfill];
	 }];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testVideoWithUndeterminedCaptionLanguageCode
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"RgKAFK5djSk" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	 {
		 XCTAssertNil(error);
		 XCTAssertNotNil(video);
		 XCTAssertNil(video.captionURLs[@"und"]);
		 XCTAssertNotNil(video.captionURLs);
		 [expectation fulfill];
	 }];
	[self waitForExpectationsWithTimeout:5 handler:nil];
	
}

- (void) testMobileRestrictedVideo
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"JHaA9bKi-xs" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(error);
		XCTAssertNotNil(video.title);
		XCTAssertTrue(video.viewCount > 0);
		XCTAssertNotNil(video.expirationDate);
		XCTAssertNotNil(video.thumbnailURL);
		XCTAssertTrue(video.streamURLs.count > 0);
		XCTAssertTrue(video.duration > 0);
		[video.streamURLs enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSURL *streamURL, BOOL *stop) {
			XCTAssertTrue([streamURL.query rangeOfString:@"signature="].location != NSNotFound || [streamURL.query rangeOfString:@"sig="].location != NSNotFound);
		}];
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testLiveVideo
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"hHW1oY26kxQ" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(error);
		XCTAssertNotNil(video.title);
		XCTAssertTrue(video.viewCount > 0);
		XCTAssertNotNil(video.thumbnailURL);
		XCTAssertNotNil(video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

// Test for https://github.com/0xced/XCDYouTubeKit/issues/420

- (void) testVideo1
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"8vISc8dZ_bc" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	 {
		 XCTAssertNil(error);
		 XCTAssertNotNil(video.title);
		 XCTAssertTrue(video.viewCount > 0);
		 XCTAssertNotNil(video.thumbnailURL);
		 XCTAssertTrue(video.streamURLs.count > 0);
		 XCTAssertTrue(video.duration > 0);
		 [video.streamURLs enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSURL *streamURL, BOOL *stop) {
			 XCTAssertTrue([streamURL.query rangeOfString:@"signature="].location != NSNotFound || [streamURL.query rangeOfString:@"sig="].location != NSNotFound);
		 }];
		 [expectation fulfill];
	 }];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

// See https://github.com/0xced/XCDYouTubeKit/issues/420#issue-400541618

- (void) testVideo1IsPlayable
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"8vISc8dZ_bc" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(error);
		XCTAssertNotNil(video.title);
		XCTAssertTrue(video.viewCount > 0);
		XCTAssertNotNil(video.expirationDate);
		XCTAssertNotNil(video.thumbnailURL);
		XCTAssertTrue(video.streamURLs.count > 0);
		XCTAssertTrue(video.duration > 0);
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:video.streamURLs[@(XCDYouTubeVideoQualityMedium360)]];
		request.HTTPMethod = @"HEAD";
		NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError)
		{
			XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
			[expectation fulfill];
		}];
		[dataTask resume];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testVideo1ReturnsSomePlayableStreams
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	
	//These are the playble itag stream for `cdqP6wI8TCc` as of Feb 12, 2020 in the US
	NSArray<NSNumber *>*playableStreamKeys = @[@140, @136, @251, @134];
	
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"cdqP6wI8TCc" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		
		XCTAssertNotNil(video);
		XCTAssertNil(error);
		
		[[XCDYouTubeClient defaultClient]queryVideo:video cookies:nil completionHandler:^(NSDictionary * _Nonnull streamURLs, NSError * _Nullable queryError, NSDictionary<id, NSError *> *streamErrors) {
			
			XCTAssertNil(queryError);
			XCTAssertNotNil(streamURLs);
			XCTAssertTrue([NSThread isMainThread]);
			
			for (NSNumber *itag in playableStreamKeys)
			{
				XCTAssertTrue([streamURLs.allKeys containsObject:itag]);
			}
			
			for (id key in streamURLs.allKeys)
			{
				XCTAssertNotNil(streamURLs[key]);
			}
			
			XCTAssertEqual(playableStreamKeys.count, streamURLs.count, @"`streamURLs` count should be equal to `playableStreamKeys` count");
			XCTAssertNotEqual(video.streamURLs.count, streamURLs.count, @"`streamURLs` count should not be equal since this video contains some streams are unplayable");
			
			[expectation fulfill];
		}];
	}];
	
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

// Disable internet connection before running to allow some queries to fail
// Also, this test requires using Charles Proxy tools (or similar app) to block some of the streamURLs
- (void) testVideo1ReturnsSomePlayableStreamsEvenIfSomeFailDueToConnectionError_offline
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"cdqP6wI8TCc" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNotNil(video);
		XCTAssertNil(error);
		
		[[XCDYouTubeClient defaultClient]queryVideo:video cookies:nil completionHandler:^(NSDictionary * _Nonnull streamURLs, NSError * _Nullable queryError, NSDictionary<id, NSError *> *streamErrors) {
			
			XCTAssertNil(queryError);
			XCTAssertNotNil(streamURLs);
			XCTAssertTrue([NSThread isMainThread]);

			for (id key in streamURLs.allKeys)
			{
				XCTAssertNotNil(streamURLs[key]);
			}
			
			XCTAssertTrue(streamErrors.count != 0);
			for (NSError *streamError in streamErrors.allValues)
			{
				XCTAssertNotNil(streamError.localizedDescription);
			}
			
			XCTAssertNotEqual(video.streamURLs.count, streamURLs.count, @"`streamURLs` count should not be equal since this video contains some streams are unplayable");
			
			[expectation fulfill];
		}];
	}];
	
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

// Disable internet connection before running to allow all queries to fail
- (void) testVideo1ReturnsNoPlayableStreamsBecauseConnectionError_offline
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"cdqP6wI8TCc" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNotNil(video);
		XCTAssertNil(error);
		
		[[XCDYouTubeClient defaultClient]queryVideo:video cookies:nil completionHandler:^(NSDictionary * _Nonnull streamURLs, NSError * _Nullable queryError, NSDictionary<id, NSError *> *streamErrors) {
			
			XCTAssertNotNil(queryError);
			XCTAssertNil(streamURLs);
			XCTAssertTrue(streamErrors.count != 0);
			XCTAssertTrue([NSThread isMainThread]);
			
			for (NSError *streamError in streamErrors.allValues)
			{
				XCTAssertNotNil(streamError.localizedDescription);
			}
			
			XCTAssertNotEqual(video.streamURLs.count, streamURLs.count, @"`streamURLs` count should not be equal since this video contains some streams are unplayable");
			
			[expectation fulfill];
		}];
	}];
	
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testVideo2ReturnsAllPlayableStreams
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"QcIy9NiNbmo" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNotNil(video);
		XCTAssertNil(error);
		
		[[XCDYouTubeClient defaultClient]queryVideo:video cookies:nil completionHandler:^(NSDictionary * _Nonnull streamURLs, NSError * _Nullable queryError, NSDictionary<id, NSError *> *streamErrors) {
			
			XCTAssertNil(queryError);
			XCTAssertNil(streamErrors);
			XCTAssertNotNil(streamURLs);
			XCTAssertTrue([NSThread isMainThread]);
			
			for (id key in streamURLs.allKeys)
			{
				XCTAssertNotNil(streamURLs[key]);
			}
			
			XCTAssertEqual(video.streamURLs.count, streamURLs.count, @"`streamURLs` count should be equal since all the streams are playable.");
			
			[expectation fulfill];
		}];
	}];
	
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testVideo3ReturnsSomePlayableStreams
{
	/**
	 * This video `550S-6XVRsw` contains some streams (e.g. itag=22)  that don't play (the file appeas to be incomplete on YouTube's servers).
	 * This test ensures that we catch those kinds of errors and they aren't included in the `streamURLs`
	 * See https://github.com/0xced/XCDYouTubeKit/issues/456 for more information.
	 */
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	NSNumber *nonPlayableStreamKey = @(XCDYouTubeVideoQualityHD720);
	
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"550S-6XVRsw" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNotNil(video);
		XCTAssertNil(error);
		
		[[XCDYouTubeClient defaultClient]queryVideo:video cookies:nil completionHandler:^(NSDictionary * _Nonnull streamURLs, NSError * _Nullable queryError, NSDictionary<id, NSError *> *streamErrors) {
			
			XCTAssertNil(queryError);
			XCTAssertNotNil(streamErrors);
			XCTAssertNotNil(streamURLs);
			XCTAssertTrue([NSThread isMainThread]);
			
			for (id key in streamURLs.allKeys)
			{
				XCTAssertNotNil(streamURLs[key]);
			}
			
			XCTAssertNotEqual(video.streamURLs.count, streamURLs.count, @"`streamURLs` count should not be equal since this video contains some streams are unplayable");
			XCTAssertNil(streamURLs[nonPlayableStreamKey], @"itag 22 should not be available in this stream.");
			//I noticed when the file stored on the server is not complete we get this error
			XCTAssertTrue([streamErrors.allValues.firstObject.domain isEqual:NSURLErrorDomain]);
			XCTAssertEqual(streamErrors.allValues.firstObject.code, NSURLErrorNetworkConnectionLost);
			XCTAssertNotNil(streamErrors.allValues.firstObject.userInfo[NSLocalizedRecoverySuggestionErrorKey]);
			XCTAssertTrue([streamErrors.allValues.firstObject.userInfo[NSLocalizedRecoverySuggestionErrorKey] isEqual:@"The file stored on the server might be incomplete."]);
			[expectation fulfill];
		}];
	}];
	
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testThatQueryingLiveVideoReturnsPlayableStreams
{
	/**
	 * This video `hHW1oY26kxQ` is a live stream
	 * See https://github.com/0xced/XCDYouTubeKit/issues/456 for more information.
	 */
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"hHW1oY26kxQ" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNotNil(video);
		XCTAssertNil(error);
		
		[[XCDYouTubeClient defaultClient]queryVideo:video cookies:nil completionHandler:^(NSDictionary * _Nonnull streamURLs, NSError * _Nullable queryError, NSDictionary<id, NSError *> *streamErrors) {
			
			XCTAssertNil(queryError);
			XCTAssertNotNil(streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming], @"Should contain live stream");
			XCTAssertNotNil(streamURLs);
			XCTAssertTrue([NSThread isMainThread]);
			
			for (id key in streamURLs.allKeys)
			{
				XCTAssertNotNil(streamURLs[key]);
			}

			[expectation fulfill];
		}];
	}];
	
	[self waitForExpectationsWithTimeout:900 handler:nil];
}

- (void) testExpiredLiveVideo
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"i2-MnWWoL6M" completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNoStreamAvailable);
		XCTAssertEqualObjects(error.localizedDescription, @"This live stream recording is not available.");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testRestrictedVideo
{
	char *logLevel = getenv("XCDYouTubeKitLogLevel");
	setenv("XCDYouTubeKitLogLevel", "1", 1);
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"1kIsylLeHHU" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNoStreamAvailable);
		XCTAssertEqualObjects(error.localizedDescription, @"This video is no longer available because the YouTube account associated with this video has been terminated.");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
	
	if (logLevel)
		setenv("XCDYouTubeKitLogLevel", logLevel, 1);
}

- (void) testRemovedVideo
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"BXnA9FjvLSU" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNoStreamAvailable);
		XCTAssertEqualObjects(error.localizedDescription, @"This video is no longer available due to a copyright claim by Digital Rights Group Ltd.");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testGeoblockedVideo
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"Exf63KPXF6w" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNoStreamAvailable);
		XCTAssertEqualObjects(error.localizedDescription, @"The uploader has not made this video available in your country.");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testInvalidVideoIdentifier
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"tooShort" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNoStreamAvailable);
		XCTAssertEqualObjects(error.localizedDescription, @"Invalid parameters.");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testNonExistentVideoIdentifier
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"xxxxxxxxxxx" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNoStreamAvailable);
		XCTAssertEqualObjects(error.localizedDescription, @"This video is unavailable.");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testFrenchClient
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[[XCDYouTubeClient alloc] initWithLanguageIdentifier:@"fr"] getVideoWithIdentifier:@"xxxxxxxxxxx" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNoStreamAvailable);
		XCTAssertEqualObjects(error.localizedDescription, @"Cette vidéo n'est pas disponible.");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testNilVideoIdentifier
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:nil completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNoStreamAvailable);
		XCTAssertEqualObjects(error.localizedDescription, @"Invalid parameters.");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testSpaceVideoIdentifier
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@" " completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNoStreamAvailable);
		XCTAssertEqualObjects(error.localizedDescription, @"Invalid parameters.");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

// Disable internet connection before running
- (void) testConnectionError_offline
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"EdeVaT-zZt4" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTAssertNil(video);
		XCTAssertEqualObjects(error.domain, XCDYouTubeVideoErrorDomain);
		XCTAssertEqual(error.code, XCDYouTubeErrorNetwork);
		XCTAssertEqualObjects(error.localizedDescription, @"The Internet connection appears to be offline.");
		NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
		XCTAssertEqualObjects(underlyingError.domain, NSURLErrorDomain);
		XCTAssertEqual(underlyingError.code, NSURLErrorNotConnectedToInternet);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testUsingClientOnNonMainThread
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		XCTAssertFalse([NSThread isMainThread]);
		[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"EdeVaT-zZt4" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
		{
			XCTAssertTrue([NSThread isMainThread]);
			[expectation fulfill];
		}];
	});
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testCancelingOperation
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	id<XCDYouTubeOperation> operation = [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"EdeVaT-zZt4" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	{
		XCTFail();
	}];
	[expectation performSelector:@selector(fulfill) withObject:nil afterDelay:0.2];
	[operation cancel];
	[self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testCancelingOperationQueryOperation
{
	__weak XCTestExpectation *expectation = [self expectationWithDescription:@""];
	__block XCDYouTubeVideoQueryOperation *operation = nil;
	[[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"6kLq3WMV1nU" completionHandler:^(XCDYouTubeVideo *video, NSError *error)
	 {
		XCTAssertNotNil(video);
		
		operation = [[XCDYouTubeClient defaultClient] queryVideo:video cookies:nil completionHandler:^(NSDictionary * _Nonnull streamURLs, NSError * _Nullable queryError, NSDictionary<id,NSError *> * _Nonnull streamErrors)
		{
			XCTFail();
		}];
		
		[operation cancel];
		[expectation fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void) testNilCompletionHandler
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	XCTAssertThrowsSpecificNamed([[XCDYouTubeClient defaultClient] getVideoWithIdentifier:@"EdeVaT-zZt4" completionHandler:nil], NSException, NSInvalidArgumentException);
#pragma clang diagnostic pop
}

@end

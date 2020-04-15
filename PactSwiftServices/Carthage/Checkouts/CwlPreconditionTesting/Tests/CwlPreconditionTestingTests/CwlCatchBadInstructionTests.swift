//
//  CwlCatchBadInstructionTests.swift
//  CwlPreconditionTesting
//
//  Created by Matt Gallagher on 2016/01/10.
//  Copyright © 2016 Matt Gallagher ( https://www.cocoawithlove.com ). All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import Foundation
import Swift
import XCTest
import CwlPosixPreconditionTesting
import CwlPreconditionTesting

class CatchBadInstructionTests: XCTestCase {
	func testCatchBadInstruction() {
	#if os(macOS) || os(iOS)
		// Test catching an assertion failure
		var reachedPoint1 = false
		var reachedPoint2 = false
		let exception1: CwlPreconditionTesting.BadInstructionException? = CwlPreconditionTesting.catchBadInstruction {
			// Must invoke this block
			reachedPoint1 = true
			
			// Fatal error raised
			precondition(false, "THIS PRECONDITION FAILURE IS EXPECTED")

			// Exception must be thrown so that this point is never reached
			reachedPoint2 = true
		}
		// We must get a valid BadInstructionException
		XCTAssert(exception1 != nil)
		XCTAssert(reachedPoint1)
		XCTAssert(!reachedPoint2)
		
		// Test without catching an assertion failure
		var reachedPoint3 = false
		let exception2: CwlPreconditionTesting.BadInstructionException? = CwlPreconditionTesting.catchBadInstruction {
			// Must invoke this block
			reachedPoint3 = true
		}
		// We must not get a BadInstructionException without an assertion
		XCTAssert(reachedPoint3)
		XCTAssert(exception2 == nil)
	#endif
	}

	func testPosixCatchBadInstruction() {
		// Test catching an assertion failure
		var reachedPoint1 = false
		var reachedPoint2 = false
		let exception1: CwlPosixPreconditionTesting.BadInstructionException? = CwlPosixPreconditionTesting.catchBadInstruction {
			// Must invoke this block
			reachedPoint1 = true
			
			// Fatal error raised
			precondition(false, "THIS PRECONDITION FAILURE IS EXPECTED")

			// Exception must be thrown so that this point is never reached
			reachedPoint2 = true
		}
		// We must get a valid BadInstructionException
		XCTAssert(exception1 != nil)
		XCTAssert(reachedPoint1)
		XCTAssert(!reachedPoint2)
		
		// Test without catching an assertion failure
		var reachedPoint3 = false
		let exception2: CwlPosixPreconditionTesting.BadInstructionException? = CwlPosixPreconditionTesting.catchBadInstruction {
			// Must invoke this block
			reachedPoint3 = true
		}
		// We must not get a BadInstructionException without an assertion
		XCTAssert(reachedPoint3)
		XCTAssert(exception2 == nil)
	}
}

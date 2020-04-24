//
//  ValidationErrorHandler.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 20/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
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

struct ValidationErrorHandler {

	private let errors: [PactError]

	init(mismatches: String) {
		let mismatchData = mismatches.data(using: .utf8)

		do {
			// BUG in RustMockServer - actual and expected keys are either String or Array<Int> :( (See if Either<String, Array<Int>> could work with Decodable)
			self.errors = try JSONDecoder().decode([PactError].self, from: mismatchData ?? "[{\"type\":\"Unsupported Pact Error Message\"}]".data(using: .utf8)!)
		} catch {
			self.errors = [PactError(type: "mock-server-parsing-fail", method: "", path: "", request: [:], mismatches: nil)]
		}
	}

	var description: String {
		var expectedRequest: String = ""
		var actualRequest: String = ""
		var errorReason: String = ""

		errors.forEach { error in
			errorReason = VerificationErrorType(error.type).rawValue

			switch VerificationErrorType(error.type) {
			case .missing:
				expectedRequest += "\(error.method) \(error.path)"
				actualRequest += ""
			case .notFound:
				expectedRequest += ""
				actualRequest += "\(error.method) \(error.path)"
			case .mismatch:
				let expectedQuery = error.mismatches?.compactMap {
					if MismatchErrorType(rawValue: $0.type) == .query {
						return "\($0.parameter ?? "unknown_parameter")=" + "\($0.expected.expectedString)"
					}
					return nil
				}
				.joined(separator: "&")

				let mismatches = error.mismatches?.compactMap {
						"\($0.parameter != nil ? "query param '" + $0.parameter! + "': " : "")"
					+ "\($0.mismatch != nil ? $0.mismatch! : "")"
					+ "\( MismatchErrorType(rawValue: $0.type)  == .body ? "Body in request does not match the expected body definition" : "")"
				}
				.joined(separator: "\n\t")

				expectedRequest += "\(error.method) \(error.path)\(expectedQuery != "" ? "?" + expectedQuery! : "")"
				actualRequest += "\(error.method) \(error.path)\(mismatches != nil ? "\n\t" + mismatches! : "")"
			default:
				expectedRequest += ""
				actualRequest += ""
			}
		}

		return """
		Actual request does not match expected interactions...

		Reason:
			\(errorReason)

		Request:
			\(expectedRequest)
		
		Error:
			\(actualRequest)
		"""
	}

}

struct PactError {

	let type: String
	let method: String
	let path: String
	let request: [String: String]?
	let mismatches: [MismatchError]?

}

extension PactError: Decodable {

	enum CodingKeys: String, CodingKey {
		case type
		case method
		case path
		case request
		case mismatches
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		type = try container.decode(String.self, forKey: .type)
		method = try container.decode(String.self, forKey: .method)
		path = try container.decode(String.self, forKey: .path)
		request = [:]
		mismatches = try container.decodeIfPresent([MismatchError].self, forKey: .mismatches)
	}

}

struct MismatchError: Decodable {
	let type: String
	let expected: Expected
	let actual: Actual
	let parameter: String?
	let mismatch: String?
}

// MARK: -
// This is only used to handle Mock Server's bug where it returns a String or an Array<Int> depending on the request. :|
struct Expected: Codable {
	let expectedString: String
	let expectedIntArray: [Int]

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		do {
			expectedString = try container.decode(String.self)
			expectedIntArray = []
		} catch {
			expectedIntArray = try container.decode([Int].self)
			expectedString = expectedIntArray.map { "\($0)" }.joined(separator: ",")
		}
	}
}

struct Actual: Codable {
	let actualString: String
	let actualIntArray: [Int]

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		do {
			actualString = try container.decode(String.self)
			actualIntArray = []
		} catch {
			actualIntArray = try container.decode([Int].self)
			actualString = actualIntArray.map { "\($0)" }.joined(separator: ",")
		}
	}
}

// MARK: -

enum MismatchErrorType: String {
	case query
	case body
	case headers
	case unknown

	init(rawValue: String) {
		switch rawValue  {
		case "QueryMismatch": self = .query
		case "BodyTypeMismatch": self = .body
		case "BodyMismatch": self = .body
		default: self = .unknown
		}
	}
}

enum VerificationErrorType: String {
	case missing = "Missing request"
	case notFound = "Unexpected request"
	case mismatch = "Request does not match"
	case mockServerParsingFailed = "Failed to parse Mock Server error response! Please report this as an issue at https://github.com/surpher/pact-swift/issues/new. Provide this test as an example to help us debug and improve this framework."
	case unknown = "Not entirely sure what happened! Please report this as an issue at https://github.com/surpher/pact-swift/issues/new. Provide this test as an example to help us debug and improve this framework."

	init(_ type: String) {
		switch type {
		case "missing-request":
			self = .missing
		case "request-not-found":
			self = .notFound
		case "request-mismatch":
			self = .mismatch
		case "mock-server-parsing-fail":
			self = .mockServerParsingFailed
		default:
			self = .unknown
		}
	}
}

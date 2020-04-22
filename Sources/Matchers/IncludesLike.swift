//
//  IncludesLike.swift
//  PactSwift
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
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

public struct IncludesLike: MatchingRuleExpressible {

	public enum IncludeCombine: String {
		case and = "AND"
		case or = "OR"
	}

	internal let value: Any
	internal let combine: IncludeCombine
	internal var rules: [[String: AnyEncodable]] {
		includeStringValues.map {
			[
				"match": AnyEncodable("include"),
				"value": AnyEncodable($0)
			]
		}
	}

	private var includeStringValues: [String]

	// MARK: - Initializers

	public init(_ values: String..., combine: IncludeCombine = .and) {
		self.value = values
		self.includeStringValues = values
		self.combine = combine
	}

}

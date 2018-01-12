//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation

enum InviteResult {
    case success(email: String)
    case failure(email: String, errorMessage: String)
}

enum InviteSource {
    case manualInput, addressBook
}

extension Sequence where Element == InviteResult {
    var emails: [String] {
        return map {
            switch $0 {
            case .success(email: let email): return email
            case .failure(email: let email, _): return email
            }
        }
    }
}
//
//  SearchActorsSkeleton.swift
//
//
//  Created by Christopher Jr Riley on 2024-03-17.
//

import Foundation

extension ATProtoKit {
    /// Retrieves the skeleton results of actors (users).
    ///  
    /// - Note: According to the AT Protocol specifications: "Backend Actors (profile) search, returns only skeleton."
    ///
    /// - SeeAlso: This is based on the [`app.bsky.unspecced.searchActorsSkeleton`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/unspecced/searchActorsSkeleton.json
    ///
    /// - Parameters:
    ///   - query: The string used for searching the users.
    ///   - canTypeAhead: Indicates whether the results can be typed ahead. Optional.
    ///   - limit: The number of items that can be in the list. Optional. Defaults to `25`.
    ///   - cursor: The mark used to indicate the starting point for the next set of result. Optional.
    /// - Returns: A `Result`, containing either an ``UnspeccedSearchActorsSkeletonOutput`` if successful, or an `Error` if not.
    public func searchActorsSkeleton(_ query: String, canTypeAhead: Bool?, limit: Int? = 25, cursor: String? = nil,
                                     pdsURL: String? = nil) async throws -> Result<UnspeccedSearchActorsSkeletonOutput, Error> {
        guard let sessionURL = pdsURL != nil ? pdsURL : session?.pdsURL,
              let requestURL = URL(string: "\(sessionURL)/xrpc/app.bsky.unspecced.searchActorsSkeleton") else {
            return .failure(ATRequestPrepareError.invalidRequestURL)
        }

        var queryItems = [(String, String)]()

        queryItems.append(("q", query))

        if let canTypeAhead {
            queryItems.append(("typeAhead", "\(canTypeAhead)"))
        }

        if let limit {
            let finalLimit = min(1, max(limit, 100))
            queryItems.append(("limit", "\(finalLimit)"))
        }

        if let cursor {
            queryItems.append(("cursor", cursor))
        }

        do {
            let queryURL = try APIClientService.setQueryItems(
                for: requestURL,
                with: queryItems
            )

            let request = APIClientService.createRequest(forRequest: queryURL,
                                                         andMethod: .get,
                                                         acceptValue: "application/json",
                                                         contentTypeValue: nil,
                                                         authorizationValue: nil)
            let response = try await APIClientService.sendRequest(request,
                                                                  decodeTo: UnspeccedSearchActorsSkeletonOutput.self)

            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}

//
//  Movie.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 28/5/22.
//

import Foundation

struct MoviesResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}
/* Example JSON
    {
      "page": 1,
      "results": [], <- This returns an array of other JSONs (Movie struct below)
      "total_pages": 7,
      "total_results": 127
    }
 */

struct Movie : Codable {
    let id: Int?
    let title: String?
    let posterPath: String?
    let releaseDate: String?
}
// Add more properties as needed

/* Example JSON
 {
   "adult": false,
   "backdrop_path": "/zqkmTXzjkAgXmEWLRsY4UpTWCeo.jpg",
   "genre_ids": [
     12,
     28,
     878
   ],
   "id": 11,
   "original_language": "en",
   "original_title": "Star Wars",
   "overview": "Princess Leia is captured and held hostage by the evil Imperial forces in their effort to take over the galactic Empire. Venturesome Luke Skywalker and dashing captain Han Solo team together with the loveable robot duo R2-D2 and C-3PO to rescue the beautiful princess and restore peace and justice in the Empire.",
   "popularity": 69.069,
   "poster_path": "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
   "release_date": "1977-05-25",
   "title": "Star Wars",
   "video": false,
   "vote_average": 8.2,
   "vote_count": 17248
 }
 */

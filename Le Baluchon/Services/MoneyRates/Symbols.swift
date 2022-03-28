//
//  Symbols.swift
//  Le Baluchon
//
//  Created by Yoan on 28/03/2022.
//

import Foundation

struct Symbols: Decodable {
    let success: Bool
    let symbols: [String: String]
}

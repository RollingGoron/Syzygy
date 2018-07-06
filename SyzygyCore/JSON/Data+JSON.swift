//
//  Data+JSON.swift
//  SyzygyCore
//
//  Created by Dave DeLong on 12/31/17.
//  Copyright © 2017 Dave DeLong. All rights reserved.
//

import Foundation

public extension Data {
    
    func JSONRepresentation() -> Result<JSON> {
        
        do {
            let o = try JSONSerialization.jsonObject(with: self, options: [.allowFragments])
            let j = JSON(o)
            return .success(j)
        } catch let e {
            return .error(e)
        }
        
    }
    
}

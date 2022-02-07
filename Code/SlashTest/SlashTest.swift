//
//  SlashTest.swift
//  SwiftUIStudy
//
//  Created by woogus on 2022/01/29.
//

import Combine


struct Slash {
    var type: Type
    
    enum `Type` {
        case test
    }
}

    [].last(where: (Slash.Type.test))

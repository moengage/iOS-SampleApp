//
//  MoESampleViewModel.swift
//  MoESwiftSample
//
//  Created by Deepa on 05/09/22.
//

import Foundation

struct SampleViewModel {
    
    var dataSource = SDKData.allCases
    
    func numberOfRows(in section: Int) -> Int {
        return dataSource.count
    }

}

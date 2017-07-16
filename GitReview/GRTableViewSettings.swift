//
//  GRTableViewSettings.swift
//  GitReview
//
//  Created by Whitney Foster on 7/16/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import UIKit

class TableViewSettings {
    var sections: [Section] = [Section]()
    
    init(sections: [Section]) {
        self.sections = sections
    }
    
    func rowAt(indexPath: IndexPath) -> Row? {
        return sectionAt(index: indexPath.section)?.cellAt(row: indexPath.row)
    }
    
    func sectionAt(index: Int) -> Section? {
        return index < self.sections.count ? sections[index] : nil
    }
    
    func hasData() -> Bool {
        return self.sections.filter({ $0.rows.count > 0 }).count > 0
    }
}

class Section {
    var rows: [Row]
    var header: HeaderFooter?
    let footer: HeaderFooter?
    
    init(header hv: HeaderFooter? = nil, footer fv: HeaderFooter? = nil, rows: [Row]) {
        self.header = hv
        self.footer = fv
        self.rows = rows
    }
    
    func headerView() -> UIView? { // TODO: redo category page
        return self.header?.view
    }
    
    func cellAt(row: Int) -> Row? {
        if row < self.rows.count {
            return self.rows[row]
        }
        return nil
    }
}

class Row {
    let identifier: String
    let setUp: (UITableViewCell, IndexPath) -> Void
    let collectionSetUp: (UICollectionViewCell) -> Void
    private(set) var editingStyle: UITableViewCellEditingStyle = .none
    
    //    init(identifier: String, setUpWithIndex: @escaping (UITableViewCell, IndexPath) -> Void) {
    //        self.identifier = identifier
    //        self.setUp = setUp
    //        self.collectionSetUp = { _ in }
    //    }
    //
    init(identifier: String, editingStyle: UITableViewCellEditingStyle = .none, setUp: @escaping (UITableViewCell) -> Void) {
        self.identifier = identifier
        self.editingStyle = editingStyle
        self.setUp = { (cell, _) in setUp(cell) }
        self.collectionSetUp = { _ in }
    }
    
    init(collectionIdentifier identifier: String, setUp: @escaping (UICollectionViewCell) -> Void) {
        self.identifier = identifier
        self.setUp = { _ in }
        self.collectionSetUp = setUp
    }
}

struct HeaderFooter {
    let view: UIView?
    let identifier: String?
    let title: String?
    let setUp: (_ view: UIView?, IndexPath) -> Void
    
    init(identifier id: String, setUp: @escaping (_ view: UIView?, IndexPath) -> Void) {
        self.view = nil
        self.identifier = id
        self.title = nil
        self.setUp = setUp
    }
    
    init(view v: UIView, setUp: @escaping (_ view: UIView?) -> Void = { _ in }) {
        self.view = v
        self.identifier = nil
        self.title = nil
        self.setUp = { (v, _) in setUp(v) }
    }
    
    init(view v: UIView, setUpWithIndex: @escaping (_ view: UIView?, IndexPath) -> Void) {
        self.view = v
        self.identifier = nil
        self.title = nil
        self.setUp = setUpWithIndex
    }
    
    init(title t: String, setUp: @escaping (_ view: UIView?) -> Void = { _ in }) {
        self.view = nil
        self.identifier = nil
        self.title = t
        self.setUp = { (v, _) in setUp(v) }
    }
}

//
//  GRTableViewManager.swift
//  GitReview
//
//  Created by Whitney Foster on 10/14/16.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import UIKit

@objc protocol GRTableViewManagerDelegate: class {
    @objc optional func cellSelected(cell: UITableViewCell?, atIndex index: IndexPath)
    @objc optional func heightForHeader(section: Int) -> Float
    @objc optional func heightForFooter(section: Int) -> Float
    @objc optional func heightForCell(at: IndexPath) -> CGFloat
    @objc optional func canEditCell(at: IndexPath, editingStyle: UITableViewCellEditingStyle) -> Bool
    @objc optional func deleteCell(at: IndexPath)
    @objc optional func userScrolled(toPage page: Int)
}

class GRTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    internal(set) var tableSettings: TableViewSettings = TableViewSettings(sections: [])
    weak var delegate: GRTableViewManagerDelegate? = nil
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.y / scrollView.frame.size.height)
        self.delegate?.userScrolled?(toPage: page)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.y / scrollView.frame.size.height)
        self.delegate?.userScrolled?(toPage: page)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellSettings = tableSettings.rowAt(indexPath: indexPath) {
            guard let cell = cellSettings.identifier.isEmpty ? UITableViewCell() : tableView.dequeueReusableCell(withIdentifier: cellSettings.identifier) else {
                NSError.create(message: "could not find cell with identifier: \(cellSettings.identifier)")
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.white
            cell.updateConstraints()
            cell.layoutMarginsDidChange()
            cell.setNeedsDisplay()
            
            cellSettings.setUp(cell, indexPath)
            return cell
        }
        else {
            NSError.create(message: "index out of bounds: \(indexPath)")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.delegate?.heightForCell?(at: indexPath) {
            return height
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.cellSelected?(cell: tableView.cellForRow(at: indexPath), atIndex: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSettings.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSettings.sectionAt(index: section)?.rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var v: UIView?
        let header = tableSettings.sectionAt(index: section)?.header
        if let id = header?.identifier {
            v = tableView.dequeueReusableHeaderFooterView(withIdentifier: id)
        }
        else {
            v = header?.view
        }
        header?.setUp(v, IndexPath(row: 0, section: section))
        return v
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSettings.sectionAt(index: section)?.header?.title
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableSettings.sectionAt(index: section)?.footer?.view
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableSettings.sectionAt(index: section)?.footer?.title
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let style = self.tableSettings.rowAt(indexPath: indexPath)?.editingStyle, style == editingStyle {
            if editingStyle == .delete {
                self.delegate?.deleteCell?(at: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let style = self.tableSettings.rowAt(indexPath: indexPath)?.editingStyle, style != .none {
            return true
        }
        return false
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: .destructive, title: "Remove", handler: { (action, index) in
//            self.delegate?.deleteCell?(at: indexPath)
//        })
//        delete.backgroundColor = UIColor.hollarOrange
//        return [delete]
//    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let v = view as? UITableViewHeaderFooterView {
            v.contentView.backgroundColor = UIColor.clear
            if tableSettings.sectionAt(index: section)?.header?.view == nil, let text = v.textLabel?.text {
                v.textLabel?.text = text
                v.contentView.backgroundColor = UIColor.white
            }
            tableSettings.sectionAt(index: section)?.header?.setUp(v, IndexPath(row: 0, section: section))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let override = self.delegate?.heightForFooter?(section: section) {
            return CGFloat(override)
        }
        var height: CGFloat = tableSettings.sectionAt(index: section)?.footer?.view?.frame.height ?? 0
        if height == 0 && (tableSettings.sectionAt(index: section)?.footer?.title != nil || tableSettings.sectionAt(index: section)?.footer?.view != nil) {
            height = 40
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let override = self.delegate?.heightForHeader?(section: section) {
            return CGFloat(override)
        }
        var height: CGFloat = tableSettings.sectionAt(index: section)?.header?.view?.frame.height ?? 0
        if height == 0 && (tableSettings.sectionAt(index: section)?.header?.title != nil || tableSettings.sectionAt(index: section)?.header?.view != nil) {
            height = 40
        }
        return height
    }
    
}

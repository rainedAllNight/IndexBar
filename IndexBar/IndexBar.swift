//
//  IndexBar.swift
//  Rescue
//
//  Created by rainedAllNight on 2020/8/17.
//  Copyright © 2020 luowei. All rights reserved.
//

import UIKit

public protocol IndexBarDelegate: class {
    func indexBar(_ indexBar: IndexBar, didSelected index: Int)
}

fileprivate enum IndexSectionState {
    case normal
    case selected
}

public struct IndexBarConfigure {
    /// section normal title color
    public var titleColor: UIColor = .lightGray
    /// section title font
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 10)
    /// section selected title color
    public var titleColorForSelected: UIColor = .white
    /// section selected background color
    public var backgroundColorForSelected: UIColor = .blue
    /// section width&height
    public var sectionWH: CGFloat = 16
    /// section vertical spacing
    public var sectionSpacing: CGFloat = 4
    /// show bubble view, default is true
    public var showBubble = true
    /// the configure of the bubble view
    public var bubbleConfigure = BubbleConfigure()
}

public class IndexBar: UIView, UITableViewDelegate {

    @IBInspectable private var titleColor: UIColor? {
        willSet {
            guard let new = newValue else {return}
            _configure.titleColor = new
        }
    }
    @IBInspectable private var selectedTitleColor: UIColor? {
        willSet {
            guard let new = newValue else {return}
            _configure.titleColorForSelected = new
        }
    }
    @IBInspectable private var selectedBackgroundColor: UIColor? {
        willSet {
            guard let new = newValue else {return}
            _configure.backgroundColorForSelected = new
        }
    }
    @IBInspectable private var showBubble: Bool = true {
        willSet {
            _configure.showBubble = newValue
        }
    }
    @IBInspectable private var sectionWH: CGFloat = 0 {
        willSet {
            _configure.sectionWH = newValue
        }
    }
    @IBInspectable private var sectionSpacing: CGFloat = 0 {
        willSet {
            _configure.sectionSpacing = newValue
        }
    }
    
    ///if you want to listen the callback of section seleced, please set the delegate(如果想监听切换section的回调可实现此代理)
    public weak var delegate: IndexBarDelegate?
    /// configure index bar
    public var configure: ((inout IndexBarConfigure) -> ())? {
        willSet {
            newValue?(&_configure)
            initUI()
        }
    }
    
    private var dataSource = [String]()
    private var lastSelectedLabel: UILabel?
    private var lastSelectedIndex = -1
    private var subLabels = [UILabel]()
    private var tableView: UITableView?
    private var observe: NSKeyValueObservation?
    private var bubbleView: IndexBarBubbleView?
    private var _configure = IndexBarConfigure()
    
    // MARK: - Init data
    
    ///Use this function to init data
    public func setData(_ titles: [String], tableView: UITableView) {
        self.dataSource = titles
        self.tableView = tableView
        layoutIfNeeded()
        initUI()
    }

    // MARK: - UI
    
    private func initUI() {
        backgroundColor = .clear
        guard !dataSource.isEmpty else {return}
        reset()
        let redundantHeight = bounds.height - (_configure.sectionWH + _configure.sectionSpacing) * CGFloat(dataSource.count)
        var y: CGFloat = redundantHeight > 0 ? redundantHeight/2 : 0
        dataSource.forEach({
            let label = UILabel(frame: CGRect(x: 0, y: y, width: _configure.sectionWH, height: _configure.sectionWH))
            y += _configure.sectionWH + _configure.sectionSpacing
            label.text = $0
            label.textAlignment = .center
            label.layer.cornerRadius = _configure.sectionWH/2
            label.font = _configure.titleFont
            setIndexSection(label)
            subLabels.append(label)
            addSubview(label)
        })
        ///default select first
        selectSection(index: 0)
        addObserver()
        addBubbleView()
    }
    
    private func reset() {
        lastSelectedIndex = -1
        lastSelectedLabel = nil
        subLabels.removeAll()
        observe = nil
        subviews.forEach({$0.removeFromSuperview()})
    }
    
    private func addBubbleView() {
        guard _configure.showBubble else {return}
        self.bubbleView?.removeFromSuperview()
        let bubbleView = IndexBarBubbleView.init(frame: CGRect(x: -80, y: 0, width: 60, height: 60), configure: _configure.bubbleConfigure)
        addSubview(bubbleView)
        bubbleView.alpha = 0
        self.bubbleView = bubbleView
    }
    
    private func addObserver() {
        observe = tableView?.observe(\.contentOffset, options: .new, changeHandler: { [unowned self] (tableView, change) in
            guard let point = change.newValue else {return}
            guard let indexPath = tableView.indexPathForRow(at: point), indexPath.section < self.dataSource.count else {return}
            guard tableView.isDragging || tableView.isDecelerating else {return}
            self.selectSection(index: indexPath.section)
        })
    }
    
    private func setIndexSection(_ label: UILabel,
                              with state: IndexSectionState = .normal) {
        switch state {
        case .normal:
            label.textColor = _configure.titleColor
            label.layer.backgroundColor = UIColor.clear.cgColor
        case.selected:
            label.textColor = _configure.titleColorForSelected
            label.layer.backgroundColor = _configure.backgroundColorForSelected.cgColor
            lastSelectedLabel = label
            if let index = subLabels.firstIndex(of: label) {
                delegate?.indexBar(self, didSelected: index)
            }
        }
    }
    
    private func selectSection(point: CGPoint) {
        guard point.x <= bounds.width,
            point.y <= bounds.height,
            point.y > 0 else {return}
        var index = -1
        guard let label = subLabels.first(where: {
            index += 1
            return point.y < $0.frame.maxY
        }) else {return}
        if let last = lastSelectedLabel {
            setIndexSection(last, with: .normal)
        }
        setIndexSection(label, with: .selected)
        if lastSelectedIndex != index {
            addImpactFeedback()
            bubbleView?.show(label.text, on: CGPoint(x: bubbleView?.center.x ?? label.center.x, y: label.center.y))
            tableView?.scrollToRow(at: IndexPath(item: 0, section: index), at: .top, animated: true)
            lastSelectedIndex = index
        }
    }
    
    private func selectSection(index: Int) {
        if let last = lastSelectedLabel {
            setIndexSection(last, with: .normal)
        }
        setIndexSection(subLabels[index], with: .selected)
    }
    
    private func addImpactFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.prepare()
        impact.impactOccurred()
    }
    
    // MARK: - Touch Event
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let point = event?.touches(for: self)?.first?.location(in: self) else {return}
        selectSection(point: point)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let point = event?.touches(for: self)?.first?.location(in: self) else {return}
        selectSection(point: point)
        bubbleView?.hide()
    }
}



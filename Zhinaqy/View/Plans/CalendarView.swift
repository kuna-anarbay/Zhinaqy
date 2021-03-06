//
//  CalendarView.swift
//  Zhinaqy
//
//  Created by Kuanysh Anarbay on 9/8/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import CoreData


class CalendarView: UIView {
    
    static let additionalHeight: CGFloat = 80.0
    
    //MARK: UI Variables
    lazy private var nextMonthButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setImage(UIImage(named: "chevron.right"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 28, bottom: 8, right: 16)
        button.imageView?.tintColor = Color.main
        button.backgroundColor = Color.groupedBackground
        return button
    }()
    
    lazy private var prevMonthButton: UIButton = {
        let button = UIButton()
        button.tag = -1
        button.setImage(UIImage(named: "chevron.left"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 28)
        button.imageView?.tintColor = Color.main
        button.backgroundColor = Color.groupedBackground
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = Color.groupedBackground
        return label
    }()
    
    lazy private var divider: UIView = {
        let view = UIView()
        view.backgroundColor = Color.opaqueSeparator
        view.layer.cornerRadius = 3
        return view
    }()
    
    lazy private var weekStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews:
            Calendar.current.shortWeekdaySymbols.map({ (day) -> UILabel in
                let dayLabel = UILabel()
                dayLabel.text = day.uppercased()
                dayLabel.textAlignment = .center
                dayLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
                dayLabel.textColor = ["Sun", "Sat"].contains(day) ? Color.secondaryLabel : Color.label
                dayLabel.backgroundColor = Color.groupedBackground
                
                return dayLabel
            })
        )
        stackView.backgroundColor = Color.groupedBackground
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    
    lazy private var collectionView: UICollectionView = {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 0,
                                           bottom: 0,
                                           right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: self.bounds.width/7,
                                 height: self.bounds.width/7)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0,
                                                            y: 0,
                                                            width: 0,
                                                            height: 0),
                                              collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = self.backgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: DayCell.reuseId)
        
        return collectionView
    }()
    
    lazy var topConstraint: NSLayoutConstraint = {
        let constraint = self.collectionView.topAnchor.constraint(equalTo: self.weekStackView.bottomAnchor, constant: 0)
        constraint.isActive = true
        return constraint
    }()
    
    
    let fetchController: NSFetchedResultsController<Task>
    let currentMonth: Bindable<Date>
    let currentDay: Bindable<Date>
    
    
    init(frame: CGRect,
         fetchController: NSFetchedResultsController<Task>,
         currentMonth: Bindable<Date>,
         currentDay: Bindable<Date>,
         target: PlansView,
         updateMonth: Selector) {
        
        self.fetchController = fetchController
        self.currentMonth = currentMonth
        self.currentDay = currentDay
        super.init(frame: frame)
        
        nextMonthButton.addTarget(target, action: updateMonth, for: .touchDown)
        prevMonthButton.addTarget(target, action: updateMonth, for: .touchDown)
        addViews()
        setConstraints()
        collectionView.reloadData()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    
    func addTransition(_ type: CATransitionSubtype) {
        collectionView.performTransition(type)
        titleLabel.performTransition(type)
    }
    
}




//MARK:- UI updates
extension CalendarView {
    
    private func addViews() {
        self.addSubview(collectionView)
        self.addSubview(titleLabel)
        self.addSubview(nextMonthButton)
        self.addSubview(prevMonthButton)
        self.addSubview(weekStackView)
        self.addSubview(divider)
    }
    
    
    private func setConstraints() {
        prevMonthButton.anchor(top: topAnchor,
                               leading: leadingAnchor,
                               size: .init(width: 72, height: 44))
        nextMonthButton.anchor(top: topAnchor,
                               trailing: trailingAnchor,
                               size: .init(width: 72, height: 44))
        titleLabel.anchor(top: topAnchor,
                          leading: prevMonthButton.trailingAnchor,
                          trailing: nextMonthButton.leadingAnchor,
                          size: .init(width: 0, height: 44))
        weekStackView.anchor(top: titleLabel.bottomAnchor,
                             leading: leadingAnchor,
                             trailing: trailingAnchor,
                             size: .init(width: 0, height: 16))
        collectionView.anchor(leading: leadingAnchor,
                              trailing: trailingAnchor)
        topConstraint.constant = CGFloat(currentDay.value.element(.weekOfMonth) - 1)*self.frame.width/7*(-1)
        divider.anchor(top: collectionView.bottomAnchor,
                       bottom: bottomAnchor,
                       padding: .init(top: 8, left: 0, bottom: 8, right: 0),
                       size: .init(width: 66, height: 6))
        divider.anchorCenter(x: self.centerXAnchor)
    }
}






//MARK:- CollectionView datasource
extension CalendarView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return currentMonth.value.count(get: .weekOfMonth, from: .month)*7
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.reuseId, for: indexPath) as! DayCell
        
        let indexOfFirstDay = currentMonth.value.element(.weekday) - 1
        let date = currentMonth.value.increment(by: indexPath.row - indexOfFirstDay, .day)
        let sameMonth = indexPath.row >= indexOfFirstDay && indexPath.row < indexOfFirstDay + currentMonth.value.count(get: .day, from: .month)
        
        let section = fetchController.sections?.first(where: { Date($0.name).same(.day, as: date) })
        cell.configure(date: date,
                       section: section,
                       currentDay: self.currentDay.value.same(.day, as: date),
                       currentMonth: sameMonth)
        
        return cell
    }
    
}


//MARK:- CollectionView delegate
extension CalendarView: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        
        let indexOfFirstDay = currentMonth.value.element(.weekday) - 1
        let sameMonth = indexPath.row >= indexOfFirstDay && indexPath.row < indexOfFirstDay + currentMonth.value.count(get: .day, from: .month)
        if sameMonth {
            let temp = currentDay.value.element(.day) + indexOfFirstDay - 1
            currentDay.value = currentMonth.value.increment(by: indexPath.row - indexOfFirstDay, .day)
            collectionView.reloadItems(at: [indexPath, IndexPath(item: temp, section: 0)])
        }
        
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

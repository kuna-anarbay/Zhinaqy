//
//  ViewFactory.swift
//  Zhinaqy
//
//  Created by Kuanysh Anarbay on 9/8/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit

protocol ViewFactory {
    func makeRootView() -> UITabBarController
    func makePlansView() -> PlansView
    func makeNewTaskView(with task: Task?,
                         type: NewTaskState,
                         project: Project) -> NewTaskView
    
    func makeProjectsView() -> ProjectsView
    func makeNewProjectView(with project: Project?,
                            type: NewProjectState)  -> NewProjectView
    func makeProjectView(with project: Project) -> ProjectView
}

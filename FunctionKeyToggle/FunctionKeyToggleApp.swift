//
//  FunctionKeyToggleApp.swift
//  FunctionKeyToggle
//
//  Created by Jonathan Wight on 1/4/25.
//

import SwiftUI

@main
struct FunctionKeyToggleApp: App {

    @State
    private var viewModel = ViewModel()

    var body: some Scene {
        Settings {
            ContentView()
                .environment(viewModel)
                .navigationTitle("Settings")                
        }
//        .windowLevel(.floating)

        MenuExtra()
        .environment(viewModel)
    }
}


//
//  MainTabView.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/21.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "list.dash")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "square.and.pencil")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

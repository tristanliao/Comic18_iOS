//
//  HomeView.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/21.
//

import SwiftUI

struct HomeView: View {
    let homeLoader = HomeLoader()
    var comics: [Comic] = []
    @State var recentComics: [Comic] = []
    @State var latestKoreanComics: [Comic] = []
    @State var recommendComics: [Comic] = []
    @State var latestComics: [Comic] = []
    let gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        List {
            Section("連載更新") {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(recentComics, id: \.self) { comic in
                        ComicCellView(comic: comic)
                    }
                }
            }
            
            Section("最新韓漫") {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(latestKoreanComics, id: \.self) { comic in
                        ComicCellView(comic: comic)
                    }
                }
            }
            
            Section("推薦") {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(recommendComics, id: \.self) { comic in
                        ComicCellView(comic: comic)
                    }
                }
            }
            
            Section("最新漫畫") {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(latestComics, id: \.self) { comic in
                        ComicCellView(comic: comic)
                    }
                }
            }
        }
        .onAppear(perform: loadComics)
    }
    
    private func loadComics() {
        homeLoader.loadRecentComics { result in
            switch result {
            case let .success(comics):
                recentComics = comics
            case let .failure(error):
                print(error)
            }
        }
        
        homeLoader.loadLatestKoreanComics { result in
            switch result {
            case let .success(comics):
                latestKoreanComics = comics
            case let .failure(error):
                print(error)
            }
        }
        
        homeLoader.loadRecommendComics { result in
            switch result {
            case let .success(comics):
                recommendComics = comics
            case let .failure(error):
                print(error)
            }
        }
        
        homeLoader.loadLatestComics { result in
            switch result {
            case let .success(comics):
                latestComics = comics
            case let .failure(error):
                print(error)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView(comics: [
            Comic.mockComic1,
            Comic.mockComic2,
            Comic.mockComic3
        ])
    }
}

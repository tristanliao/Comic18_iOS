//
//  HomeView.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/21.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
        }
    }
}

struct HomeView: View {
    let homeLoader = HomeLoader()
    var comics: [Comic] = []
    @State var recentComics: [Comic] = []
    @State var latestKoreanComics: [Comic] = []
    @State var recommendComics: [Comic] = []
    @State var latestComics: [Comic] = []
    
    let gridItems = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    Section(header: SectionHeaderView(title: "連載更新")) {
                        ForEach(recentComics, id: \.self) { comic in
                            NavigationLink(value: comic) {
                                ComicCellView(comic: comic)
                            }
                        }
                    }
                    
                    Section(header: SectionHeaderView(title: "最新韓漫")) {
                        ForEach(latestKoreanComics, id: \.self) { comic in
                            NavigationLink(value: comic) {
                                ComicCellView(comic: comic)
                            }
                        }
                    }
                    
                    Section(header: SectionHeaderView(title: "推薦")) {
                        ForEach(recommendComics, id: \.self) { comic in
                            NavigationLink(value: comic) {
                                ComicCellView(comic: comic)
                            }
                        }
                    }
                    
                    Section(header: SectionHeaderView(title: "最新漫畫")) {
                        ForEach(latestComics, id: \.self) { comic in
                            NavigationLink(value: comic) {
                                ComicCellView(comic: comic)
                            }
                        }
                    }
                }
                .padding(.init(top: 0, leading: 5, bottom: 0, trailing: 5))
            }
            .navigationTitle("首頁")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Comic.self) { comic in
                let viewModel = ComicDetailViewModel(comicID: comic.id)
                ComicDetailView(viewModel: viewModel)
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

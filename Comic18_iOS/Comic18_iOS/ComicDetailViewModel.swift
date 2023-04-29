//
//  ComicDetailViewModel.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/4/27.
//

import Foundation
import SwiftUI

final class ComicDetailViewModel: ObservableObject {
    private let detailLoader: DetailLoader
    private var comicDetail: ComicDetail?
    
    @Published var comicTitle: String = ""
    @Published var comicDescription: String = ""
    @Published var authors: [String] = []
    @Published var watchCountString: String = ""
    @Published var likeCountString: String = ""
    @Published var releaseDateString: String = ""
    @Published var updateDateString: String = ""
    @Published var chapters: [Chapter] = []
    @Published var coverImageURL: URL?
    @Published var previewImagesURL: [URL] = []
    @Published var tags: [String] = []
    @Published var startButtonTitle: String = "開始閱讀"
    
    init(comicID: String) {
        self.detailLoader = DetailLoader(comicID: comicID)
    }
    
    func loadComicDetail() {
        detailLoader.getDetail { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(detail):
                self.comicDetail = detail
                DispatchQueue.main.async {
                    self.comicTitle = detail.title
                    self.comicDescription = detail.description
                    self.authors = detail.authors
                    self.watchCountString = "\(detail.watchCount) 次觀看"
                    self.likeCountString = "\(detail.likeCount) 喜歡"
                    self.releaseDateString = "上架日期：\(detail.releaseDate)"
                    self.updateDateString = "更新日期：\(detail.updateDate)"
                    self.coverImageURL = URL(string: detail.coverImage)
                    self.previewImagesURL = detail.previewImages.compactMap { URL(string: $0) }
                    self.tags = detail.tags
                    self.chapters = detail.chapters
                }
                
                print(detail)
            case let .failure(error):
                print(error)
            }
        }
    }
}

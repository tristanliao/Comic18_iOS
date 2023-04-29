//
//  ComicDetailView.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/26.
//

import SwiftUI
import WrappingHStack

struct ComicDetailView: View {
    private enum Constants {
        static let chapterCellWidth: CGFloat = 100
        static let chapterCellHeight: CGFloat = 50
        static let chapterCellInterval: CGFloat = 10
    }
    
    @StateObject var viewModel: ComicDetailViewModel
    
    init(viewModel: ComicDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                // Preview images
                TabView() {
                    AsyncImage(url: viewModel.coverImageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Color.white
                    }
                    
                    ForEach(viewModel.previewImagesURL, id: \.self) {
                        AsyncImage(url: $0) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Color.white
                        }
                    }
                }
                .frame(height: 400)
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                // Comic title
                HStack {
                    Text(viewModel.comicTitle)
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                    Spacer()
                }
                
                ScrollView(.horizontal) {
                    HStack {
                        Text("作者：")
                            .font(.system(size: 14))
                        ForEach(viewModel.authors, id: \.self) { author in
                            Text(author)
                                .font(.system(size: 14))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Detail info
                HStack {
                    Text(viewModel.watchCountString)
                        .font(.system(size: 12))
                    Text(viewModel.likeCountString)
                        .font(.system(size: 12))
                    Spacer()
                    Text(viewModel.releaseDateString)
                        .font(.system(size: 12))
                    Text(viewModel.updateDateString)
                        .font(.system(size: 12))
                }
                .padding(.horizontal)
                
                // Tags
                WrappingHStack(viewModel.tags, id: \.self, spacing: .constant(5), lineSpacing: 5) { tag in
                        Button(tag) {}
                            .font(.system(size: 12))
                            .buttonStyle(.bordered)
                            .tint(.pink)
                }
                .padding(.horizontal)
                
                // Comic description
                Text(viewModel.comicDescription)
                    .font(.system(size: 16))
                    .padding()
                
                let chapterLayout: [GridItem] = [
                    GridItem(.adaptive(
                        minimum: Constants.chapterCellWidth,
                        maximum: Constants.chapterCellWidth
                    ))
                ]
                
                LazyVGrid(columns: chapterLayout, spacing: Constants.chapterCellInterval) {
                    ForEach(viewModel.chapters, id: \.id) { chapter in
                        Button(action: {
                            
                        }, label: {
                            Text(String(chapter.number)).frame(width: 70)
                        })
                            .buttonStyle(.bordered)
                    }
                }
                
                Button(action: {
                    
                }) {
                    Text(viewModel.startButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                .padding()
            }
        }
        .onAppear(perform: viewModel.loadComicDetail)
    }
    
    
}

struct ComicDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ComicDetailViewModel(comicID: "364522")
        ComicDetailView(viewModel: viewModel)
    }
}

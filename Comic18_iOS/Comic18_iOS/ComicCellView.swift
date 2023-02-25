//
//  ComicCellView.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/23.
//

import SwiftUI

struct ComicCellView: View {
    let comic: Comic
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: comic.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.6)
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 4) {
                    Text(comic.category)
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                        .background(.black)
                        .cornerRadius(5)
                    
                    if let subCategory = comic.subCategory {
                        Text(subCategory)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                            .background(.black)
                            .cornerRadius(5)
                    }
                }
                .offset(x: -5, y: 5)
            }
            .overlay(alignment: .bottomLeading) {
                Text("❤️ " + comic.likesCount)
                    .font(.system(size: 10))
                    .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
                    .background(.white)
                    .cornerRadius(5)
                    .offset(x: 5, y: -5)
            }
            .overlay(alignment: .bottomTrailing) {
                // 書籤 icon
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(comic.title)
                    .font(.system(size: 12))
                    .lineLimit(2)
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(comic.authors.joined(separator: ", "))
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(comic.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
                                .background(.black.opacity(0.8))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(8)
        }
    }
}

struct ComicCellView_Previews: PreviewProvider {
    static var previews: some View {
        ComicCellView(comic: Comic.mockComic1)
    }
}

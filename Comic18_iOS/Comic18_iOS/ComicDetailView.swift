//
//  ComicDetailView.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/26.
//

import SwiftUI

struct ComicDetailView: View {
    let comic: Comic
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ComicDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ComicDetailView(comic: Comic.mockComic1)
    }
}

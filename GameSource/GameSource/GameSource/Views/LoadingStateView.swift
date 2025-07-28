//
//  LoadingStateView.swift
//  GameSource
//
//  Created by Enzo Ferroni on 24/07/25.
//

import SwiftUI

struct LoadingStateView: View {
    var body: some View {
        ProgressView("Loading...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingStateView()
}
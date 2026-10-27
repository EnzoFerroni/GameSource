//
//  CompatibilityViews.swift
//  GameSource
//
//  Created by Enzo Ferroni on 27/10/26.
//

import SwiftUI

// NavigationStack on iOS 16 and later, a stack-style NavigationView on iOS 15.
struct CompatibleNavigationStack<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
                .navigationViewStyle(.stack)
        }
    }
}

// ContentUnavailableView on iOS 17 and later, the same icon, title,
// description and actions in a plain stack on older versions.
struct UnavailableView<Actions: View>: View {
    let title: String
    let systemImage: String
    let description: String
    @ViewBuilder let actions: () -> Actions

    init(
        _ title: String,
        systemImage: String,
        description: String,
        @ViewBuilder actions: @escaping () -> Actions = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actions = actions
    }

    var body: some View {
        if #available(iOS 17, *) {
            ContentUnavailableView {
                Label(title, systemImage: systemImage)
            } description: {
                Text(description)
            } actions: {
                actions()
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.title2.bold())

                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                actions()
            }
            .padding(32)
            .frame(maxWidth: .infinity)
        }
    }
}

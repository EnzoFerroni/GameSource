import SwiftUI

struct FilterBarView: View {
    @ObservedObject var gamesViewModel: GamesViewModel
    @State private var showFilters = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search games...", text: $gamesViewModel.searchText)
                    
                    if !gamesViewModel.searchText.isEmpty {
                        Button(action: {
                            gamesViewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Filter button
                Button(action: {
                    withAnimation {
                        showFilters.toggle()
                    }
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Expanded filter options
            if showFilters {
                VStack(spacing: 8) {
                    HStack {
                        Text("Sort by:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Picker("Sort", selection: $gamesViewModel.selectedSort) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    HStack {
                        Text("Filter:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Picker("Filter", selection: $gamesViewModel.selectedFilter) {
                            ForEach(FilterOption.allCases, id: \.self) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

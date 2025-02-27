//
//  HomeView.swift
//  Cocktails
//
//  Created by Josh Smith on 11/25/24.
//


import SwiftUI
import CoreSpotlight
#if canImport(WidgetKit)
import WidgetKit
#endif

struct HomeView: View {
    
    @EnvironmentObject private var bar: Bar
    @State private var sheet: SheetItem?
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                CocktailList()
                    .sheet(item: $sheet) { sheet in
                        switch sheet {
                        case .shopping:
                            ShoppingView()
                        case .filter:
                            FilterView()
                        case .ingredients:
                            CocktailsByIngredient()
                        case .guests:
                            GuestsView()
                        case .settings:
                            SettingsView()
                        }
                    }
            }
            Tab("Ingredients", systemImage: "vial.viewfinder") {
                CocktailsByIngredient()
            }
            Tab("Shopping List", systemImage: "cart") {
                ShoppingView()
            }
            Tab("Guests", systemImage: "person.3") {
                GuestsView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .onOpenURL(perform: openURL)
        .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
    }
    
    func openURL(_ url: URL) {
        if url.isDeepLink {
            if let cocktail = url.cocktail {
                print("COMMENT (Open URL): Opening \(cocktail.name).")
                bar.selectedCocktail = [cocktail]
            } else if let host = url.host {
                print("COMMENT (Open URL): Opening \(host).")
                sheet = SheetItem(host)
            }
        } else {
            print("COMMENT (Open URL): URL \(url) is not a deep link.")
        }
    }
    
    func loadSpotlightItem(userActivity: NSUserActivity) {

        if let path = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            let url = URL(string: "cocktails://\(path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")")
            if let url {
                openURL(url)
            }
        }
    }
    
    enum SheetItem: String, Identifiable {
        case shopping, filter, ingredients, guests, settings
        var id: Self { return self }
        init(_ path: String) {
            self = SheetItem(rawValue: path) ?? .shopping
        }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(Bar.preview)
}

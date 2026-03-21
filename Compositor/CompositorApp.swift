//
//  CompositorApp.swift
//  Compositor
//
//  Created by Formic on 6/17/25.
//

import SwiftUI
import SwiftData

@main
struct CompositorApp: App {
    @StateObject private var profileData = ProfileData.shared
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding: Bool = false
    

    let modelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: Composite.self)
            let context = ModelContext(container)

            // Insert example data
            //context.insert(Composite(textContent: "Example Note 1", classification: "happy", latitude: 0, longitude: 0, sort: 1))
            //context.insert(Composite(textContent: "Example Note 2", classification: "melancholy", latitude: 0, longitude: 0, sort: 2))
            
            // Save changes
            try context.save()
            
            return container
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            OnboardingView()
                //.preferredColorScheme(.light)
                .modelContainer(modelContainer)
                .environmentObject(profileData)
                .onAppear(){
                    profileData.didCompleteOnboarding = self.didCompleteOnboarding
                }
                .onChange(of: profileData.didCompleteOnboarding) {
                    self.didCompleteOnboarding = profileData.didCompleteOnboarding
                }
        }
        
    }
}

struct PreviewWrapper<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .environmentObject(ProfileData.shared)
            .preferredColorScheme(.light)
    }
}

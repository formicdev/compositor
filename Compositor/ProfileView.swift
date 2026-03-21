//
//  ProfileView.swift
//  Compositor
//
//  Created by Formic on 8/31/25.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

struct HueSlider: View {
    @Binding var hue: Double

    var body: some View {
        Slider(value: $hue, in: 0...1)
            .tint(Color(hue: hue, saturation: 1, brightness: 1))
            .padding()
            .background(
                LinearGradient(
                    colors: stride(from: 0.0, to: 1.0, by: 0.02).map {
                        Color(hue: $0, saturation: 0.7, brightness: 1)
                    },
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
    }
}

struct ProfileView: View {
    @State private var showSettings = false
    @State private var showPopup = false
    @State private var userInput = ""
    @State private var hue = 0.1
    @State private var bright = 1.0
    @State private var brightness = 0.5
    @Environment(\.dismiss) var dismiss
    
    //@State var value: CGFloat = 3
    @State var dragValue1: CGFloat = 0.5
    @State var dragValue2: CGFloat = 0.5
    @State var isDragged1: Bool = false
    @State var isDragged2: Bool = false

    
    
    var body: some View {
        ZStack(){
                ZStack(alignment: .center) {
                    // Background color for the top bar
                    //FoundationBG()
                    
                    VStack(){
                        profileImage()
                        
                        .frame(width: 200)
                        
                        Spacer()
                            .frame(height: 30)
                        
                        Text("Aidan Jiao")
                            .foundationText(.title, color: Color(hue: hue, saturation: 1, brightness: 0.2))
                        
                        Spacer()
                            .frame(height: 30)
                        
                        ZStack() {
                            GeometryReader { geo in
                                let width = geo.size.width
                                
                                ZStack(alignment: .leading) {
                                    
                                    ZStack(){
                                        LinearGradient(
                                            colors: stride(from: 0.0, to: 1.0, by: 0.02).map {
                                                Color(hue: $0, saturation: 0.7, brightness: 1)
                                            },
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Capsule()
                                        )
                                        .frame(height: 48)
                                        LinearGradient(
                                            colors: stride(from: 0.0, to: 1.0, by: 0.02).map {
                                                Color(hue: $0, saturation: 0.7, brightness: 1)
                                            },
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .blur(radius: 20)
                                        .mask(
                                            Capsule()
                                        )
                                        .frame(height: 48)
                                    }
                                    .padding(.horizontal, -13)
                                    .padding(.leading, -5)

                                    
                                    ZStack {
                                        Circle()
                                            .fill(.white)
                                            
                                            .scaleEffect(isDragged1 ? 1.423 : 1)
                                            .opacity(isDragged1 ? 1 : 0.9)
                                        
                                        
                                        Circle()
                                            .fill(Color(hue: hue, saturation: 1, brightness: 1))
                                            .scaleEffect(isDragged1 ? 1.423 : 1)
                                            .opacity(isDragged1 ? 0.5 : 0)
                                            //.opacity(isDragged1 ? 0 : 1)
                                        
                                        
                                        Circle()
                                            .fill(Color(.clear))
                                            .strokeBorder(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white,        // top-left
                                                            Color.clear,       // mid
                                                            Color.white       // bottom-right
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.2
                                                )
                                            .scaleEffect(isDragged1 ? 1.423 : 1)
                                            .opacity(isDragged1 ? 0.9 : 0)
                                            .blur(radius: 0.5)
                                        
                                        
                                        
                                        ZStack(){
                                            Capsule()
                                                .fill(Color(hue: hue, saturation: 1, brightness: 1))
                                                .padding(5)
                                                .opacity(isDragged1 ? 0 : 0.7)
                                                .shadow(color: .black.opacity(0.3), radius: 6)
                                                .blur(radius: isDragged1 ? 3 : 0)
                                        }
                                        .scaleEffect(isDragged1 ? 1.8 : 1)
                                        
                                        ZStack{
                                            Circle()
                                                .mask(
                                                    ZStack(){
                                                        VStack(){
                                                            Rectangle()
                                                                .fill(.black)
                                                                .padding(.top, 1)
                                                            Spacer()
                                                                .padding(5)
                                                            Rectangle()
                                                                .fill(.black)
                                                                .padding(.bottom, 1)
                                                        }
                                                        Capsule()
                                                            .strokeBorder(.black, lineWidth: 5)
                                                            .opacity(hue < 0.01 || hue > 0.99 ? 0.3 : 0)
                                                            .padding(.horizontal, -25)
                                                            .offset(x: hue < 0.01 ? 25 : hue > 0.99 ? -25 : 0, y: 0)
                                                            .animation(.smooth(duration: 0.3), value: hue)

                                                    }
                                                        .opacity(isDragged1 ? 0.3 : 0)

                                                )
                                        }
                                        .scaleEffect(1.423)
                                        .blur(radius: 2)
                                        //.animation(.bouncy(duration: 0.34), value: isDragged1)
                                    
                                            
                                        
                                        
                                    }
                                    .shadow(color: .black.opacity(0.12), radius: 8)
                                    .frame(width: 42, height: 42)
                                    .offset(x: dragValue1 * width - (36 * (0.4 + 0.5 * dragValue1)))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { drag in
                                                let x = drag.location.x
                                                dragValue1 = max(0, min(1, x / width))
                                                hue = 0 + ((1 - 0) * dragValue1)
                                            }
                                    )
                                    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                                        withAnimation(.bouncy(duration: 0.4, extraBounce: 0.12)) {
                                            isDragged1 = pressing
                                        }
                                    }, perform: {})
                                }
                            }
                            .frame(height: 36)
                            .onAppear {
                                dragValue1 = hue / (1 - 0)
                            }
                            
                        }
                        .padding(.horizontal, 30)
                        

                        Spacer()
                            .frame(height: 30)
                        
                        ZStack() {
                            GeometryReader { geo in
                                let width = geo.size.width
                                
                                ZStack(alignment: .leading) {
                                    
                                    ZStack(){
                                        LinearGradient(
                                            colors: [
                                                Color(hue: hue, saturation: 0.7, brightness: 0.8),
                                                Color(hue: hue, saturation: 0.7, brightness: 1.2)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Capsule()
                                        )
                                        .frame(height: 48)
                                        
                                    }
                                    .padding(.horizontal, -13)
                                    .padding(.leading, -5)
                                    .onChange(of: brightness){
                                        bright = 0.8 + (0.4 * brightness)
                                    }
                                    
                                    ZStack {
                                        Circle()
                                            .fill(.white)
                                            
                                            .scaleEffect(isDragged2 ? 1.423 : 1)
                                            .opacity(isDragged2 ? 1 : 0.9)
                                        
                                        
                                        Circle()
                                            .fill(Color(hue: hue, saturation: 1, brightness: bright))
                                            .scaleEffect(isDragged2 ? 1.423 : 1)
                                            .opacity(isDragged2 ? 0.65 : 0)
                                            //.opacity(isDragged2 ? 0 : 1)
                                        
                                        
                                        Circle()
                                            .fill(Color(.clear))
                                            .strokeBorder(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white,        // top-left
                                                            Color.clear,       // mid
                                                            Color.white       // bottom-right
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.2
                                                )
                                            .scaleEffect(isDragged2 ? 1.423 : 1)
                                            .opacity(isDragged2 ? 0.9 : 0)
                                            .blur(radius: 0.5)
                                        
                                        
                                        
                                        ZStack(){
                                            Capsule()
                                                .fill(Color(hue: hue, saturation: 1, brightness: bright))
                                                .padding(5)
                                                .opacity(isDragged2 ? 0 : 0.7)
                                                .shadow(color: .black.opacity(0.3), radius: 6)
                                                .blur(radius: isDragged2 ? 3 : 0)
                                        }
                                        .scaleEffect(isDragged2 ? 1.8 : 1)
                                        
                                        ZStack{
                                            Circle()
                                                .mask(
                                                    ZStack(){
                                                        VStack(){
                                                            Rectangle()
                                                                .fill(.black)
                                                                .padding(.top, 1)
                                                            Spacer()
                                                                .padding(5)
                                                            Rectangle()
                                                                .fill(.black)
                                                                .padding(.bottom, 1)
                                                        }
                                                        Capsule()
                                                            .strokeBorder(.black, lineWidth: 5)
                                                            .opacity(brightness < 0.01 || brightness > 0.99 ? 0.3 : 0)
                                                            .padding(.horizontal, -25)
                                                            .offset(x: brightness < 0.01 ? 25 : brightness > 0.99 ? -25 : 0, y: 0)
                                                            .animation(.smooth(duration: 0.3), value: hue)

                                                    }
                                                        .opacity(isDragged2 ? 0.3 : 0)

                                                )
                                        }
                                        .scaleEffect(1.423)
                                        .blur(radius: 2)
                                        //.animation(.bouncy(duration: 0.34), value: isDragged2)
                                    
                                            
                                        
                                        
                                    }
                                    .shadow(color: .black.opacity(0.12), radius: 8)
                                    .frame(width: 42, height: 42)
                                    .offset(x: dragValue2 * width - (36 * (0.4 + 0.5 * dragValue2)))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { drag in
                                                let x = drag.location.x
                                                dragValue2 = max(0, min(1, x / width))
                                                brightness = 0 + ((1 - 0) * dragValue2)
                                            }
                                    )
                                    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                                        withAnimation(.bouncy(duration: 0.4, extraBounce: 0.12)) {
                                            isDragged2 = pressing
                                        }
                                    }, perform: {})
                                }
                            }
                            .frame(height: 36)
                            .onAppear {
                                dragValue2 = brightness / (1 - 0)
                            }
                            
                        }
                        .padding(.horizontal, 30)
                        
                        
                    }
                    
                    
                    
                }
                .padding(.top, 16)
                
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        
    }
}

class ProfileData: ObservableObject {
    static let shared = ProfileData()
    
    @Published var didCompleteOnboarding: Bool = false
    //var does sutff in othrr file check later
    
    
    //store one place set it aftr launch
    @Published var hue: Double = 0.1
    @Published var brightness: Double = 1.0
    
    @Published var isToastPresented: Bool = false
}

func sendToast(){
    @EnvironmentObject var profileData: ProfileData
    
}

struct profileImage: View {
    @EnvironmentObject var profileData: ProfileData

    /*
    init(_ hue: Double, _ brightness: Double){
        self.hue = hue
        self.brightness = brightness
    }
    */
    
    
    var body: some View {
        ZStack(){
            Circle()
                .fill(Color(hue: profileData.hue, saturation: 1, brightness: 1))
                .blur(radius: 30)
                .opacity(0.25)
            Image("profile")
                .resizable()
                .scaledToFit()
                .brightness((profileData.brightness - 1) / 3)
            Circle()
                .fill(Color(hue: profileData.hue, saturation: 1, brightness: 1))
                .blendMode(.color)
               
            
        }
        .compositingGroup()
        
    }
    
    
    
}






struct ProfileEditPreview: View{
    var body: some View{
        ZStack(){
            Color(.black)
            ProfileEditView()
        }
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.all)
    }
}

struct ProfileEditView: View {
    @State private var showSettings = false
    @State private var showPopup = false
    @State private var userInput = ""
    @State private var hue = 0.1
    @State private var bright = 1.0
    @State private var brightness = 0.5
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileData: ProfileData
    
    //@State var value: CGFloat = 3
    @State var dragValue1: CGFloat = 0.5
    @State var dragValue2: CGFloat = 0.5
    @State var isDragged1: Bool = false
    @State var isDragged2: Bool = false
    @State var isChanging1: Bool = false
    @State private var hueHistory: [Double] = [0.0, 0.0]
    
    
    var body: some View {
        ZStack(){
                ZStack(alignment: .center) {
                    // Background color for the top bar
                    //FoundationBG()
                    Color(.clear)
                        .ignoresSafeArea()
                    
                    VStack(){
                        profileImage()
                            .onChange(of: hue){
                                profileData.hue = hue
                            }
                            .onChange(of: bright){
                                profileData.brightness = bright
                            }
                        .frame(width: 200)
                        .onAppear {
                            dragValue1 = profileData.hue
                            hue = profileData.hue
                            bright = profileData.brightness
                            brightness = (bright - 0.8) / 0.4
                            dragValue2 = brightness

                        }
                        
                        
                        
                        Spacer()
                            .frame(height: 30)
                        
                        Text("Aidan Jiao")
                            .foundationText(.title, color: Color(hue: hue, saturation: 0.7, brightness: 3))
                        
                        Spacer()
                            .frame(height: 30)
                        
                        Text("\(hue, specifier: "%.3f")")
                            .foregroundStyle(Color(hue: hue, saturation: 0.55, brightness: 2))
                            .fontWeight(.bold)
                            .font(.system(.footnote, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 18)
                            .brightness(-0.5)
                        
                        ZStack() {
                            GeometryReader { geo in
                                let width = geo.size.width
                                
                                ZStack(alignment: .leading) {
                                    
                                    ZStack(){
                                        LinearGradient(
                                            colors: stride(from: 0.0, to: 1.0, by: 0.02).map {
                                                Color(hue: $0, saturation: 0.7, brightness: 1)
                                            },
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Capsule()
                                        )
                                        .frame(height: 48)
                                        LinearGradient(
                                            colors: stride(from: 0.0, to: 1.0, by: 0.02).map {
                                                Color(hue: $0, saturation: 0.7, brightness: 1)
                                            },
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .blur(radius: 20)
                                        .mask(
                                            Capsule()
                                        )
                                        .frame(height: 48)
                                    }
                                    .padding(.horizontal, -13)
                                    .padding(.leading, -5)

                                    
                                    ZStack {
                                        Circle()
                                            .fill(.white)
                                            
                                            .scaleEffect(isDragged1 ? 1.423 : 1)
                                            .opacity(isDragged1 ? 1 : 0.9)
                                        /*
                                            .onChange(of: hue) {
                                                print(isChanging1)
                                                hueHistory[1] = hueHistory[0]   // previous = old current
                                                hueHistory[0] = hue        // current = new value
                                                isChanging1 = (hueHistory[0] != hueHistory[1])
                                            }
                                            .onChange(of: isDragged1) {
                                                print(isChanging1)
                                                hueHistory[1] = hueHistory[0]   // previous = old current
                                                hueHistory[0] = hue        // current = new value
                                                isChanging1 = (hueHistory[0] != hueHistory[1])
                                            }
                                        */
                                        
                                        Circle()
                                            .fill(Color(hue: hue, saturation: 1, brightness: 1))
                                            .scaleEffect(isDragged1 ? 1.423 : 1)
                                            .opacity(isDragged1 ? 0.57 : 0)
                                            //.opacity(isDragged1 ? 0 : 1)
                                        
                                        
                                        
                                        
                                        Circle()
                                            .fill(Color(.clear))
                                            .strokeBorder(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white,        // top-left
                                                            Color.clear,       // mid
                                                            Color.white       // bottom-right
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.2
                                                )
                                            .scaleEffect(isDragged1 ? 1.423 : 1)
                                            .opacity(isDragged1 ? 0.9 : 0)
                                            .blur(radius: 0.5)
                                        
                                        
                                        
                                        
                                        ZStack(){
                                            Capsule()
                                                .fill(Color(hue: hue, saturation: 1, brightness: 1))
                                                .padding(5)
                                                .opacity(isDragged1 ? 0 : 0.7)
                                                .shadow(color: .black.opacity(0.3), radius: 6)
                                                .blur(radius: isDragged1 ? 3 : 0)
                                        }
                                        .scaleEffect(isDragged1 ? 1.8 : 1)
                                        
                                        ZStack{
                                            Circle()
                                                .foregroundStyle(.black)
                                                .mask(
                                                    ZStack(){
                                                        VStack(){
                                                            Ellipse()
                                                                .fill(.black)
                                                                .padding(.top, 1)
                                                            Spacer()
                                                                .padding(4)
                                                            Ellipse()
                                                                .fill(.black)
                                                                .padding(.bottom, 1)
                                                        }
                                                        .padding(.horizontal, hue < 0.01 || hue > 0.99 ? 12 : 14)
                                                        .animation(.smooth(duration: 0.2), value: hue)
                                                        Capsule()
                                                            .strokeBorder(.black, lineWidth: 6)
                                                            .opacity(hue < 0.01 || hue > 0.99 ? 0.45 : 0)
                                                            .padding(.horizontal, -25)
                                                            .offset(x: hue < 0.01 ? 25 : hue > 0.99 ? -25 : 0, y: 0)
                                                            .animation(.smooth(duration: 0.3), value: hue)

                                                    }
                                                        .opacity(isDragged1 ? 0.35 : 0)

                                                )
                                        }
                                        .scaleEffect(1.423)
                                        .blur(radius: 2)
                                        //.animation(.bouncy(duration: 0.34), value: isDragged1)
                                    
                                            
                                        
                                        
                                    }
                                    .shadow(color: .black.opacity(0.12), radius: 8)
                                    .frame(width: 42, height: 42)
                                    .offset(x: dragValue1 * width - (36 * (0.4 + 0.5 * dragValue1)))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { drag in
                                                let x = drag.location.x
                                                dragValue1 = max(0, min(1, x / width))
                                                hue = 0 + ((1 - 0) * dragValue1)
                                            }
                                    )
                                    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                                        withAnimation(.bouncy(duration: 0.4, extraBounce: 0.12)) {
                                            isDragged1 = pressing
                                        }
                                    }, perform: {})
                                }
                            }
                            .frame(height: 36)
                            .onAppear {
                                dragValue1 = hue / (1 - 0)
                            }
                            
                        }
                        .padding(.horizontal, 30)
                        
                        

                        Spacer()
                            .frame(height: 30)
                        
                        Text("\(brightness, specifier: "%.3f")")
                            .foregroundStyle(Color(hue: hue, saturation: 0.55, brightness: 2))
                            .fontWeight(.bold)
                            .font(.system(.footnote, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 18)
                            .brightness(-0.5)
                        
                       
                        
                        ZStack() {
                            GeometryReader { geo in
                                let width = geo.size.width
                                
                                ZStack(alignment: .leading) {
                                    
                                    ZStack(){
                                        LinearGradient(
                                            colors: [
                                                Color(hue: hue, saturation: 0.7, brightness: 0.8),
                                                Color(hue: hue, saturation: 0.7, brightness: 1.2)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Capsule()
                                        )
                                        .frame(height: 48)
                                        
                                    }
                                    .padding(.horizontal, -13)
                                    .padding(.leading, -5)
                                    .onChange(of: brightness){
                                        bright = 0.8 + (0.4 * brightness)
                                    }
                                    
                                    ZStack {
                                        Circle()
                                            .fill(.white)
                                            
                                            .scaleEffect(isDragged2 ? 1.423 : 1)
                                            .opacity(isDragged2 ? 1 : 0.9)
                                        
                                        
                                        
                                        Circle()
                                            .fill(Color(hue: hue, saturation: 1, brightness: (bright - 0.88)*1.6+1.0))
                                            .scaleEffect(isDragged2 ? 1.423 : 1)
                                            .opacity(isDragged2 ? 0.7 : 0)
                                            
                                            //.opacity(isDragged2 ? 0 : 1)
                                        
                                        
                                        Circle()
                                            .fill(Color(.clear))
                                            .strokeBorder(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white,        // top-left
                                                            Color.clear,       // mid
                                                            Color.white       // bottom-right
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.2
                                                )
                                            .scaleEffect(isDragged2 ? 1.423 : 1)
                                            .opacity(isDragged2 ? 0.9 : 0)
                                            .blur(radius: 0.5)
                                        
                                        
                                        
                                        ZStack(){
                                            Capsule()
                                                .fill(Color(hue: hue, saturation: 1, brightness: bright))
                                                .padding(5)
                                                .opacity(isDragged2 ? 0 : 0.7)
                                                .shadow(color: .black.opacity(0.3), radius: 6)
                                                .blur(radius: isDragged2 ? 3 : 0)
                                        }
                                        .scaleEffect(isDragged2 ? 1.8 : 1)
                                        
                                        ZStack{
                                            Circle()
                                                .foregroundStyle(.black)
                                                .mask(
                                                    ZStack(){
                                                        VStack(){
                                                            Ellipse()
                                                                .fill(.black)
                                                                .padding(.top, 1)
                                                            Spacer()
                                                                .padding(4)
                                                            Ellipse()
                                                                .fill(.black)
                                                                .padding(.bottom, 1)
                                                        }
                                                        .padding(.horizontal, brightness < 0.01 || brightness > 0.99 ? 12 : 14)
                                                        .animation(.smooth(duration: 0.2), value: brightness)
                                                        Capsule()
                                                            .strokeBorder(.black, lineWidth: 6)
                                                            .opacity(brightness < 0.01 || brightness > 0.99 ? 0.45 : 0)
                                                            .padding(.horizontal, -25)
                                                            .offset(x: brightness < 0.01 ? 25 : brightness > 0.99 ? -25 : 0, y: 0)
                                                            .animation(.smooth(duration: 0.3), value: brightness)

                                                    }
                                                        .opacity(isDragged2 ? 0.35 : 0)

                                                )
                                        }
                                        .scaleEffect(1.423)
                                        .blur(radius: 2)
                                        //.animation(.bouncy(duration: 0.34), value: isDragged2)
                                    
                                            
                                        
                                        
                                    }
                                    .shadow(color: .black.opacity(0.12), radius: 8)
                                    .frame(width: 42, height: 42)
                                    .offset(x: dragValue2 * width - (36 * (0.4 + 0.5 * dragValue2)))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { drag in
                                                let x = drag.location.x
                                                dragValue2 = max(0, min(1, x / width))
                                                brightness = 0 + ((1 - 0) * dragValue2)
                                            }
                                    )
                                    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                                        withAnimation(.bouncy(duration: 0.4, extraBounce: 0.12)) {
                                            isDragged2 = pressing
                                        }
                                    }, perform: {})
                                }
                            }
                            .frame(height: 36)
                            .onAppear {
                                dragValue2 = brightness / (1 - 0)
                            }
                            
                        }
                        .padding(.horizontal, 30)
                        
                        
                    }
                    
                    
                    
                }
                .padding(.top, 16)
                
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        //.ignoresSafeArea()
        //.edgesIgnoringSafeArea(.all)
        
    }
}
    

/*
 ZStack(){
     HStack() {
         Button() {
             dismiss()
         } label: {
             DefaultPillView(text: "Cancel", image: "", type: 0, padding: 20)
             
         }
         .padding(.horizontal, 15)
         
         .buttonStyle(.automatic)
         
         
         Spacer()
         
         
         Button(action: {
             dismiss()
         }) {
             DefaultPillView(text: " ", image: "checkmark", type: 1, padding: 20)
         }
         .padding(.horizontal, 15)
         .buttonStyle(.automatic)
     }
     Text("Account & Settings")
         .foundationText(.title)
 }
 .frame(maxHeight: .infinity, alignment: .top)
 .padding(.top, 16)
 */


/*
 ZStack() {
     VStack(alignment: .leading) {
         // Header
         HStack {
             Text("Profile")
                 .font(.largeTitle)
                 .fontWeight(.semibold)
                 .frame(maxWidth: .infinity, alignment: .leading)
             
             
             VStack(spacing: 20) {
                 Button("Open Popup") {
                     userInput = String(userInput.prefix(1))
                     showPopup = true
                 }
                 
                 Text("You typed: \(userInput)")
             }
             .sheet(isPresented: $showPopup) {

                 VStack(spacing: 20) {
                     Text("Enter a letter, number, or emoji.")
                         .font(.headline)
                     
                     TextField("Type here...", text: $userInput)
                         .textFieldStyle(RoundedBorderTextFieldStyle())
                         .padding()
                     
                     Button("Close") {
                         userInput = String(userInput.prefix(1))
                         showPopup = false
                     }
                     .padding()
                     .background(Color.blue)
                     .foregroundColor(.white)
                     .cornerRadius(10)
                 }
                 .padding()
             }
             
             
             Button(action: {
                 showSettings = true
             }) {
                 Image(systemName: "gear")
                     .font(.title2)
                     .fontWeight(.bold)
                     .foregroundStyle(Color(red: 0.412, green: 0.29, blue: 0.055))
                     .padding(12)
                     .background(Color(red: 1, green: 0.9, blue: 0.8))
                     .foregroundColor(.white)
                     .clipShape(Circle())
             }
         }
         .padding(.horizontal, 18)
         .padding(.top, 20)
         
         // Card background
         ZStack() {
             Rectangle()
                 .fill(
                     LinearGradient(
                         gradient: Gradient(colors: [
                             Color(red: 1, green: 0.869, blue: 0.69),
                             Color(red: 1, green: 0.763, blue: 0.494)
                         ]),
                         startPoint: .top,
                         endPoint: .bottom
                     )
                 )
                 .cornerRadius(22)
                 .padding(.horizontal, 12)
                 .frame(height: 200)
             
             ZStack() {
                 Ellipse()
                     .fill(Color.white)
                     .opacity(0.7)
                     .frame(width: 120, height: 120)
                     .shadow(color: .brown.opacity(0.6), radius: 10, x: 0, y: 4)
                 Image(systemName: "person.fill")
                     .font(.system(size: 70, weight: .bold, design: .default))
                     .foregroundStyle(Color.brown)
                 //.opacity(1)
                 
             }
         }
         
         
        
         
         
         // Overlay content
         Text("Name")
             .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.0))
             .font(.title2)
             .bold()
             .frame(maxWidth: .infinity, alignment: .center)
             .padding(.top, 15)
         /*
          Text("Notetaking tips for students.")
          .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.0))
          .font(.title2)
          .bold()
          .padding(.leading, 30)
          .padding(.top, 50)
          */
         
         
     }
     .frame(maxHeight: .infinity, alignment: .top)
     .fullScreenCover(isPresented: $showSettings) {
         SettingsView()
     }
 }
 */

#Preview {
    PreviewWrapper{
        ProfileEditPreview()
    }
    //OnboardingView()
}


/*
 
ZStack(){
 GeometryReader { geo in
     let width = geo.size.width
     
     ZStack(alignment: .leading) {
         
         LinearGradient(
             colors: stride(from: 0.0, to: 1.0, by: 0.02).map {
                 Color(hue: $0, saturation: 0.7, brightness: 1)
             },
             startPoint: .leading,
             endPoint: .trailing
         )
         .mask(
             Capsule()
         )
         .frame(height: 45)
         LinearGradient(
             colors: stride(from: 0.0, to: 1.0, by: 0.02).map {
                 Color(hue: $0, saturation: 0.7, brightness: 1)
             },
             startPoint: .leading,
             endPoint: .trailing
         )
         .blur(radius: 20)
         .mask(
             Capsule()
         )
         .frame(height: 45)
         
         
         
         ZStack {
             BoundingPrimitiveView(height: 0, radius: 30)
             
             ZStack() {
                 Capsule()
                     .fill(Color(hue: hue, saturation: 1, brightness: 1))
                     .brightness(-0.1)
                     .padding(4)
                 
                 Capsule()
                     .fill(Color(hue: hue, saturation: 1, brightness: 1))
                     .padding(6)
                     
                 
                 
             }
             .clipShape(Capsule())
             .blur(radius: isDragged1 ? 2.6 : 0.3)
             
             .animation(.smooth(duration: 0.34), value: dragValue21)
         }
         .scaleEffect(isDragged1 ? 1.12 : 1)
         .frame(width: 45, height: 45)
         .offset(x: dragValue21 * width - (36 * (0.4 + 0.5 * dragValue21)))
         .gesture(
             DragGesture()
                 .onChanged { drag in
                     let x = drag.location.x
                     dragValue21 = max(0, min(1, x / width))
                     hue = 0 + ((1 - 0) * dragValue21)
                 }
         )
         .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
             withAnimation(.bouncy(duration: 0.4, extraBounce: 0.2)) {
                 isDragged1 = pressing
             }
         }, perform: {})
     }
 }
 .frame(height: 36)
 .onAppear {
     dragValue21 = hue / (1 - 0)
 }
 
}
.padding(.horizontal, 20)

 */

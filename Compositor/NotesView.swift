//
//  NoteView.swift
//  Compositor
//
//  Created by Formic on 6/21/25.
//

import Foundation
import SwiftUI
import SwiftData

extension InsettableShape {
    func innerOuterStroke(
        outerColor: Color,
        outerWidth: CGFloat,
        outerBlend: BlendMode,
        innerColor: Color,
        innerWidth: CGFloat,
        innerBlend: BlendMode,
        inset: CGFloat = 0
    ) -> some View {
        ZStack {
            self.stroke(outerColor, lineWidth: outerWidth)
                .blendMode(outerBlend)
            self.inset(by: outerWidth / 2 + inset)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [innerColor, innerColor.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom), lineWidth: innerWidth)
                .blendMode(innerBlend)
        }
        .compositingGroup()
    }
}



/*
extension Shape {
    func warmShadow(
    ) -> some View {
        ZStack {
            .shadow(color: colorScheme == .dark ? .black : Color(red: 0.898, green: 0.824, blue: 0.694).opacity(0.7), radius: 10, y: 4)
        }
        .compositingGroup()
    }
}
*/

/*
struct RectanglesOnOval: View {
    let numberOfRects = 12
    let ellipseWidth: CGFloat = 100
    let ellipseHeight: CGFloat = 100

    var body: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2

            ZStack {
                Ellipse()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: ellipseWidth, height: ellipseHeight)
                    .position(x: centerX, y: centerY)

                ForEach(0..<numberOfRects, id: \.self) { i in
                    let t = (Double(i) / Double(numberOfRects)) * 2 * .pi

                    // Position on ellipse
                    let x = centerX + CGFloat(cos(t)) * ellipseWidth / 2
                    let y = centerY + CGFloat(sin(t)) * ellipseHeight / 2

                    // Calculate derivative for tangent
                    // dx/dt = -a * sin(t)
                    // dy/dt = b * cos(t)
                    let dx = -Double(ellipseWidth) / 2 * sin(t)
                    let dy = Double(ellipseHeight) / 2 * cos(t)

                    // Tangent angle

                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 20)
                        .position(x: x, y: y)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
    }
}
*/

enum textStyle {
    case largeTitle
    case title
    case label
    case labelSecondary
    case labelSecondaryBold
    case labelTertiary
    case labelTertiaryBold
    case labelBold
    case body
    case bodySecondary
    case caption
}



func getSystemColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.78, green: 0.8, blue: 0.97)
    //Color(red: 0.88, green: 0.82, blue: 0.72)
            : Color(red: 0.380, green: 0.325, blue: 0.231)
}


extension View {
    func foundationText(_ style: textStyle, color: Color? = nil) -> some View {
        self.modifier(FoundationText(style: style, color: color))
    }
}

struct FoundationText: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let style: textStyle
    var color: Color? = nil
    var systemDarkText = Color(red: 0.380, green: 0.325, blue: 0.231)
    var systemLightText = Color(red: 0.78, green: 0.8, blue: 0.97)
    //var systemLightText = Color(red: 0.88, green: 0.8, blue: 0.67)
    
    // Computed property to resolve the color with fallback
    private var systemColor: Color {
        color ?? (colorScheme == .light ? systemDarkText : systemLightText)
    }
    
    func body(content: Content) -> some View {
        switch style {
        case .largeTitle:
            content
                .font(.largeTitle)
                .foregroundStyle(systemColor)
                .fontWeight(.semibold)
            
        case .title:
            content
                .font(.title3)
                .foregroundStyle(systemColor)
                .fontWeight(.semibold)
            
        case .label:
            content
                .foregroundStyle(systemColor)
                .fontWeight(.semibold)
                .font(.callout)
        
        case .labelSecondary:
            content
                .foregroundStyle(systemColor)
                .fontWeight(.semibold)
                .font(.subheadline)
                
            
        case .labelSecondaryBold:
            content
                .foregroundStyle(systemColor)
                .fontWeight(.bold)
                .font(.subheadline)
            
        case .labelTertiary:
            content
                .foregroundStyle(systemColor)
                .fontWeight(.semibold)
                .font(.footnote)
            
        case .labelTertiaryBold:
            content
                .foregroundStyle(systemColor)
                .fontWeight(.bold)
                .font(.footnote)
            
        case .labelBold:
            content
                .foregroundStyle(systemColor)
                .fontWeight(.bold)
                .font(.callout)
            
        case .body:
            content
                .foregroundStyle(systemColor)
                .fontWeight(.semibold)
                .font(.callout)
            
        case .bodySecondary:
            content
                .foregroundStyle(systemColor)
                .fontWeight(.semibold)
                .font(.subheadline)
            
        case .caption:
            content
                .foregroundStyle(systemColor)
                .fontWeight(.semibold)
                .font(.headline)
        }
    }
}

struct FoundationBG: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View{
        ZStack(){
        Color(colorScheme == .light ? .white : Color(red: 0.067, green: 0.047, blue: 0.016))
            .ignoresSafeArea()
            .frame(height: 70)
        
        if colorScheme == .dark {
            ZStack(){
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "0C0F1C"), location: 0),
                        .init(color: Color(hex: "000003"), location: 0.60),
                        
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                ZStack(){
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.486, green: 0.3833, blue: 0.208, opacity: 1.0), location: 0.03),
                                .init(color: .black, location: 0.6),
                                
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .blur(radius: 30)
                        .opacity(1)
                        .frame(width: 80)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.546, green: 0.3833, blue: 0.208, opacity: 0.8), location: 0.03),
                                .init(color: .black, location: 0.6),
                                
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .blur(radius: 20)
                        .opacity(1)
                        .frame(width: 70)
                        .rotationEffect(.degrees(34), anchor: .top)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 60)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.506, green: 0.3833, blue: 0.268, opacity: 0.8), location: 0.03),
                                .init(color: .black, location: 0.6),
                                
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .blur(radius: 10)
                        .opacity(1)
                        .frame(width: 50)
                        .rotationEffect(.degrees(7), anchor: .top)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 100)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.456, green: 0.3533, blue: 0.288, opacity: 0.8), location: 0.03),
                                .init(color: .black, location: 0.6),
                                
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .blur(radius: 25)
                        .opacity(1)
                        .frame(width: 90)
                        .rotationEffect(.degrees(-8), anchor: .top)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 60)
                    
                }
                .padding(.top, -30)
                .opacity(0.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .blur(radius: 0)
        } else if colorScheme == .light {
            ZStack(){
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 1, green: 0.941, blue: 0.845), location: 0),
                        .init(color: Color(red: 1, green: 1, blue: 1, opacity: 0.0), location: 0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blur(radius: 17)
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.9, green: 0.77, blue: 0.5).opacity(0.3), location: 0),
                        .init(color: Color(red: 1, green: 1, blue: 1, opacity: 0.0), location: 0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .edgesIgnoringSafeArea(.all)
            //.frame(height: 700)
            
        }
    }
        .edgesIgnoringSafeArea(.all)
    }
}


// MARK: Toggle
struct ResponsiveToggle: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isOn: Bool = false
    @State private var isChanging: Bool = false
    @State private var selected: Bool = false
    var body: some View {
        
        ZStack() {
            ZStack(){
                ZStack() {
                    Capsule()
                        .fill(isOn ? Color(red: 1, green: 0.634, blue: 0.24) : Color(red: 0.898, green: 0.8, blue: 0.694))
                        .overlay(
                            Capsule()
                                .stroke(Color(isOn ? Color(red: 0.83, green: 0.55, blue: 0.28) : Color(red: 0.77, green: 0.65, blue: 0.594)),
                                        lineWidth: 4)
                                .shadow(color: Color(red: 0.8 ,green: 0.5, blue: 0).opacity(0.3), radius: 2, x: 0, y: 2)
                                .shadow(color: Color(.brown.opacity(0.3)), radius: 1, x: 0, y: 1)
                                .clipShape(
                                    Capsule()
                                )
                            
                        )
                }
                .frame(width: 65, height: 24)
                
                
                HStack(){
                    
                    if(isOn){
                        Spacer()
                    }
                    
                    ZStack(){
                        BoundingPrimitiveView(height: 0, radius: 100)
                        ZStack(){
                            Capsule()
                                .stroke(Color(isOn ? Color(red: 0.95, green: 0.634, blue: 0.24) : Color(red: 0.858, green: 0.75, blue: 0.644)),
                                        lineWidth: 3)
                                .clipShape(
                                    Capsule()
                                )
                                .blur(radius: 1)
                            Capsule()
                                .fill(isOn ? Color(red: 0.95, green: 0.634, blue: 0.24) : Color(red: 0.858, green: 0.75, blue: 0.644))
                                .frame(height: 22)
                                .padding(.leading, isOn ? 0 : 9)
                                .padding(.trailing, isOn ? 8 : 0)
                                .blur(radius: 2.4)

                        }
                            .opacity(selected ? 0.3 : isChanging ? 0.5 : 0)
                    }
                    .frame(width: selected ? 48 : isChanging ? 63 : 50, height: 32)
                    .scaleEffect(isChanging || selected ? 1.25 : 1)
                    .blur(radius: isChanging ? 2 : 0)
                        //.opacity(isChanging ? 0.6 : 1)
                    
                    if(!isOn){
                        Spacer()
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(width: 80, height: 20)
            
            Button(action: {withAnimation(.smooth(duration: 0.1)) { isOn.toggle()}; withAnimation(.smooth(duration: 0.34)) { isChanging.toggle()}}) {
                ZStack(){
                    Capsule()
                        .opacity(0.001)
                }
                .frame(width: 80, height: 30)
            }
            .buttonStyle(.plain)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                // pressing == true when the finger is down
                // pressing == false when the finger lifts
                withAnimation(.bouncy(duration: 0.4, extraBounce: 0.2)) {
                    selected = pressing
                }
            }, perform: {
            })
            .onChange(of: isOn) {

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.snappy(duration: 0.34, extraBounce: 0.12)) {
                            isChanging = false
                        }
                    }
                }
            
            
            
        }
        //.background(.red)
    }
}



struct ResponsiveSlider: View {
    @Binding var value: CGFloat   // 0.0 → 1.0
    let minVal: CGFloat
    let maxVal: CGFloat
    @State private var dragValue: CGFloat
    
    init(_ value: Binding<CGFloat>, _ minVal: CGFloat, _ maxVal: CGFloat) {
        self._value = value
        self.minVal = minVal
        self.maxVal = maxVal
        dragValue = (value.wrappedValue)/(maxVal-minVal)
    }
    
    @State private var isDragged: Bool = false
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width

            ZStack(alignment: .leading) {
                
                // Track
                Capsule()
                    .fill(Color(red: 0.898, green: 0.8, blue: 0.694))
                    .frame(height: 10)

                // Fill
                Capsule()
                    .fill(Color(red: 1, green: 0.634, blue: 0.24))
                    .frame(width: dragValue * width, height: 10)
                    .blur(radius: isDragged ? 1 : 0)

                // Thumb
                ZStack(){
                    BoundingPrimitiveView(height: 0, radius: 30)
                        //.opacity(0.3)
                    HStack(spacing: 0){
                        Capsule()
                            .fill(Color(red: 0.97, green: 0.634, blue: 0.24))
                            .background(Color(red: 0.898, green: 0.8, blue: 0.694))
                            
                        Rectangle()
                            .fill(Color(red: 0.868, green: 0.74, blue: 0.624))
                            
                    }
                    .clipShape(
                        Capsule()
                    )
                    .frame(height: 12)
                    .blur(radius: 3.6)
                    .opacity(isDragged && dragValue > 0.08 && dragValue < 0.92 ? 0.35 : 0)
                    .animation(.smooth(duration: 0.34), value: dragValue)
                }
                    
                    .scaleEffect(isDragged ? 1.24 : 1)
                    
                    .frame(width: 50, height: 34)
                    .offset(x: dragValue * width - (36*(0.4+0.5*dragValue)))
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                let x = drag.location.x
                                dragValue = max(0, min(1, x / width))
                                value = minVal+((maxVal-minVal)*dragValue)
                            }
                    )
                    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                        //print(dragValue)
                        // pressing == true when the finger is down
                        // pressing == false when the finger lifts
                        withAnimation(.bouncy(duration: 0.4, extraBounce: 0.2)) {
                            isDragged = pressing
                        }
                    }, perform: {
                    })
            }
        }
        .frame(height: 36)
    }
}

// MARK: Notes View

struct NotesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    //@Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Int = 0
    @State private var isPressed = false
    @State private var isPressed2 = false
    @State private var isPressed3 = false
    @State private var tabScale: CGFloat = 1.0
    @State private var showTab: Bool = true
    @State private var tabOpacity: Bool = true
    @State private var tabViewSelected: Int = 0 ///
    @State private var tabCapsuleScale: CGFloat = 1.0
    @State private var showAccountSheet = false //false
    @State private var topOfHome = true
    @State private var topOfMemories = true
    @State private var showHeaders = true
    @State private var tabMinimized: Bool = false
    @State private var contentPriority: Bool = false
   
    
    let composbrown = Color(red: 0.380, green: 0.325, blue: 0.231)
    
    var body: some View {
        ZStack(){
            ZStack() {
                
                if(true){
                    
                        NavigationStack {
                            VStack(alignment: .leading, spacing: 0) {
                                // Custom title at the top
                                ZStack(alignment: .topLeading) {
                                    // Background color for the top bar
                                    Color(colorScheme != .dark ? .white : .black)
                                        .ignoresSafeArea()
                                        .frame(height: 70)
                                    
                                    FoundationBG()
                                    
                                    ZStack(alignment: .top){
                                    ScrollView{
                                        LazyVStack(){
                                            Spacer()
                                                .frame(height: 73)
                                                .onScrollVisibilityChange(threshold: 0.3) { visible in
                                                    if(visible){
                                                        topOfHome = true
                                                    }
                                                    else{
                                                        topOfHome = false
                                                    }
                                                }
                                            // MARK: Tabs
                                            HStack(alignment: .bottom, spacing: 10){
                                                Button(action: { withAnimation(.bouncy()) { isPressed.toggle(); selectedTab = 0 } }) {
                                                    
                                                    
                                                    TabPillView(textContent: "Composites", selectedTab: selectedTab, tabID: 0)
                                                        .scaleEffect(isPressed ? 1.18 : 1.0)
                                                }
                                                .buttonStyle(.plain)
                                                .onChange(of: isPressed) { oldValue, newValue in
                                                    if newValue {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                            withAnimation(.bouncy(extraBounce: 0.2)) {
                                                                isPressed = false
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                Button(action: { withAnimation(.bouncy()) { isPressed2.toggle(); selectedTab = 1 } }) {
                                                    
                                                    TabPillView(textContent: "Quotes", selectedTab: selectedTab, tabID: 1)
                                                        .scaleEffect(isPressed2 ? 1.18 : 1.0)
                                                }
                                                .buttonStyle(.plain)
                                                .onChange(of: isPressed2) { oldValue, newValue in
                                                    if newValue {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                            withAnimation(.bouncy(extraBounce: 0.2)) {
                                                                isPressed2 = false
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 18)
                                            
                                            Spacer()
                                                .frame(height: 20)
                                            
                                            // MARK: Main Content
                                            VStack(alignment: .leading){
                                                if(selectedTab == 0){
                                                    VStack(spacing: 20) {
                                                        NavigationLink {
                                                            MemoryMap(showTab: $showTab)
                                                                .navigationBarHidden(true)
                                                            
                                                        } label: {
                                                            BoundingPrimitiveView(.plain, height: 200, radius: 26)
                                                                .padding(.horizontal, 18)
                                                        }
                                                        .simultaneousGesture(TapGesture().onEnded {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                                showTab = false
                                                            }
                                                            
                                                        })
                                                        //.navigationBarBackButtonHidden(true)
                                                        NavigationLink {
                                                            fullscreenLoaderView()
                                                                .navigationBarHidden(true)
                                                            
                                                        } label: {
                                                            BoundingPrimitiveView(.plain, height: 200, radius: 26)
                                                                .padding(.horizontal, 18)
                                                        }
                                                        .simultaneousGesture(TapGesture().onEnded {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                                showTab = false
                                                            }
                                                            
                                                        })
                                                        ResponsiveToggle()
                                                        BoundingPrimitiveView(.plain, height: 200, radius: 26)
                                                            .padding(.horizontal, 18)
                                                        BoundingPrimitiveView(.plain, height: 200, radius: 26)
                                                            .padding(.horizontal, 18)
                                                        Spacer()
                                                            .frame(height: 40)
                                                        ResponsiveSlider($tabCapsuleScale, 0, 2)
                                                            .padding(.horizontal, 60)
                                                        Spacer()
                                                            .frame(height: 40)
                                                        ResponsiveToggle()
                                                        
                                                        Spacer()
                                                            .frame(height: 200)
                                                        
                                                        //RectanglesOnOval()
                                                        
                                                    }
                                                    //.background(.red)
                                                    .transition(.move(edge: .leading))
                                                }
                                                else{
                                                    VStack(alignment: .center) {
                                                        BoundingPrimitiveView(height: 400, radius: 26)
                                                            .padding(.horizontal, 18)
                                                        
                                                        Spacer()
                                                            .frame(height: 25)
                                                        ResponsiveToggle()
                                                        Spacer()
                                                            .frame(height: 25)
                                                        ResponsiveToggle()
                                                    }
                                                    .transition(.move(edge: .trailing))
                                                }
                                                
                                            }
                                            .animation(.snappy, value: selectedTab)
                                            
                                        }
                                    }
                                    .mask(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: .clear, location: 0.05),
                                                .init(color: .black.opacity(1), location: 0.11),
                                                .init(color: .black.opacity(1), location: 0.85),
                                                .init(color: .clear, location: 1)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .ignoresSafeArea(edges: .bottom)
                                    )
                                    
                                    
                                        
                                }
                                }
                                .frame(maxHeight: .infinity, alignment: .top)
                                // List of navigation links
                                
                                
                            }
                            
                        }
                        .toolbar(.hidden, for: .navigationBar)
                    .ignoresSafeArea()
                    .frame(maxHeight: .infinity, alignment: .top)
                    .transition(.scale)
                    .scaleEffect(tabViewSelected == 0 ? 1 : 1.03, anchor: .bottom)
                    .opacity(tabViewSelected == 0 ? 1 : 0)
                    .blur(radius: tabViewSelected == 0 ? 0 : 10)
                    //.scaleEffect(isPressed3 ? 1.02 : 1.0)
                    
                    NavigationStack {
                        VStack(alignment: .leading, spacing: 0) {
                            // Custom title at the top
                            ZStack(alignment: .topLeading) {
                                // Background color for the top bar
                                
                                
                                //FoundationBG()
                                
                                //ScrollView{
                                ZStack(){
                                    //LazyVStack(){
                                        
                                    /*
                                        Spacer()
                                            .frame(height: 53)
                                            
                                        */
                                    MemoryView($contentPriority)
                                    
                                            .onScrollVisibilityChange(threshold: 0.3) { visible in
                                                if(visible){
                                                    topOfMemories = false
                                                }
                                                else{
                                                    topOfMemories = false
                                                }
                                            }
                                    // TODO: fix title texts
                                        /*
                                        Spacer()
                                            .frame(height: 6)
                                        
                                        ScrollView(.horizontal) {
                                            HStack(alignment: .bottom, spacing: 10){
                                                
                                                ZStack(alignment: .leading){
                                                    BoundingPrimitiveView(height: 80, radius: 26)
                                                    
                                                    Text("Activity Map")
                                                        .font(.callout)
                                                        .foregroundStyle(colorScheme == .light ? Color(.darkGray) : Color(.white))
                                                        .blendMode(.luminosity)
                                                        .fontWeight(.semibold)
                                                        .frame(maxHeight: .infinity, alignment: .bottom)
                                                        .padding(13)
                                                }
                                                .frame(width: 160, height: 80)
                                                
                                                ZStack(alignment: .leading){
                                                    BoundingPrimitiveView(height: 80, radius: 26)
                                                    
                                                    Text("Collections")
                                                        .font(.callout)
                                                        .foregroundStyle(colorScheme == .light ? Color(.darkGray) : Color(.white))
                                                        .blendMode(.luminosity)
                                                        .fontWeight(.semibold)
                                                        .frame(maxHeight: .infinity, alignment: .bottom)
                                                        .padding(13)
                                                }
                                                .frame(width: 160, height: 80)
                                                
                                                ZStack(alignment: .leading){
                                                    BoundingPrimitiveView(height: 80, radius: 26)
                                                    
                                                    Text("Lookback")
                                                        .font(.callout)
                                                        .foregroundStyle(colorScheme == .light ? Color(.darkGray) : Color(.white))
                                                        .blendMode(.luminosity)
                                                        .fontWeight(.semibold)
                                                        .frame(maxHeight: .infinity, alignment: .bottom)
                                                        .padding(13)
                                                }
                                                .frame(width: 160, height: 80)
                                                
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .frame(height: 115)
                                            .padding(.horizontal, 18)
                                            
                                        }
                                        .scrollTargetBehavior(.paging)
                                        .scrollIndicators(.never)
                                        
                                        Spacer()
                                            .frame(height: 5)
                                        // MARK: e321321
                                        
                                        
                                        VStack() {
                                            NavigationLink {
                                                MemoryMap(showTab: $isPressed)
                                                    .navigationBarHidden(true)
                                                
                                            } label: {
                                                BoundingPrimitiveView(height: 200, radius: 26)
                                                    .padding(.horizontal, 18)
                                            }
                                            .simultaneousGesture(TapGesture().onEnded {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                    showHeaders = false
                                                }
                                                
                                            })
                                            //.navigationBarBackButtonHidden(true)
                                            
                                        }
                                        
                                        BoundingPrimitiveView(height: 200, radius: 26)
                                            .padding(.horizontal, 18)
                                        BoundingPrimitiveView(height: 200, radius: 26)
                                            .padding(.horizontal, 18)
                                        BoundingPrimitiveView(height: 200, radius: 26)
                                            .padding(.horizontal, 18)
                                        
                                        Spacer()
                                            .frame(height: 300)
                                        */
                                        
                                    
                                }
                                .mask(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            //.init(color: .clear, location: 0.05),
                                            .init(color: .black.opacity(1), location: 0.11),
                                            .init(color: .black.opacity(1), location: 0.85),
                                            //.init(color: .clear, location: 1)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .ignoresSafeArea(edges: .all)
                                )
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                            // List of navigation links
                            
                            
                        }

                    }
                    .ignoresSafeArea()
                    .frame(maxHeight: .infinity, alignment: .top)
                    .transition(.scale)
                    .scaleEffect(tabViewSelected == 1 ? 1 : 1.03, anchor: .bottom)
                    .opacity(tabViewSelected == 1 ? 1 : 0)
                    .blur(radius: tabViewSelected == 1 ? 0 : 10)
                    
                    
                    VStack(){
                        Spacer()
                            .frame(height: 10)
                        HStack(alignment: .top){
                            ZStack(alignment: .topLeading){
                                ZStack(alignment: .topLeading){
                                    Text("Compositor")
                                        .foundationText(.largeTitle)
                                        .opacity(topOfHome ? 1 : 0)
                                        .blur(radius: topOfHome ? 0 : 5)
                                        .scaleEffect(topOfHome ? 1 : 0.9, anchor: .leading)
                                    VStack(alignment: .leading){
                                        Text("Home")
                                            .foundationText(.title)
                                        Text("Composites")
                                            .foundationText(.title)
                                            .opacity(0.6)
                                    }
                                    .opacity(topOfHome ? 0 : 1)
                                    .blur(radius: topOfHome ? 5 : 0)
                                    .scaleEffect(topOfHome ? 1.1 : 1, anchor: .leading)
                                }
                                .opacity(tabViewSelected == 0 ? 1 : 0)
                                .blur(radius: tabViewSelected == 0 ? 0 : 4)
                                .scaleEffect(tabViewSelected == 0 ? 1 : 0.9, anchor: .leading)
                                .animation(.smooth(duration: 0.4), value: topOfHome)
                                
                                ZStack(alignment: .topLeading){
                                    Text("Memories")
                                        .foundationText(.largeTitle)
                                        .opacity(topOfMemories ? 1 : 0)
                                        .blur(radius: topOfMemories ? 0 : 5)
                                        .scaleEffect(topOfMemories ? 1 : 0.9, anchor: .leading)
                                    VStack(alignment: .leading){
                                        Text("Memories")
                                            .foundationText(.title)
                                            
                                        
                                    }
                                    .opacity(topOfMemories ? 0 : 1)
                                    .blur(radius: topOfMemories ? 5 : 0)
                                    .scaleEffect(topOfMemories ? 1.1 : 1, anchor: .leading)
                                }
                                .opacity(tabViewSelected == 1 ? 1 : 0)
                                .blur(radius: tabViewSelected == 1 ? 0 : 4)
                                .scaleEffect(tabViewSelected == 1 ? 1 : 0.9, anchor: .leading)
                                .animation(.smooth(duration: 0.4), value: topOfMemories)
                            }
                            
                            .padding(.leading, 18)
                            
                            Spacer()
                            
                            Button() {
                                showAccountSheet = true
                            } label: {
                                profileImage()
                                    .frame(maxWidth: 45)
                                    //.shadow(color: colorScheme == .dark ? .black.opacity(0.15) : Color(red: 0.888, green: 0.78, blue: 0.634).opacity(0.7), radius: 12, y: 3)
                                    .padding(.trailing, 18)
                            }
                            .buttonStyle(.plain)
                            .sheet(isPresented: $showAccountSheet) {
                                MainAccountView()
                                    .presentationDetents([.large])
                                    .presentationCornerRadius(34)
                                    .interactiveDismissDisabled(true)
                            }
                            
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .opacity(tabScale == 1 && showHeaders ? 1 : 0)
                    .blur(radius: tabScale == 1 && showHeaders ? 0 : 6)
                    //.scaleEffect(tabScale == 1 && showTab ? 1 : 0.8)
                    .animation(.smooth(duration: 0.2), value: showHeaders)
                    
                }
            }
            .animation(.smooth, value: tabViewSelected)
                
            VStack() {
                Spacer()
                ZStack() {
                    
                        ZStack() {
                            BoundingPrimitiveView(height: 0, radius: 50)
                                .frame(maxWidth: !tabMinimized ? .infinity : 85, maxHeight: !tabMinimized ? .infinity : 30)
                                .onTapGesture {
                                    if(tabMinimized){
                                        tabMinimized = false
                                        // MARK: Maximize Tab View
                                    }
                                }
                                .onChange(of: tabViewSelected){
                                    if(tabViewSelected == 1){
                                        showHeaders = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8){
                                            if(tabViewSelected == 1 && false){
                                                tabMinimized = true
                                                // MARK: Auto Minimize Tab View
                                                
                                            }
                                        }
                                    }
                                    else{
                                        tabMinimized = false
                                        showHeaders = true
                                    }
                                }
                            // MARK: tap and recede
                                .onChange(of: tabMinimized){
                                    if(tabViewSelected == 1 && !tabMinimized && contentPriority){
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                            if(tabViewSelected == 1 && contentPriority){
                                                tabMinimized = true
                                            }
                                        }
                                    }
                                }
                                .onChange(of: contentPriority){
                                    print(contentPriority)
                                    tabMinimized = contentPriority
                                }
                                .onChange(of: tabViewSelected){
                                    if(tabViewSelected == 1 && contentPriority){
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                                            if(tabViewSelected == 1 && contentPriority){
                                                tabMinimized = true
                                            }
                                        }
                                    }
                                }
                            // MARK: end
                                .animation(.bouncy(extraBounce: 0.01), value: tabMinimized)

                            
                            HStack(){
                                if(tabViewSelected == 1) {
                                            Spacer()
                                        }
                                //bubble
                                ZStack(alignment: .center){
                                    RoundedRectangle(cornerRadius: 60)
                                        .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.32, blue: 0.48) : tabCapsuleScale > 1 ? Color(red: 1, green: 0.858, blue: 0.684) : Color(red: 0.986, green: 0.888, blue: 0.754))
//                                        .strokeBorder(
//                                                LinearGradient(
//                                                    colors: [
//                                                        Color.white,        // top-left
//                                                        Color.clear,       // mid
//                                                        Color.white       // bottom-right
//                                                    ],
//                                                    startPoint: .topLeading,
//                                                    endPoint: .bottomTrailing
//                                                ),
//                                                lineWidth: 1.2
//                                            )
//                                        .shadow(color: colorScheme == .dark ? .black.opacity(0.15) : Color(red: 0.928, green: 0.824, blue: 0.694).opacity(0.8), radius: 11, y: 3)
                                        .frame(maxWidth: .infinity, maxHeight: !tabMinimized ? .infinity : 20, alignment: .top)
                                        .padding(6)
                                        //.offset(x: 0, y: -10)
                                        
                                }
                                //.background(Color.red)
                                .frame(width: tabMinimized ? 54 : tabViewSelected == 0 ? 95 : 120)
                                .frame(maxHeight: !tabMinimized ? .infinity : 50)
                                //.frame(width: tabCapsuleScale > 1 ? 119 : 120)
                                //.frame(height: tabCapsuleScale > 1 ? 30 : .infinity)
                                
                                .animation(.snappy(duration: 0.3, extraBounce: 0.01), value: tabMinimized)

                                .opacity(isPressed3 ? 0.9 : tabCapsuleScale > 1 ? 0.7 : 1)
                                .blur(radius: tabCapsuleScale > 1 ? 2 : 0)
                                .scaleEffect(isPressed3 ? 1.1 : tabCapsuleScale)
                                .onChange(of: tabViewSelected) {  DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                                    withAnimation(.smooth(extraBounce: 0.4)) {
                                        tabCapsuleScale = 1.25
                                    }
                                }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                        withAnimation(.smooth(extraBounce: 0.5)) {
                                            tabCapsuleScale = 1
                                        }
                                    }
                                }
                                
                                if(tabViewSelected == 0) {
                                            Spacer()
                                        }
                                
                            }
                            .frame(maxWidth: !tabMinimized ? .infinity : 85)
                            .animation(.smooth, value: tabMinimized)
                            .animation(.smooth(duration: 0.3), value: tabViewSelected)
                            HStack(spacing: -16){
                                
                                Button(action: { withAnimation(.bouncy()) { isPressed3.toggle(); tabViewSelected = 0}}) {
                                    
                                    ZStack(alignment: .center){
                                            
                                        Text("Home")
                                            .foundationText(.label)
                                            .opacity(tabViewSelected == 1 ? 0.5 : 1)
                                            .padding(.vertical, 18)
                                            .padding(.horizontal, 20)
                                    }
                                    .frame(width: 95)
                                    .scaleEffect(isPressed3 && tabViewSelected == 0 ? 1.05 : 1.0)
                                }
                                .buttonStyle(.plain)
                                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                                    
                                    if isPressed3 {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.prepare()
                                            generator.impactOccurred(intensity: 0.6)
                                        }
                                    
                                    withAnimation(.smooth(duration: 0.3)) {
                                        isPressed3 = true
                                    }
                                }, perform: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                                        withAnimation(.smooth(extraBounce: 0.55)) {
                                            isPressed3 = false
                                            }
                                        }
                                })
                                .onChange(of: tabViewSelected) {  DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    withAnimation(.smooth(extraBounce: 0.55)) {
                                        isPressed3 = false
                                        }
                                    }
                                }
                                

                                Button(action: { withAnimation(.bouncy()) { isPressed3.toggle(); tabViewSelected = 1} }) {
                                    ZStack(alignment: .center){
                                        Text("Memories")
                                            .foundationText(.label)
                                            .opacity(tabViewSelected == 0 ? 0.5 : 1)
                                            .padding(.vertical, 18)
                                            .padding(.horizontal, 20)
                                    }
                                    .frame(width: 120)
                                    .scaleEffect(isPressed3 && tabViewSelected == 1 ? 1.05 : 1.0)
                                }
                                .buttonStyle(.plain)
                                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                                   
                                    if isPressed3 {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.prepare()
                                        generator.impactOccurred(intensity: 0.8)
                                        }
                                    
                                    withAnimation(.smooth(duration: 0.3)) {
                                        isPressed3 = true
                                    }
                                }, perform: {
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                                        withAnimation(.smooth(extraBounce: 0.55)) {
                                            isPressed3 = false
                                            }
                                        }
                                })
                            }
                            .opacity(tabMinimized ? 0 : 1)
                            .scaleEffect(tabMinimized ? 0.65 : 1)
                            .blur(radius: tabMinimized ? 3 : 0)
                            .animation(.bouncy(duration: tabMinimized ? 0.3 : 0.35), value: tabMinimized)
                        }
                        .fixedSize()
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                .scaleEffect(isPressed3 ? 1.05 : 1.0)
                .fixedSize()
                //.background(.red)
                .blur(radius: tabScale > 1.0 ? 4 : 0)
                .scaleEffect(tabScale, anchor: .center)
                .opacity(tabMinimized ? 0.7 : tabOpacity ? 1 : 0) // initially hidden during bounce
                .offset(x: 0, y: tabMinimized ? 12 : 0)
                .animation(.snappy(duration: 0.3), value: tabMinimized)
                
                .onChange(of: showTab) {
                    showHeaders.toggle()
                    // Bounce up
                    //withAnimation(.bouncy(duration: 0.3)) { tabScale = 1.0 }
                    
                    // Bounce back down
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                        withAnimation(.bouncy(duration: 0.44)) { tabScale = 1.05; tabOpacity.toggle()}
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.082) {
                        withAnimation(.snappy(duration: 0.16)) { tabScale = 1.18}
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                        withAnimation(.bouncy(duration: 0.44, extraBounce: 0.1)) { tabScale = 1.0}
                        
                        
                       
                    }
                }
                
                
            }
            .frame(maxWidth: .infinity)
            
        }
        .onAppear {
            DispatchQueue.main.async {
                // forces second layout pass
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}


/*
 struct NotesView: View {
     @State private var noteText: String = ""  // Editable text storage
     
     var body: some View {
         VStack() {
             HStack() {
                 Text("Notes")
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .font(.largeTitle)
                     .bold()
                     .padding([.top, .leading], 18)
                 
                 VStack() {
                     ShareLink(item: noteText) {
                         HStack {
                             Image(systemName: "square.and.arrow.up")
                                 .fontWeight(.bold)
                                 .foregroundStyle(Color(red: 0.412, green: 0.29, blue: 0.055))
                                 .imageScale(.medium)
                         }
                         .contentShape(Circle())
                         .fixedSize(horizontal: true, vertical: true)
                         .foregroundColor(.white)
                         .padding(14)
                         .background(Color(red: 1, green: 0.9, blue: 0.8))
                         .cornerRadius(40)
                         .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                         
                         
                     }
                     .padding(.horizontal, 18)
                     .padding(.top, 20)
                     
                 }
                 
             }
             
             TextEditor(text: $noteText)
                 .padding()
                 .font(.body)
                 .foregroundColor(.primary)
                 .background(Color(.systemBackground))
                 .ignoresSafeArea()  // Makes it stretch to full screen
         }
     }
 }
 */


// MARK: - Creation Sheet

struct MainAccountView: View {
    @State private var scale: CGFloat = 1.0
    @EnvironmentObject var profileData: ProfileData
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var currentPage: Int = 0
    
    @State private var showEditMenu: Bool = false
    @State private var showEditMenuContent: Bool = false
    
    @Query(sort: \Composite.sort, order: .forward)
    private var composites: [Composite]
    
    func deleteAllComposites() {
        for composite in composites {
            modelContext.delete(composite)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete all composites: \(error)")
        }
    }
    
    var body: some View {
        ZStack{
            NavigationView {
                ZStack(alignment: .center) {
                    // Background color for the top bar
                    FoundationBG()
                    VStack(){
                        ZStack() {
                            HStack() {
                                ZStack() {
                                    if(currentPage == 0) {
                                        ZStack() {
                                            Button() {
                                                dismiss()
                                            } label: {
                                                DefaultPillView(text: "Done", image: "", type: 0, padding: 20)
                                                
                                            }
                                            .padding(.horizontal, 15)
                                            
                                            .buttonStyle(.automatic)
                                        }
                                        
                                    }
                                    else{
                                        ZStack() {
                                            Button() {
                                                currentPage = 0
                                            } label: {
                                                DefaultPillView(text: " ", image: "arrow.left", type: 1, padding: 20)
                                            }
                                            .padding(.horizontal, 15)
                                            .buttonStyle(.automatic)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                .blur(radius: scale == 1.18 ? 2.2 : 0)
                                .animation(.snappy, value: currentPage)
                                .scaleEffect(scale, anchor: .center)
                                .onChange(of: currentPage) {
                                    withAnimation(.bouncy) { scale = 1.18 }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation(.bouncy) { scale = 1.0 }
                                    }
                                }
                                
                                
                                Spacer()
                                
                                ZStack(){
                                    
                                        Button(action: {
                                            if(currentPage == 1){
                                                showEditMenu = true
                                            }
                                        }) {
                                            DefaultPillView(text: currentPage == 1 ? "Edit" : "?", image: "", type: 0, padding: 20)
                                        }
                                        .padding(.horizontal, 15)
                                        .buttonStyle(.automatic)
                                        //.opacity(currentPage == 0 ? 0 : 1)
                                        .animation(.default, value: currentPage)
                                    
//                                    else if(currentPage == 1){
//                                        Button(action: {
//                                            showEditMenu = true
//                                        }) {
//                                            DefaultPillView(text: "Edit", image: "", type: 0, padding: 20)
//                                        }
//                                        .padding(.horizontal, 15)
//                                        .buttonStyle(.automatic)
//                                    }
//                                    else if(currentPage == 4){
//                                        Button(action: {
//                                            showEditMenu = true
//                                        }) {
//                                            DefaultPillView(text: "?", image: "", type: 0, padding: 20)
//                                        }
//                                        .padding(.horizontal, 15)
//                                        .buttonStyle(.automatic)
//                                    }
                                }
                                //.blur(radius: currentPage == 0 ? 4 : 0)
                                .animation(.snappy, value: currentPage)
                                .scaleEffect(currentPage <= 10 ? scale : 1, anchor: .center)
                                .onChange(of: currentPage) {
                                    
                                        withAnimation(.spring(bounce: 0.5)) { scale = 1.2 }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                            withAnimation(.spring(bounce: 0.5)) { scale = 1.0 }
                                        }
                                    
                                }
                                
                            }
                            if(currentPage == 1){
                                Text("You")
                                    .foundationText(.title)
                                    .transition(.blurReplace)
                            }
                            else if(currentPage == 2){
                                Text("Appearance")
                                    .foundationText(.title)
                                    .transition(.blurReplace)
                            }
                            else if(currentPage == 4){
                                Text("Notifications")
                                    .foundationText(.title)
                                    .transition(.blurReplace)
                            }
                            else if(currentPage == 0){
                                Text("Account & Settings")
                                    .foundationText(.title)
                                    .transition(.blurReplace)
                            }
                            
                        }
                        .padding(.top, 16)
                        
                        // MARK: - Content
                            if(currentPage == 0) {
                                
                                VStack(){
                                    
                                    Spacer()
                                        .frame(height: 10)
                                    ScrollView(){
                                        
                                        VStack(spacing: 26){
                                            
                                            ZStack(){
                                                Primativelist()
                                                    .item(title: "John Baller", subtitle: "Your account", icon: "triangle.rounded") {
                                                        currentPage = 1
                                                    }
                                                
                                                /*
                                                 NavigationLink {
                                                 ProfileView()
                                                 .navigationBarHidden(true)
                                                 
                                                 } label: {
                                                 Rectangle()
                                                 .opacity(0.001)
                                                 
                                                 }
                                                 */
                                                
                                            }
                                            
                                            
                                            Primativelist()
                                                .item(title: "What's new", subtitle: "Update 1.2", icon: "star.4") {
                                                    deleteAllComposites()
                                                }
                                            
                                            Primativelist(color: getSystemColor(colorScheme))
                                                .item(title: "Appearance", icon: "arrow.right") {
                                                    currentPage = 2;
                                                }
                                                .item(title: "Reflections", icon: "arrow.right") {
                                                    currentPage = 1;
                                                }
                                                .item(title: "Sounds & Haptics", icon: "arrow.right") {
                                                    currentPage = 1;
                                                }
                                                .item(title: "Notifications", icon: "arrow.right") {
                                                    currentPage = 4;
                                                }
                                                .item(title: "Widgets", icon: "arrow.right") {
                                                    currentPage = 1;
                                                }
                                                
                                            
                                            Primativelist(color: getSystemColor(colorScheme))
                                                .item(title: "About", icon: "arrow.right") {
                                                    currentPage = 1;
                                                }
                                                .item(title: "Donate", icon: "arrow.up.right") {
                                                    currentPage = 1;
                                                }
                                            
                                            
                                            Primativelist(color: getSystemColor(colorScheme))
                                                .item(title: "Privacy Policy", icon: "arrow.up.right") {
                                                    currentPage = 1;
                                                }
                                                .item(title: "Terms and Conditions", icon: "arrow.up.right") {
                                                    currentPage = 1;
                                                }
                                            
                                            Primativelist(color: getSystemColor(colorScheme))
                                                .item(title: "Erase all data", icon: "xmark") {
                                                    deleteAllComposites()
                                                    profileData.didCompleteOnboarding = false
                                                }

                                                
                                            
                                        }
                                    }
                                    
                                    
                                    
                                }
                                .frame(maxHeight: .infinity, alignment: .top)
                                .transition(.move(edge: .leading).combined(with: .blurReplace))

                            }
                        
                        //.opacity(currentPage != 0 ? 0 : 1)
                        //.blur(radius: currentPage != 0 ? 10 : 0)
                        //.background(Color.red)
                        //.scaleEffect(currentPage != 0 ? 0.88 : 1, anchor: .center)
                        
                        
                        else if(currentPage == 1){
                            VStack {
                                
                                ProfileView()
                                /*
                                 if compositeText.isEmpty {
                                 Text("Yes")
                                 .foregroundColor(.gray)
                                 .padding(.leading, 0)
                                 .padding(.top, 12)
                                 }
                                 
                                 TextEditor(text: $compositeText)
                                 .padding(.vertical, 10)
                                 .background(Color.blue)
                                 .scrollContentBackground(.hidden)
                                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                                 //.padding(.horizontal, 15)
                                 */
                                
                                /*
                                 VStack(spacing: 20) {
                                 
                                 Button("Hi i enjoy being a useless button") {
                                 dismiss()
                                 
                                 }
                                 .padding()
                                 .fontWeight(.bold)
                                 .background(Color.blue)
                                 .foregroundColor(.white)
                                 .cornerRadius(10)
                                 }
                                 .padding()
                                 */
                                
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        
                        else if(currentPage == 2) {
                            
                            VStack(){
                                
                                Spacer()
                                    .frame(height: 10)
                                ScrollView(){
                                    
                                    VStack(spacing: 26){
                                        
                                        
                                        
                                        Primativelist(color: getSystemColor(colorScheme))
                                            .item(title: "Notifications", accessory: .withToggle) {
                                                currentPage = 1;
                                            }
                                            
                                        
                                        Primativelist(color: getSystemColor(colorScheme))
                                            .item(title: "Notifications", accessory: .withToggle) {
                                                currentPage = 1;
                                            }
                                            .item(title: "Reduce motion", accessory: .withToggle) {
                                                currentPage = 1;
                                            }
                                            .item(title: "Reflections", accessory: .withToggle) {
                                                currentPage = 1;
                                            }
                                    }
                                }
                                
                                
                                
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        
                        else if(currentPage == 4) {
                            
                            VStack(){
                                
                                Spacer()
                                    .frame(height: 10)
                                ScrollView(){
                                    
                                    VStack(spacing: 26){
                                        
                                        
                                        
                                        Primativelist(color: getSystemColor(colorScheme))
                                            .item(title: "Notifications", accessory: .withToggle) {
                                                currentPage = 1;
                                            }
                                            
                                        
                                        Primativelist(color: getSystemColor(colorScheme))
                                            .item(title: "Notifications", accessory: .withToggle) {
                                                currentPage = 1;
                                            }
                                            .item(title: "Reduce motion", accessory: .withToggle) {
                                                currentPage = 1;
                                            }
                                            .item(title: "Reflections", accessory: .withToggle) {
                                                currentPage = 1;
                                            }
                                    }
                                }
                                
                                
                                
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        
                    }
                    .animation(.snappy(duration: 0.44), value: currentPage)
                    //.animation(.timingCurve(0.4, 0, 0.2, 1, duration: 0.5), value: currentPage)
                    
                }
            }
            //.brightness(showEditMenu ? -0.5 : 0)
            .animation(.linear(duration: 0.2), value: showEditMenu)
            
            ZStack(){
                //Color(.black)
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(.black))
                    .opacity(showEditMenu ? 0.7 : 0)
                    .ignoresSafeArea()
                    .animation(.snappy(duration: showEditMenu ? 0.4 : 0.2), value: showEditMenu)
                
                
                RoundedRectangle(cornerRadius: showEditMenuContent ? 0 : showEditMenu ? 140 : 200)
                    .fill(Color(.black))
                    
                    .opacity(showEditMenu ? 1 : 0)
                    //].offset(x: 0, y: showEditMenu ? 0 : 1000)
                    .scaleEffect(showEditMenu ? 1.23 : 0.05)
                    .edgesIgnoringSafeArea(.all)
                    .animation(.smooth(duration: showEditMenu ? 0.4 : 0.38), value: showEditMenu)
                    .animation(.smooth(duration: 0.3), value: showEditMenuContent)
                    .mask(
                        RoundedRectangle(cornerRadius: 0)

                    )
                //.padding(.vertical, showEditMenu ? 0 : 100)
                    .frame(maxHeight: showEditMenu ? .infinity : 480, alignment: .bottom)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: showEditMenuContent ? 0 : 10)
                    .animation(.snappy(duration: showEditMenu ? 0.33 : 0.3), value: showEditMenu)
                    .animation(.smooth(duration: 0.4), value: showEditMenuContent)

                   
                
                ProfileEditView()
                    //.frame(maxHeight: .infinity, alignment: .top)
                    .opacity(showEditMenuContent ? 1.0 : showEditMenu ? 0.01 : 0)
                    .scaleEffect(showEditMenuContent ? 1 : 0.7)
                    .blur(radius: showEditMenuContent ? 0 : 40)
                    .animation(.bouncy(duration: showEditMenu ? 0.35 : 0.15, extraBounce: 0), value: showEditMenuContent)
                    .animation(.smooth(duration: 0.33), value: showEditMenu)
                    //.background(.red)
                
                Button(action: {
                    showEditMenu.toggle()
                }) {
                    DefaultPillView(text: "", image: "checkmark", type: 1, padding: 20)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 7)
                        .padding(.trailing, 16)
                        .grayscale(1)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 10)
                
                    
            }
            //.background(.red)
            .opacity(showEditMenu ? 1 : 0)
            .animation(.smooth(duration: showEditMenu ? 0 : 0.9), value: showEditMenu)
            .onChange(of: showEditMenu){
                DispatchQueue.main.asyncAfter(deadline: .now() + (showEditMenu ? 0.15 : 0)){
                    showEditMenuContent.toggle()
                }
            }
            
            
        }
    }
}

// MARK: 051427

struct BoundingPrimitiveView: View {
    @Environment(\.colorScheme) var colorScheme
    let height: CGFloat?
    let radius: CGFloat
    let style: containerStyle
    
    init(_ style: containerStyle = .butter, height: CGFloat? = 0, radius: CGFloat) {
        self.style = style
        self.height = height
        self.radius = radius
    }
    
    var body: some View {
        switch style {
        case .butter:
            RoundedRectangle(cornerRadius: radius)
                .fill(colorScheme == .light
                    ? AnyShapeStyle(Color(red: 1, green: 0.955, blue: 0.89))
                    : AnyShapeStyle(LinearGradient(colors: [
                    Color(hex: "0F172D"),
                    Color(hex: "0F162C") ],
                    startPoint: .top, endPoint: .bottom)))
                .shadow(color: colorScheme == .dark ? .black.opacity(0.15) : Color(red: 0.928, green: 0.824, blue: 0.694).opacity(0.8), radius: 11, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .innerOuterStroke(
                            outerColor: colorScheme == .light ? Color(red: 0.878, green: 0.8, blue: 0.694).opacity(0.8) : .black.opacity(0.2),
                            outerWidth: 2.5,
                            outerBlend: .luminosity,
                            innerColor: colorScheme == .light ? .white : .gray.opacity(0.1),
                            innerWidth: 2,
                            innerBlend: .luminosity
                        )
                )
                .frame(height: height == 0 ? nil : height)
            
        case .plain:
            RoundedRectangle(cornerRadius: radius)
                .fill(colorScheme == .dark
                      ? Color(red: 0.04, green: 0.08, blue: 0.14)
                      : Color(red: 0.986, green: 0.888, blue: 0.754)
                )
                .frame(height: height == 0 ? nil : height)
        }
            //.padding(.horizontal, 18)
    }
}



struct TabPillView: View {
    @Environment(\.colorScheme) var colorScheme
    let textContent: String
    let selectedTab: Int
    let tabID: Int
    //let ContainerWidth: CGFloat
    
    var body: some View {
        ZStack(alignment:.leading){
            BoundingPrimitiveView(height: 0, radius: 26)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .opacity(selectedTab == tabID ? 1.0 : colorScheme == .light ? 0.6 : 0.4)
            Text(textContent)
                .foundationText(.bodySecondary)
                .padding(.horizontal, 18)
                .frame(maxHeight: .infinity, alignment: .center)
                .opacity(selectedTab == tabID ? 1.0 : 0.5)
                
        }
        .frame(height: 42)
        .fixedSize()
        //.background(Color.red)
    }
}

/*
 if true{
    return true
 }
 
*/

enum containerStyle {
    case butter
    case plain
        
    
}



#Preview {
    PreviewWrapper{
        NotesView()
    }
}


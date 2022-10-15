//
//  Home.swift
//  GlassMorphism
//
//  Created by Павел Курзо on 15.10.22.
//

import SwiftUI

struct Home: View {
    
    @State var blurView: UIVisualEffectView = .init()
    @State var defaultBlurRadius: CGFloat = 0
    @State var defaultSaturationAmount: CGFloat = 0
    
    @State var activateGlassMorphism: Bool = false
    
    var body: some View {
        
        ZStack {
            Color("BG")
                .ignoresSafeArea()
            
            Image("TopCircle")
                .offset(x: 150, y: -90)
            
            Image("BottomCircle")
                .offset(x: -150, y: 90)
            
            Image("CenterCircle")
                .offset(x: -40, y: -100)
            
            glassMorphicCard()
            
            Toggle("Activate Glass Morphism", isOn: $activateGlassMorphism)
                .font(.title3)
                .fontWeight(.semibold)
                .onChange(of: activateGlassMorphism) { newValue in
                    blurView.gaussianBlurRadius = (activateGlassMorphism ? 10 : defaultBlurRadius)
                    blurView.saturationAmount = (activateGlassMorphism ? 1.8 : defaultSaturationAmount)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(15)
        }
    }
    
    @ViewBuilder
    func glassMorphicCard() -> some View {
        ZStack {
            CustomBlurView(effect: .systemUltraThinMaterial) { view in
                blurView = view
                if defaultBlurRadius == 0 { defaultBlurRadius = view.gaussianBlurRadius }
                if defaultSaturationAmount == 0 { defaultSaturationAmount = view.saturationAmount }
            }
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    .linearGradient(colors: [
                        .white.opacity(0.25),
                        .white.opacity(0.05)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .blur(radius: 5)
            
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .stroke(
                    .linearGradient(colors: [
                        .white.opacity(0.6),
                        .clear,
                        .purple.opacity(0.2),
                        .purple.opacity(0.5)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 2
                )
        }
        .shadow(color: .black.opacity(0.15), radius: 5, x: -10, y: 10)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 10, y: -10)
        .overlay(content: {
            CardContent()
                .opacity(activateGlassMorphism ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: activateGlassMorphism)
        })
        .padding(.horizontal, 25)
        .frame(height: 220)
    }
    
    @ViewBuilder
    func CardContent() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MEMBERSHIP")
                    .modifier(CustomModifier(font: .callout))
                
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
            
            Spacer()
            
            Text("PAVEL KURZO")
                .modifier(CustomModifier(font: .title3))
            
            Text("BEREYZIAT")
                .modifier(CustomModifier(font: .callout))
            
        }
        .padding()
        .padding(.vertical, 10)
        .blendMode(.overlay)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct CustomModifier: ViewModifier {
    var font: Font
    func body(content: Content) -> some View {
        content
            .font(font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .kerning(1.2)
            .shadow(radius: 15)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomBlurView: UIViewRepresentable {
    var effect: UIBlurEffect.Style
    var onChange: (UIVisualEffectView) -> ()
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            onChange(uiView)
        }
    }
}

extension UIVisualEffectView {
    var backDrop: UIView? {
        return subView(forClass: NSClassFromString("_UIVisualEffectBackdropView"))
    }
    
    var gaussianBlur: NSObject? {
        return backDrop?.value(key: "filters", filter: "gaussianBlur")
    }
    
    var saturation: NSObject? {
        return backDrop?.value(key: "filters", filter: "colorSaturate")
    }
    
    var gaussianBlurRadius: CGFloat {
        get {
            return gaussianBlur?.values?["inputRadius"] as? CGFloat ?? 0
        }
        set {
            gaussianBlur?.values?["inputRadius"] = newValue
            applyNewEffects()
        }
    }
    
    func applyNewEffects() {
        UIVisualEffectView.animate(withDuration: 0.5) {
            self.backDrop?.perform(Selector(("applyRequestedFilterEffects")))
        }
    }
    
    var saturationAmount: CGFloat {
        get {
            return saturation?.values?["inputAmount"] as? CGFloat ?? 0
        }
        set {
            saturation?.values?["inputAmount"] = newValue
            applyNewEffects()
        }
    }
}

extension UIView {
    func subView(forClass: AnyClass?) -> UIView? {
        return subviews.first { view in
            type(of: view) == forClass
        }
    }
}

extension NSObject {
    var values: [String: Any]? {
        get {
            return value(forKeyPath: "requestedValues") as? [String: Any]
        }
        set {
            setValue(newValue, forKey: "requestedValues")
        }
    }
    
    func value(key: String, filter: String) -> NSObject? {
        (value(forKey: key) as? [NSObject])?.first(where: { obj in
            return obj.value(forKeyPath: "filterType") as? String == filter
        })
    }
}

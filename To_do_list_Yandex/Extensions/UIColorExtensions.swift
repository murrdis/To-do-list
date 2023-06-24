import UIKit

typealias HEX = String

extension UIColor {
    var hex: HEX? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        let alpha = Float(components[3])
        
        let hexString = String(
            format: "#%02lX%02lX%02lX%02lX",
            lroundf(red * 255),
            lroundf(green * 255),
            lroundf(blue * 255),
            lroundf(alpha * 255)
        )

        return hexString
    }
    
    convenience init?(hex: String){
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 8 {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
        let blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        let alpha = CGFloat(rgbValue & 0x000000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}


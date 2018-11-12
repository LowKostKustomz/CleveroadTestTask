import UIKit

private extension UIFont.Weight {
    var fontName: String {
        switch self {
        case .heavy:
            return ".SFUIText-Heavy"
        case .bold:
            return ".SFUIText-Bold"
        case .semibold:
            return ".SFUIText-Semibold"
        case .medium:
            return ".SFUIText-Medium"
        case .regular:
            return ".SFUIText"
        case .light:
            return ".SFUIText-Light"
        default:
            return UIFont.Weight.regular.fontName
        }
    }
}

extension UIFont {

    private class var scale: CGFloat {
        return UIFont.preferredFont(forTextStyle: .body).pointSize / 17
    }

    private class func font(for weight: UIFont.Weight, size: CGFloat = 17) -> UIFont {
        return UIFont(name: weight.fontName, size: size) ?? systemFont(ofSize: size, weight: weight)
    }

    private class func dynamicTypeFont(for weight: UIFont.Weight, textStyle: UIFont.TextStyle) -> UIFont {
        let pointSize = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle).pointSize
        let font = UIFont.font(for: weight, size: pointSize)
        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: font)
        } else {
            return font.withSize(scale * pointSize)
        }
    }

    class var heavy: UIFont {
        return font(for: .heavy)
    }

    class var bold: UIFont {
        return font(for: .bold)
    }

    class var semibold: UIFont {
        return font(for: .semibold)
    }

    class var medium: UIFont {
        return font(for: .medium)
    }

    class var regular: UIFont {
        return font(for: .regular)
    }

    class var light: UIFont {
        return font(for: .light)
    }
}

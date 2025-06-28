import UIKit

extension String {
    func attributed(
        font: UIFont = .systemFont(ofSize: UIFont.labelFontSize),
        color: UIColor? = nil
    ) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
        if let color { attributes[.foregroundColor] = color }
        return NSAttributedString(string: self, attributes: attributes)
    }
}

  
    import UIKit

    struct ReviewCellConfig {
        static let reuseId = String(describing: ReviewCellConfig.self)
        
        let reviewText: NSAttributedString
        let username: NSAttributedString
        let rating: Int
        let created: NSAttributedString
        let maxLines: Int
        
        fileprivate let layout = ReviewCellLayout()
    }

    extension ReviewCellConfig: TableCellConfig {
        func update(cell: UITableViewCell) {
            guard let cell = cell as? ReviewCell else { return }
            cell.usernameLabel.attributedText = username
            cell.ratingImageView.image = Self.ratingRenderer.ratingImage(rating)
            cell.reviewTextLabel.attributedText = reviewText
            cell.reviewTextLabel.numberOfLines = maxLines
            cell.createdLabel.attributedText = created
            cell.config = self
        }
        
        func height(with size: CGSize) -> CGFloat {
            layout.height(config: self, maxWidth: size.width)
        }
    }

    private extension ReviewCellConfig {
        static let ratingRenderer = RatingRenderer()
    }

    final class ReviewCell: UITableViewCell {
        fileprivate  var config: Config?
        
        fileprivate let avatarImageView = UIImageView()
        fileprivate let usernameLabel = UILabel()
        fileprivate let ratingImageView = UIImageView()
        fileprivate let reviewTextLabel = UILabel()
        fileprivate let createdLabel = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupCell()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            guard let layout = config?.layout else { return }
            avatarImageView.frame = layout.avatarFrame
            usernameLabel.frame = layout.usernameFrame
            ratingImageView.frame = layout.ratingFrame
            reviewTextLabel.frame = layout.reviewTextLabelFrame
            createdLabel.frame = layout.createdLabelFrame
        }
    }

    private extension ReviewCell {
        func setupCell() {
            selectionStyle = .none
            contentView.addSubview(avatarImageView)
            contentView.addSubview(usernameLabel)
            contentView.addSubview(ratingImageView)
            contentView.addSubview(reviewTextLabel)
            contentView.addSubview(createdLabel)
            
            // Avatar setup
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .lightGray
            avatarImageView.contentMode = .scaleAspectFit
            avatarImageView.layer.cornerRadius = Layout.avatarCornerRadius
            avatarImageView.clipsToBounds = true
            
            // Username setup
            usernameLabel.numberOfLines = 1
            
            // Rating setup
            ratingImageView.contentMode = .left
            
            // Review text setup
            reviewTextLabel.lineBreakMode = .byWordWrapping
            reviewTextLabel.numberOfLines = 0
        }
    }

    final class ReviewCellLayout {
        fileprivate static let avatarSize = CGSize(width: 36, height: 36)
        fileprivate static let avatarCornerRadius = 18.0
        fileprivate static let ratingSize = CGSize(width: 84, height: 16)
        
        private(set) var avatarFrame = CGRect.zero
        private(set) var usernameFrame = CGRect.zero
        private(set) var ratingFrame = CGRect.zero
        private(set) var reviewTextLabelFrame = CGRect.zero
        private(set) var createdLabelFrame = CGRect.zero
        
        private let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        private let avatarToTextSpacing: CGFloat = 12
        private let usernameToRatingSpacing: CGFloat = 4
        private let ratingToTextSpacing: CGFloat = 8
        private let textToCreatedSpacing: CGFloat = 8
        
        fileprivate func height(config: Config, maxWidth: CGFloat) -> CGFloat {
            let contentWidth = maxWidth - insets.left - insets.right
            
            // Avatar frame
            avatarFrame = CGRect(
                origin: CGPoint(x: insets.left, y: insets.top),
                size: Self.avatarSize
            )
            
            // Username frame
            let usernameWidth = contentWidth - Self.avatarSize.width - avatarToTextSpacing
            let usernameSize = config.username.boundingRect(width: usernameWidth).size
            usernameFrame = CGRect(
                x: avatarFrame.maxX + avatarToTextSpacing,
                y: avatarFrame.minY,
                width: usernameWidth,
                height: usernameSize.height
            )
            
            // Rating frame
            ratingFrame = CGRect(
                x: usernameFrame.minX,
                y: usernameFrame.maxY + usernameToRatingSpacing,
                width: Self.ratingSize.width,
                height: Self.ratingSize.height
            )
            
            // Calculate top section height
            let topSectionHeight = max(
                avatarFrame.maxY,
                ratingFrame.maxY
            )
            
            var currentY = topSectionHeight + ratingToTextSpacing
            
            // Review text frame
            if !config.reviewText.isEmpty() {
                let textHeight = config.reviewText.boundingRect(width: contentWidth).height
                reviewTextLabelFrame = CGRect(
                    x: insets.left,
                    y: currentY,
                    width: contentWidth,
                    height: textHeight
                )
                currentY = reviewTextLabelFrame.maxY + textToCreatedSpacing
            }
            
            // Created time frame
            let createdSize = config.created.boundingRect(width: contentWidth).size
            createdLabelFrame = CGRect(
                x: insets.left,
                y: currentY,
                width: contentWidth,
                height: createdSize.height
            )
            
            return createdLabelFrame.maxY + insets.bottom
        }
    }

    fileprivate typealias Config = ReviewCellConfig
    fileprivate typealias Layout = ReviewCellLayout


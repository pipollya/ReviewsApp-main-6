 
    import UIKit

    final class ReviewsViewModel: NSObject {
        var onStateChange: ((State) -> Void)?
        
        private var state: State
        private let reviewsProvider: ReviewsProvider
        private let decoder: JSONDecoder
        
        init(
            state: State = State(),
            reviewsProvider: ReviewsProvider = ReviewsProvider(),
            decoder: JSONDecoder = JSONDecoder()
        ) {
            self.state = state
            self.reviewsProvider = reviewsProvider
            self.decoder = decoder
        }
    }

    extension ReviewsViewModel {
        typealias State = ReviewsViewModelState
        
        func getReviews() {
            guard state.shouldLoad else { return }
            state.shouldLoad = false
            reviewsProvider.getReviews(offset: state.offset, completion: gotReviews)
        }
    }

    private extension ReviewsViewModel {
        func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
            do {
                let data = try result.get()
                let reviews = try decoder.decode(Reviews.self, from: data)
                state.items += reviews.items.map(makeReviewItem)
                state.offset += state.limit
                state.shouldLoad = state.offset < reviews.count
            } catch {
                state.shouldLoad = true
            }
            onStateChange?(state)
        }
    }

    extension ReviewsViewModel {
        typealias ReviewItem = ReviewCellConfig
        
        func makeReviewItem(_ review: Review) -> ReviewItem {
            let username = "\(review.firstName) \(review.lastName)".attributed(font: .username)
            let reviewText = review.text.attributed(font: .text)
            let created = review.created.attributed(font: .created, color: .created)
            
            return ReviewItem(
                reviewText: reviewText,
                username: username,
                rating: review.rating,
                created: created,
                maxLines: 3
            )
        }
    }

    extension ReviewsViewModel: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            state.items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let config = state.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
            config.update(cell: cell)
            return cell
        }
    }

    extension ReviewsViewModel: UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            state.items[indexPath.row].height(with: tableView.bounds.size)
        }
        
        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
                getReviews()
            }
        }
        
        private func shouldLoadNextPage(
            scrollView: UIScrollView,
            targetOffsetY: CGFloat,
            screensToLoadNextPage: Double = 2.5
        ) -> Bool {
            let viewHeight = scrollView.bounds.height
            let contentHeight = scrollView.contentSize.height
            let triggerDistance = viewHeight * screensToLoadNextPage
            let remainingDistance = contentHeight - viewHeight - targetOffsetY
            return remainingDistance <= triggerDistance
        }
    }


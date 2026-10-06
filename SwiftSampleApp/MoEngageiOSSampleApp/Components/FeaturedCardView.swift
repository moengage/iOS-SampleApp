//
//  FeaturedCardView.swift
//  MoEngageiOSSampleApp
//
//  UIKit port of MoEngageiOSSwiftUISampleApp/Components/FeaturedCard.swift.
//  One cell of the menu's featured grid: an image banner over the name, note
//  and price.
//

import UIKit

final class FeaturedCardView: UIControl {

    private let imageView = UIImageView()

    init(item: MenuItem) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BrewColor.surface
        layer.cornerRadius = BrewCorner.card
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = BrewColor.borderSubtle.cgColor
        clipsToBounds = true

        imageView.image = UIImage(named: item.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = BrewColor.neutralFill
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = item.name
        nameLabel.apply(.bodyMedium, color: BrewColor.textPrimary)
        nameLabel.numberOfLines = 1

        let noteLabel = UILabel()
        noteLabel.text = item.note
        noteLabel.apply(.micro, color: BrewColor.textSecondary)
        noteLabel.numberOfLines = 2

        let priceLabel = UILabel()
        priceLabel.text = rupees(item.price)
        priceLabel.apply(.bodyBold, color: BrewColor.textPrimary)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, noteLabel, priceLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.isUserInteractionEnabled = false
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(textStack)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1 / BrewSize.featuredImageAspect),

            textStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])

        isAccessibilityElement = true
        accessibilityLabel = "\(item.name), \(item.note), \(rupees(item.price))"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

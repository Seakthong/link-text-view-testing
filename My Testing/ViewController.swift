//
//  ViewController.swift
//  My Testing
//
//  Created by Seakthong Aing on 9/10/21.
//

import UIKit
import SwiftSoup

class ViewController: UIViewController {
    @IBOutlet var linkTextView: LinkTextView!
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let str = "<p>Are you looking for a program which supports your dream home, personal need and unsecured credit card in one package? Sathapana Bank is here to make your dream come to reality.</p>\n<p>Choose Flexi Lending program with</p>\n<p>• Competitive interest rate</p>\n<p>• Loan amount up to 85%</p>\n<p>• Tenure up to 25 years</p>\n<p>• Easy application process </p>\n<p>• <a href=\"https://www.sathapana.com.kh/minio/user_upload/Loans/Flexi_Lending/URL_Link_-_Lending_Program_Website_Content_EN.pdf\" target=\"_self\">URL link Program Features PDF File ENG Version</a></p>\n"
        do {
            let html = str
            let doc: Document = try SwiftSoup.parseBodyFragment(html)
            doc.outputSettings().prettyPrint(pretty: true)
            let me = try doc.text(trimAndNormaliseWhitespace: false)
            let link = try doc.select("a").first()
            let linkHref = try link?.attr("href") ?? "" // Get URL
            let linkText = try link?.text() ?? ""

//            let tu = "Terms of Use"
//            let pp = "Privacy Policy"
//            linkTextView.text = "Please read the Some Company \(tu) and \(pp)"
            linkTextView.text = me

            linkTextView.addLinks([
                linkText: linkHref
//                    tu: "https://some.com/tu",
//                    pp: "https://some.com/pp"
                ])
            linkTextView.onLinkTap = { url in
                    print("url: \(url)")
                    return true
                }
        } catch Exception.Error(let type, let message) {
            print(type, message)
        } catch {
            print("error")
        }
        textViewHeightConstraint.constant = self.linkTextView.contentSize.height

    }


}

class LinkLabel: UILabel {}

class LinkTextView: UITextView, UITextViewDelegate {

    typealias Links = [String: String]

    typealias OnLinkTap = (URL) -> Bool
    
    func adjustUITextViewHeight() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
        self.isScrollEnabled = false
    }

    var onLinkTap: OnLinkTap?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        isEditable = false
        isSelectable = true
        isScrollEnabled = false //to have own size and behave like a label
        delegate = self
        adjustUITextViewHeight()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func addLinks(_ links: Links) {
        guard attributedText.length > 0  else {
            return
        }
        let mText = NSMutableAttributedString(attributedString: attributedText)
        
        for (linkText, urlString) in links {
            if linkText.count > 0 {
                let linkRange = mText.mutableString.range(of: linkText)
                mText.addAttribute(.link, value: urlString, range: linkRange)
            }
        }
        attributedText = mText
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return onLinkTap?(URL) ?? true
    }

    // to disable text selection
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}

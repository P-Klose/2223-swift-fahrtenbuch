import Foundation
import CarPlay

@objc class ExampleCarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    
    private var interfaceController: CPInterfaceController?
    private var savedTabBarTemplate: CPTabBarTemplate?
    
    // https://developer.apple.com/documentation/carplay/displaying_content_in_carplay
    // CarPlay calls this function to initialize the scene.
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        // Save the interface controller
        self.interfaceController = interfaceController
        
        let template = tabBarTemplate()
        self.savedTabBarTemplate = template
        
        // Create the root template (screen) and install it at the root of the navigation hierarchy.
        interfaceController.setRootTemplate(template, animated: true, completion: nil)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }

    private func tabBarTemplate() -> CPTabBarTemplate {
        return CPTabBarTemplate(templates: [
            listTemplate(),
            informationTemplate(layout: .leading),
            pointOfInterestTemplate(),
        ])
    }
    
    private func replaceTabs() {
        self.savedTabBarTemplate?.updateTemplates([
            listTemplate(),
            informationTemplate(layout: .leading),
            informationTemplate(layout: .leading),
        ])
    }

    private func listTemplate() -> CPListTemplate {
        let template = CPListTemplate(
            title: "List Title",
            sections: [
                CPListSection(items: [
                    listItem(),
                    listItem(),
                    listItem(),
                    listItem(),
                    listItem(),
                    listItem(),
                    listItem(),
                ], header: "First Section", sectionIndexTitle: nil),
                CPListSection(items: [
                    listItem(),
                    listItem(),
                ], header: "Second Section", sectionIndexTitle: nil)

            ]
        )
        template.tabTitle = "List"
        template.tabImage = Assets.roundIconImage

        return template
    }
    
    private func listItem() -> CPListTemplateItem {
        let item = CPListItem(text: "Text", detailText: "Detail Text", image: Assets.roundIconImage, accessoryImage: nil, accessoryType: .none)
        
        item.handler = { [weak self] (item, completion) in
            guard let self = self else {
                completion()
                return
            }
            
            self.interfaceController?.pushTemplate(
                self.listTemplate(),
                animated: true,
                completion: { (didPresent, error) in
                    completion()
                }
            )
        }
        
        return item
    }
    
    private func informationTemplate(layout: CPInformationTemplateLayout) -> CPInformationTemplate {
        let template = CPInformationTemplate(
            title: "Information Title",
            layout: layout,
            items: [
                CPInformationItem(title: "Item\nTitle\nThird\nFourth", detail: "Item\nDetail\nThird line\nFourth line"),
                CPInformationItem(title: "Item Title", detail: nil),
                CPInformationItem(title: "Item Title", detail: "Item Detail"),
                CPInformationItem(title: "Item Title", detail: nil),
                CPInformationItem(title: "Item Title Item Title Item Title Item Title Item Title", detail: "Item Detail Item Detail Item Detail Item Detail Item Detail "),
                CPInformationItem(title: "Item Title", detail: nil),
            ],
            actions: [
                textButton(style: .confirm),
                textButton(style: .normal),
//                textButton(style: .cancel),
            ]
        )
        template.tabTitle = "Information"
        template.tabImage = Assets.roundIconImage

        return template
    }
    
    private func textButton(style: CPTextButtonStyle) -> CPTextButton{
        return CPTextButton(
            title: "Text Button",
            textStyle: style,
            handler: { [weak self] button in
                guard let self = self else { return }
                self.interfaceController?.pushTemplate(
                    self.informationTemplate(layout: .twoColumn),
                    animated: true,
                    completion: nil
                )
            }
        )
    }

    private func pointOfInterestTemplate() -> CPPointOfInterestTemplate {
        let template = CPPointOfInterestTemplate(
            title: "", //"Point of Interest Title",
            pointsOfInterest: [
//                pointOfInterest(withDetails: true),
//                pointOfInterest(withDetails: false),
//                pointOfInterest(withDetails: true),
//                pointOfInterest(withDetails: false),
//                pointOfInterest(withDetails: true),
//                pointOfInterest(withDetails: false),
//                pointOfInterest(withDetails: true),
//                pointOfInterest(withDetails: false),
//                pointOfInterest(withDetails: true),
//                pointOfInterest(withDetails: false),
            ],
            selectedIndex: NSNotFound
        )
        template.tabTitle = "Map"
        template.tabImage = UIImage(systemName: "map.fill")

        return template
    }
    
    private func pointOfInterest(withDetails: Bool) -> CPPointOfInterest {
        return CPPointOfInterest(
            location: MKMapItem(
                placemark: MKPlacemark(
                    coordinate: CLLocationCoordinate2D(
                        latitude: Double.random(in: 33.833 ... 36.583),
                        longitude: Double.random(in: -84.317 ... -75.467)
                    )
                )
            ),
            title: "Point of Interest Title",
            subtitle: "Subtitle",
            summary: "Summary summary summary.",
            detailTitle: withDetails ? "Detail Title" : nil,
            detailSubtitle: withDetails ? "Detail Subtitle" : nil,
            detailSummary: withDetails ? "Detail summary summary summary." : nil,
            pinImage: Assets.roundIconImage
        )
    }

//    private func actionSheetTemplate() -> CPActionSheetTemplate {
//    }

//    private func alertTemplate() -> CPAlertTemplate {
//    }
    
}

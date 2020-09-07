import HTMLKit

extension ContentNode {
    var singleColumn: Div {
        Div {
            Div {
                self
            }.class("column")
        }.class("row")
    }
}

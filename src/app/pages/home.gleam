import lustre/attribute.{class}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h1}

pub fn root() -> Element(t) {
  div([class("page-title-container")], [
    h1([class("font-gothic")], [text("Homepage")]),
  ])
}

import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn layout(elements: List(Element(t))) -> Element(t) {
  html.html([], [
    html.head([], [
      html.title([], "Project Zero"),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/styles.css"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/fonts.css"),
      ]),
      html.link([
        attribute.rel("apple-touch-icon"),
        attribute.sizes("180x180"),
        attribute.href("/static/apple-touch-icon.png"),
      ]),
      html.link([
        attribute.rel("icon"),
        attribute.type_("img/png"),
        attribute.sizes("32x32"),
        attribute.href("/static/favicon-32x32.png"),
      ]),
      html.link([
        attribute.rel("icon"),
        attribute.type_("img/png"),
        attribute.sizes("16x16"),
        attribute.href("/static/favicon-16x16.png"),
      ]),
    ]),
    html.body([attribute.id("app")], elements),
  ])
}

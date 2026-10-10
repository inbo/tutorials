this_url = nil
this_lang = nil
entitycolours = nil

function is_empty(s)
  return s == nil or s == ''
end

function Meta(meta)
  this_url = pandoc.utils.stringify(meta.translation.url)
  this_lang = pandoc.utils.stringify(meta.lang)
  entitycolours = meta.entitycolours
end

function Header(elem)
  if not is_empty(this_lang) and elem.level == 1 and this_url then
    local url_div = pandoc.Div({pandoc.Para({pandoc.Str(this_url)})}, pandoc.Attr("", {"sidebar-url-tussen"}))
    ent_logo = pandoc.Div("", { class = "entity-tussen" })
    if (this_lang == "nl-BE") then
      if (entitycolours == "inbo") then
        vl_logo = pandoc.Image("Vlaanderen is wetenschap", "flanders-nl-transparent.png")
        ent_logo = pandoc.Image("Instituut voor Natuur- en Bosonderzoek", "inbo-nl-white.png")
        ent_logo.attr = {class = "entity-tussen"}
      else
        vl_logo = pandoc.Image("Vlaanderen, verbeelding werkt", "flanders-nl-intermediate.jpg")
      end
      vl_logo.attr = {class = "vl-tussen"}
    else
      if (entitycolours == "inbo") then
        ent_logo = pandoc.Image("Instituut voor Natuur- en Bosonderzoek", "inbo-en-white.png")
        ent_logo.attr = {class = "entity-tussen-vert"}
      end
      vl_logo = pandoc.Image("Flanders, state of the art", "flanders-en-intermediate.png")
      vl_logo.attr = {class = "vl-tussen-vert"}
    end
    return {
      elem, pandoc.Div("", { class = "trapezium" }),
      pandoc.Div("", { class = "sidebar-tussen" }), vl_logo, ent_logo, url_div
    }
  elseif not is_empty(this_lang) and elem.level == 2 then
    if (this_lang == "nl-BE") then
      if (entitycolours == "inbo") then
        vl_logo = pandoc.Image("Vlaanderen is wetenschap", "flanders-nl-title.png")
      else
        vl_logo = pandoc.Image("Vlaanderen is wetenschap", "flanders-nl-slide.jpg")
      end
    else
      vl_logo = pandoc.Image("Vlaanderen is wetenschap", "flanders-en-slide.png")
    end
    vl_logo.attr = {class = "vl-slide"}
    return {elem, vl_logo}
  end
  return elem
end

function Pandoc(doc)
  Meta(doc.meta)
  doc.blocks = pandoc.walk_block(pandoc.Div(doc.blocks), {
    Header = Header
  }).content
  return doc
end

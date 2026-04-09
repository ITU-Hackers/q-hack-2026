#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let P = (
  bg:    rgb("#FFFFFF"),
  fg:    rgb("#585550"),
  dim:   rgb("#787570"),
  brand: rgb("#E1171E"),
  fe:    rgb("#34D399"),
  api:   rgb("#EBAF14"),
  ml:    rgb("#A78BFA"),
  db:    rgb("#40A5DA"),
  ext:   rgb("#F472B6"),
)

#set page(
  paper: "presentation-16-9",
  fill:  P.bg,
  margin: (x: 44pt, top: 32pt, bottom: 24pt),
)
#set text(font: ("Helvetica Neue", "Helvetica", "Arial"), fill: P.fg, size: 10pt)

#align(center)[
  #fletcher.diagram(
    node-stroke: none,
    node-corner-radius: 7pt,
    node-fill: none,
    edge-stroke: 1pt + P.fg.transparentize(62%),
    spacing: (52pt, 30pt),

    node(
      (0, 0),
      align(center)[
        #text(size: 18pt)[📱]
        #linebreak()
        #text(weight: "bold", size: 10pt)[Mobile User]
      ],
      name:   <user>,
      fill:   P.dim.transparentize(88%),
      stroke: 1.2pt + P.dim,
      width:  96pt,
      height: 48pt,
    ),

    node(
      (0, 1.3),
      align(center)[
        #text(weight: "bold", size: 11pt, fill: P.fe)[picky-app]
        #linebreak()
        #text(size: 8pt, fill: P.dim)[Next.js 16 · App Router · PWA]
        #linebreak()
        #text(size: 7.5pt, fill: P.dim.lighten(10%))[Browse · Cart · Profile]
      ],
      name:   <app>,
      fill:   P.fe.transparentize(88%),
      stroke: 1.6pt + P.fe,
      width:  210pt,
      height: 50pt,
    ),

    node(
      (0, 2.8),
      align(center)[
        #text(weight: "bold", size: 11pt, fill: P.api)[picky-api]
        #linebreak()
        #text(size: 8pt, fill: P.dim)[Rust · Axum · REST + AI Chat Agent (RAG)]
        #linebreak()
        #text(size: 7.5pt, fill: P.dim.lighten(10%))[/recipes · /recommend · /chat · /profile]
      ],
      name:   <api>,
      fill:   P.api.transparentize(88%),
      stroke: 1.6pt + P.api,
      width:  210pt,
      height: 50pt,
    ),

    node(
      (2.0, 2.8),
      align(center)[
        #text(weight: "bold", size: 10pt, fill: P.ext)[LLM]
        #linebreak()
        #text(size: 7.5pt, fill: P.dim)[OpenAI]
        #linebreak()
        #text(size: 7pt, fill: P.dim.lighten(10%))[completions + embeddings]
      ],
      name:   <llm>,
      fill:   P.ext.transparentize(88%),
      stroke: 1.2pt + P.ext,
      width:  100pt,
      height: 48pt,
    ),

    node(
      (-2.0, 2.8),
      align(center)[
        #text(weight: "bold", size: 10pt, fill: P.ml)[ONNX Runtime]
        #linebreak()
        #text(size: 7.5pt, fill: P.dim)[User-Tower Inference]
        #linebreak()
        #text(size: 7pt, fill: P.dim.lighten(10%))[128 → 100-dim embedding]
      ],
      name:   <onnx>,
      fill:   P.ml.transparentize(88%),
      stroke: 1.2pt + P.ml,
      width:  100pt,
      height: 48pt,
    ),

    node(
      (-1.5, 4.4),
      align(center)[
        #text(weight: "bold", size: 10pt, fill: P.db)[PostgreSQL]
        #linebreak()
        #text(size: 7.5pt, fill: P.dim)[users · recipes · metrics]
      ],
      name:   <pg>,
      fill:   P.db.transparentize(88%),
      stroke: 1.2pt + P.db,
      width:  100pt,
      height: 40pt,
    ),

    node(
      (0, 4.4),
      align(center)[
        #text(weight: "bold", size: 10pt, fill: P.db)[Qdrant]
        #linebreak()
        #text(size: 7.5pt, fill: P.dim)[recipe vectors · food2vec (100-d)]
      ],
      name:   <qdrant>,
      fill:   P.db.transparentize(88%),
      stroke: 1.2pt + P.db,
      width:  116pt,
      height: 40pt,
    ),

    node(
      (1.5, 4.4),
      align(center)[
        #text(weight: "bold", size: 10pt, fill: P.db)[MinIO / S3]
        #linebreak()
        #text(size: 7.5pt, fill: P.dim)[ONNX model artefacts]
      ],
      name:   <minio>,
      fill:   P.db.transparentize(88%),
      stroke: 1.2pt + P.db,
      width:  100pt,
      height: 40pt,
    ),

    node(
      (0, 5.8),
      align(center)[
        #text(weight: "bold", size: 11pt, fill: P.ml)[picky-recs]
        #linebreak()
        #text(size: 8pt, fill: P.dim)[Python · Dagster · ML Pipelines]
        #linebreak()
        #text(size: 7.5pt, fill: P.dim.lighten(10%))[recipe embedding · user-tower training (sklearn → ONNX)]
      ],
      name:   <recs>,
      fill:   P.ml.transparentize(88%),
      stroke: 1.6pt + P.ml,
      width:  250pt,
      height: 50pt,
    ),

    edge(<user>, <app>, "->",
      stroke: 1.2pt + P.fg.transparentize(40%),
    ),

    edge(<app>, <api>, "->",
      stroke: 1.2pt + P.fg.transparentize(40%),
      label: text(size: 7pt, fill: P.dim)[REST / HTTP],
      label-side: right,
    ),

    edge(<api>, <llm>, "->",
      label: text(size: 7pt, fill: P.dim)[RAG / Chat],
      label-side: right,
    ),

    edge(<api>, <onnx>, "->",
      label: text(size: 7pt, fill: P.dim)[inference],
      label-side: left,
    ),

    edge(<api>, <pg>, "->",
      label: text(size: 6.5pt, fill: P.dim)[SQL],
      label-side: left,
    ),

    edge(<api>, <qdrant>, "->",
      label: text(size: 6.5pt, fill: P.dim)[ANN search],
      label-side: right,
    ),

    edge(<api>, <minio>, "->",
      label: text(size: 6.5pt, fill: P.dim)[model poll],
      label-side: right,
    ),

    edge(<recs>, <pg>, "->",
      stroke: (paint: P.ml.transparentize(40%), dash: "dashed"),
      label: text(size: 6.5pt, fill: P.ml.lighten(20%))[read],
      label-side: left,
    ),

    edge(<recs>, <qdrant>, "->",
      stroke: (paint: P.ml.transparentize(40%), dash: "dashed"),
      label: text(size: 6.5pt, fill: P.ml.lighten(20%))[embed],
      label-side: left,
    ),

    edge(<recs>, <minio>, "->",
      stroke: (paint: P.ml.transparentize(40%), dash: "dashed"),
      label: text(size: 6.5pt, fill: P.ml.lighten(20%))[upload],
      label-side: right,
    ),
  )
]

#v(1fr)

#align(center)[
  #let dot(col) = box(circle(radius: 4pt, fill: col), baseline: 1pt)
  #set text(size: 8pt, fill: P.dim)

  #dot(P.fe) Frontend
  #h(16pt)
  #dot(P.api) Backend
  #h(16pt)
  #dot(P.ml) ML Pipeline
  #h(16pt)
  #dot(P.db) Data Stores
  #h(16pt)
  #dot(P.ext) External Service
  #h(24pt)
  #box(line(length: 18pt, stroke: 1pt + P.fg.transparentize(50%)), baseline: -1.5pt) request flow
  #h(12pt)
  #box(line(length: 18pt, stroke: (paint: P.ml.transparentize(40%), dash: "dashed")), baseline: -1.5pt) pipeline flow
]

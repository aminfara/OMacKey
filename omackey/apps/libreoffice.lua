-- LibreOffice. Accelerators from share/registry/main.xcd (PLAN.md §9 F17).
-- Its dialogs (Options, Paste Special) have class `soffice`.

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "libreoffice",
  classes = {
    "libreoffice-writer", "libreoffice-calc", "libreoffice-impress", "libreoffice-draw",
    "libreoffice-math", "libreoffice-base", "libreoffice-startcenter", "soffice",
  },
  actions = {},
})

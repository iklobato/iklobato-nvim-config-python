; Inject tsx (React/JSX) into <script> tags for proper highlighting
((script_element
  (raw_text) @injection.content)
 (#set! injection.language "tsx"))

; Inject css into <style> tags
((style_element
  (raw_text) @injection.content)
 (#set! injection.language "css"))

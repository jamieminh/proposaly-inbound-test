# proposaly-inbound-test

Static test pages for Proposaly inbound agents, hosted free on GitHub Pages.

- Index: https://jamieminh.github.io/proposaly-inbound-test/
- Each page: `https://jamieminh.github.io/proposaly-inbound-test/pages/<name>.html`

## Add a page

```bash
./new-page.sh <page-name> <bot-id> [script-src]
git add . && git commit -m "Add <page-name> test page" && git push
```

`script-src` defaults to `https://test-cdn.proposaly.io/bot/v1/widget.js`.
The page is generated from `templates/page.html.tpl` and linked from `index.html`.
Pages goes live about a minute after the push.

To change an existing page's agent, edit `data-bot-id` in `pages/<name>.html`
(both the real `<script>` at the bottom and the displayed snippet).

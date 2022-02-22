# Firefox settings

No config files here, just some notes for setting up Firefox from scratch.

## Extensions
Convenient links to quickly install the essentials:
* Ad blocker: [uBlock Origin](https://addons.mozilla.org/firefox/addon/ublock-origin/)
* Tracker blocker: [PrivacyBadger](https://addons.mozilla.org/firefox/addon/privacy-badger17/)
* Translations: [Simple translate](https://addons.mozilla.org/firefox/addon/simple-translate/)
* Reddit Enhancement: [RES](https://addons.mozilla.org/firefox/addon/reddit-enhancement-suite/)
* Live CSS editor: [webextensions.org](https://addons.mozilla.org/firefox/addon/live-editor-for-css-less-sass/)
* Userscripts & styles: [Code Injector](https://addons.mozilla.org/firefox/addon/codeinjector/)
* Skip ads in YouTube videos: [SponsorBlock](https://addons.mozilla.org/firefox/addon/sponsorblock/)

## about:config
* Always prefer light theme: `layout.css.prefers-color-scheme.content-override = 1`
  - Alternatively `ui.systemUsesDarkTheme = 0` (also affects background on new tab)
* Switch tabs by scrolling: `toolkit.tabbox.switchByScrolling = true`
* Middle click to auto scroll: `general.autoScroll = true`
* Disable pocket (also gets rid of the entry in right click menu): `extensions.pocket.enabled = false`

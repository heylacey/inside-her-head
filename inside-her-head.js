/*
  Inside Her Head — Wix custom element
  In Wix: Add > Embed Code > Custom Element, then "Choose Source":
    Server URL: https://heylacey.github.io/inside-her-head/inside-her-head.js
    Tag name:   inside-her-head
  Stretch the element to the size you want; the experience fills it.
*/
(function () {
  var PAGE = 'https://heylacey.github.io/inside-her-head/';

  class InsideHerHead extends HTMLElement {
    connectedCallback() {
      if (this.shadowRoot) return;
      var root = this.attachShadow({ mode: 'open' });
      var src = this.getAttribute('src') || PAGE;
      root.innerHTML =
        '<style>' +
          ':host{display:block;width:100%;height:100%;min-height:480px;background:#0d0c0b;overflow:hidden}' +
          'iframe{display:block;width:100%;height:100%;border:0}' +
        '</style>' +
        '<iframe src="' + src + '" title="Inside Her Head" ' +
          'allow="autoplay; fullscreen" allowfullscreen loading="eager"></iframe>';
    }
  }

  if (!customElements.get('inside-her-head')) {
    customElements.define('inside-her-head', InsideHerHead);
  }
})();

// Development harness for the showcase bridge (see index.html).
(function () {
  'use strict';

  var STRINGS = {
    en: { saveChanges: 'Save changes', save: 'Save', saveDraft: 'Save draft', cancel: 'Cancel' },
    id: { saveChanges: 'Simpan perubahan', save: 'Simpan', saveDraft: 'Simpan draf', cancel: 'Batal' },
  };
  var controllers = [];

  function state() {
    var locale = document.getElementById('locale').value;
    return {
      preset: document.getElementById('preset').value,
      theme: document.getElementById('theme').value,
      locale: locale,
      strings: STRINGS[locale],
    };
  }

  function addHosts(app) {
    var count = Number(new URLSearchParams(location.search).get('count') || '3');
    var hosts = document.getElementById('hosts');
    for (var i = 0; i < Math.min(Math.max(count, 1), 64); i++) {
      var host = document.createElement('div');
      host.className = 'host';
      hosts.appendChild(host);
      var config = Object.assign({ scene: 'button' }, state());
      app.addView({
        hostElement: host,
        initialData: {
          config: config,
          onReady: function (controller) { controllers.push(controller); },
        },
      });
    }
  }

  function sync() {
    var patch = state();
    document.body.classList.toggle('dark', patch.theme === 'dark');
    controllers.forEach(function (controller) { controller.update(patch); });
  }

  ['preset', 'theme', 'locale'].forEach(function (id) {
    document.getElementById(id).addEventListener('change', sync);
  });

  _flutter.loader.load({
    config: { renderer: 'skwasm' },
    onEntrypointLoaded: async function (engineInitializer) {
      var engine = await engineInitializer.initializeEngine({ multiViewEnabled: true, renderer: 'skwasm' });
      var app = await engine.runApp();
      addHosts(app);
    },
  });
})();

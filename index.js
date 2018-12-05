import './assets/styles/main.scss';
import logo from './assets/images/jedi_logo.png';

if (module.hot) {
    module.hot.dispose(() => {
        window.location.reload();
    });
}

import('./src/Main.elm')
    .then(({ Elm }) => {
        var node = document.querySelector('main');
        Elm.Main.init({ node, flags: { logo } });
    });

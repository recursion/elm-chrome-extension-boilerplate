require('./index.css')
/* global chrome */
const mountNode = document.createElement('div')
mountNode.className = 'jbk-root'
document.body.prepend(mountNode)

const Elm = require('./Main.elm')
let app

document.addEventListener('click', () => {
  chrome.runtime.sendMessage({ kind: 'clicked' })
})

const port = chrome.runtime.connect({ name: 'broadcast' })
port.onMessage.addListener(state => {
  if (!app) {
    app = Elm.Main.embed(mountNode, state)
    return
  }
  app.ports.onState.send(state)
})

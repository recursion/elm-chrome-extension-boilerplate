const Elm = require('./Main.elm')
const mountNode = document.getElementById('main')
/* global chrome */
let app

const port = chrome.runtime.connect({ name: 'broadcast' })

window.addEventListener('DOMContentLoaded', () => {
  if (!app) {
    app = Elm.Main.embed(mountNode)
    return
  }

  port.onMessage.addListener(state => {
    // mount app on first broadcast
    app.ports.onState.send(state)
  })

  document.addEventListener('click', () => {
    chrome.runtime.sendMessage({ kind: 'clicked' })
  })
})

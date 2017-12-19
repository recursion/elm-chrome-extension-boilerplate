const Elm = require('./Main.elm')
const mountNode = document.getElementById('main')
/* global chrome */
let app

const port = chrome.runtime.connect({ name: 'broadcast' })

window.addEventListener('DOMContentLoaded', () => {
  app = Elm.Main.embed(mountNode, {clicks: 0, infoWindowVisible: false})
  port.onMessage.addListener(state => {
    app.ports.onState.send(state)
  })

  app.ports.changeInfoWindowVisibility.subscribe(visibility => {
    chrome.runtime.sendMessage({ kind: 'changeWindowVisibility' })
  })
})

document.addEventListener('click', () => {
  chrome.runtime.sendMessage({ kind: 'clicked' })
})

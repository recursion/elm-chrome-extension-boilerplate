const Elm = require('./Main.elm')
const mountNode = document.getElementById('main')
/* global chrome */
let app

const port = chrome.runtime.connect({ name: 'broadcast' })

window.addEventListener('DOMContentLoaded', () => {
  // TODO: this state needs to be loaded from somewhere else (chrome storage?)
  // or possibly during the first state change
  app = Elm.Main.embed(mountNode, {clicks: 0, infoWindowVisible: false})
  port.onMessage.addListener(state => {
    app.ports.onState.send(state)
  })

  app.ports.changeInfoWindowVisibility.subscribe(visibility => {
    chrome.runtime.sendMessage({ msg: 'changeWindowVisibility' })
  })
})

document.addEventListener('click', () => {
  chrome.runtime.sendMessage({ msg: 'clicked' })
})

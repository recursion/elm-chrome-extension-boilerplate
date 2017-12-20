require('./index.css')
/* global chrome */
const mountNode = document.createElement('div')
mountNode.className = 'jbk-root'
document.body.prepend(mountNode)

const Elm = require('./Main.elm')
let app

// send the current location to our background app
chrome.runtime.sendMessage({msg: 'locationChange', location: window.location})

document.addEventListener('click', () => {
  chrome.runtime.sendMessage({ msg: 'clicked' })
})

const port = chrome.runtime.connect({ name: 'broadcast' })
port.onMessage.addListener(state => {
  if (!app) {
    app = Elm.Main.embed(mountNode, state)
    return
  }
  app.ports.onState.send(state)
})

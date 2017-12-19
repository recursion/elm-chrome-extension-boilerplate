const Elm = require('./Main.elm')
/* global chrome */

// initial state
// this should be loaded to/from chrome storage eventually
let currState = {
  clicks: 0,
  infoWindowVisible: true
}

const app = Elm.Main.worker(currState)

// the currently connected ports
const listeners = new Set()

chrome.runtime.onConnect.addListener(port => {
  console.assert(port.name === 'broadcast')

  listeners.add(port)

  // whenever a new listener connects, we immediately tell them
  // the state so they can initialize
  port.postMessage(currState)

  port.onDisconnect.addListener(() => {
    listeners.delete(port)
  })
})

function broadcast (state) {
  currState = state
  for (const port of listeners) {
    port.postMessage(currState)
  }
}

app.ports.broadcast.subscribe(state => {
  broadcast(state)
})

chrome.runtime.onMessage.addListener((request, sender) => {
  switch (request.msg) {
    case 'clicked':
      app.ports.clicked.send(null)
      break

    case 'changeWindowVisibility':
      app.ports.changeWindowVisibility.send(null)
      break

    default:
      console.log('Unknown message type: ', request.kind)
  }
})

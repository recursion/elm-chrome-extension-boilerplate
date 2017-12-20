const Elm = require('./Main.elm')
/* global chrome */

// initial state
// TODO: load/save this to chrome storage
let currState = {
  clicks: 0,
  infoWindowVisible: false
}

const app = Elm.Main.worker(currState)

// the currently connected ports
const listeners = new Set()

// listen for other chrome components
// and add them to our set of listeners
// so we can broadcast to them
chrome.runtime.onConnect.addListener(port => {
  console.assert(port.name === 'broadcast')

  // add this port to our listeners list
  listeners.add(port)

  // whenever a new listener connects, we immediately tell them
  // the state so they can initialize
  port.postMessage(currState)

  // remove a listener
  port.onDisconnect.addListener(() => {
    listeners.delete(port)
  })
})

// broadcast application data
// to our listeners
function broadcast (state) {
  currState = state
  for (const port of listeners) {
    port.postMessage(currState)
  }
}

// subscribe to our applications broadcasts
// and broadcast its messages to chrome listeners
app.ports.broadcast.subscribe(state => {
  broadcast(state)
})

// listen/respond to chrome runtime messages
chrome.runtime.onMessage.addListener((request, sender) => {
  switch (request.msg) {
    case 'clicked':
      app.ports.clicked.send(null)
      break

    case 'changeWindowVisibility':
      app.ports.changeWindowVisibility.send(null)
      break

    default:
      console.log('Unknown message type: ', request.msg)
  }
})

const Elm = require('./Main.elm')
const store = require('./storage')

/* global chrome */

// initial state
// TODO: load/save this to chrome storage
// TODO: store settings based on the current location
store.init()
  .then((result) => {
    console.log('In background js: got: ', result)
  })

let currState = {
  clicks: 0,
  infoWindowVisible: false,
  infoWindowPosition: {x: 0, y: 0}
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
// TODO: save the current state to chrome storage on changes
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

    case 'locationChange':
      console.log('New Location: ', request.location)
      break

    default:
      console.log('Unknown message type: ', request.msg)
  }
})

// storage.js
// api for chrome storage
// set: takes js values and stores them on chrome storage
// get: returns a promise with js values from chrome storage
// init: initialize chrome storage and get the stored settings

/* global chrome */
export const init = () => {
  return new Promise((resolve, reject) => {
    // make sure chrome storage default settings are up to date.
    get(null)
      .then((results) => {
        if (results) {
          console.log('Got chrome settings: ', results)
          if (!results.version || results.version !== defaults.version) {
            console.log('Settings need to be updated.')
          }
          resolve(results)
        } else {
          // load defaults
          console.log('Loading default settings')
          resolve('Need to load Defaults....')
        }
      })
    // return the current settings
  })
}

// get key
export const get = (key) => {
  return new Promise((resolve, reject) => {
    chrome.storage.sync.get(key, (results) => {
      console.log(results)
      if (Object.keys(results).length !== 0) {
        resolve(JSON.parse(results))
      } else {
        resolve(null)
      }
    })
    // get and return a setting, or all settings from storage
  })
}

// set key to value
export const set = (key, value) => {
  if (Array.isArray(key)) {
    key.map((k) => {
      const v = JSON.stringify(value)
      chrome.storage.sync.set({key, v})
    })
  }
}

/*
function clear () {
  chrome.storage.sync.clear(() => {
      // check for error
      // if runtime.error then..
  })
}

function remove (key) {
  chrome.storage.sync.remove((key) => {
      // check for error
      // if runtime.error then..
  })
}
*/
/*
settings:

siteUrl: position, lotsize, offset, api-keys

*/
const defaults  = {
  version: '0.0.1',
  offset: '0.1',
  lotsize: '0.001',
  multipliers: [0.1, 0.25, 0.5, 0.75, 1, 2, 3, 5, 10, 25, 50, 100],
  infoWindowPosition: {x: 0, y: 0}
}

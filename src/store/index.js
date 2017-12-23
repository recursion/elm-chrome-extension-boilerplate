import { settings } from './settings'
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
          if (!results.version || results.version !== settings.version) {
            console.log('Settings need to be updated.')
            set(settings)
            resolve(settings)
          }
          resolve(results)
        } else {
          // load settings
          console.log('Loading default settings....')
          set(settings)
          resolve(settings)
        }
      })
  })
}

// TODO: get and set are slightly backwards: as get should check for key type
// but set dosnt need to?
// get (by key) and return a setting, or all settings from storage
// key can be a string or array of strings or null for all settings
export const get = (key) => {
  return new Promise((resolve, reject) => {
    chrome.storage.sync.get(key, (results) => {
      resolve(results)
    })
  })
}

// set key to value
// takes an object with key/value pairs
export const set = (settings) => {
  chrome.storage.sync.set(settings)
  // TODO: error checking?
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

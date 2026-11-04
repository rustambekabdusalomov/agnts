// Merges user settings into the defaults (lodash _.merge is vulnerable to
// prototype pollution before 4.17.21).
const _ = require("lodash");

function settings(defaults, body) {
  return _.merge({}, defaults, JSON.parse(body));
}

module.exports = { settings };

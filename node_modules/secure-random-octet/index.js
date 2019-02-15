var getRandomValues = require('get-random-values');

function secureRandomOctet() {
  var buf = new Uint8Array(1);
  getRandomValues(buf);
  return buf[0];
}

module.exports = secureRandomOctet;
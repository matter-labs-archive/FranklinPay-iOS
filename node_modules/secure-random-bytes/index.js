var randomOctet = require('secure-random-octet');

function randomBytes(length) {
  var result = '';
  for (var i = 0; i < length; i++) {
    result += String.fromCharCode(randomOctet());
  }
  return result;
}

module.exports = randomBytes;
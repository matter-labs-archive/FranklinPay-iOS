# secure-random-octet

[![Build Status](https://img.shields.io/travis/KenanY/secure-random-octet.svg)](https://travis-ci.org/KenanY/secure-random-octet)
[![Dependency Status](https://img.shields.io/gemnasium/KenanY/secure-random-octet.svg)](https://gemnasium.com/KenanY/secure-random-octet)

Generate a cryptographically secure octet.

## Example

``` javascript
var secureRandomOctet = require('secure-random-octet');

secureRandomOctet();
// => 4
```

## Installation

``` bash
$ npm install secure-random-octet
```

## API

``` javascript
var secureRandomOctet = require('secure-random-octet');
```

### `secureRandomOctet()`

Returns a cryptographically secure _Number_ octet. Uses
[get-random-values](https://github.com/KenanY/get-random-values), so an _Error_
will be thrown if there is no secure random number generator available.
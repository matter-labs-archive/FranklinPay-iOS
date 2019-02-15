const elliptic = require('elliptic');
const BN = require("bn.js");
const assert = require("assert");
const Buffer = require('buffer/').Buffer  // note: the trailing slash is important!


const babyJubjubParams = {
    a: new BN("21888242871839275222246405745257275088548364400416034343698204186575808495616"),
    d: new BN("12181644023421730124874158521699555681764249180949974110617291017600649128846"),
    n: new BN("2736030358979909402780800718157159386076813972158567259200215660948447373041"),
    p: new BN("21888242871839275222246405745257275088548364400416034343698204186575808495617"),
    c: "1",
    g: ["2ef3f9b423a2c8c74e9803958f6c320e854a1c1c06cd5cc8fd221dc052d76df7",
        "05a01167ea785d3f784224644a68e4067532c815f5f6d57d984b5c0e9c6c94b7"]
}

const altBabyJubjub = new elliptic.curve.edwards(babyJubjubParams);

add = function() {
    return 10;
};

sign = function(message, privateKey, curve) {
    const r = (new BN("8a74c0ed82de81d5854583267e17b6ac5140929814aa53c6c5ae0d31b4216bd8", 16, "be")).umod(curve.n);
    var R = curve.g.mul(r);
    if (R.isInfinity()) {
        throw Error("R is infinity")
    }
    var s_ = (new BN(message, 16, "be")).mul(privateKey);
    var S = r.add(s_).umod(curve.n);
    return { R: R, S: S};
};

verify = function(message, signature, publicKey, curve) {
    var key = publicKey;
    var h = new BN(message, 16, "be");
    console.log("C = " + h.toString(16));
    var SG = curve.g.mul(signature.S);
    var RplusAh = signature.R.add(key.mul(h));
    return RplusAh.eq(SG);
};

serializeSignature = function(signature) {
    const R_X = signature.R.getX();
    const R_Y = signature.R.getY();
    const r_coords = [R_X.toString(16), R_Y.toString(16)];
    return {
        R: r_coords,
        S: signature.S.toString(16)
    };
};

floatToInteger = function(floatBytes, exp_bits, mantissa_bits, exp_base) {
    assert(floatBytes.length*8 == (exp_bits + mantissa_bits));
    const floatHolder = new BN(floatBytes, 16, "be"); // keep bit order
    const totalBits = floatBytes.length*8 - 1; // starts from zero
    let expBase = new BN(exp_base);
    let exponent = new BN(0);
    let exp_power_of_to = new BN(1);
    const two = new BN(2);
    for (let i = 0; i < exp_bits; i++) {
        if (floatHolder.testn(totalBits - i)) {
            exponent = exponent.add(exp_power_of_to);
        }
        exp_power_of_to = exp_power_of_to.mul(two);
    }
    exponent = expBase.pow(exponent);
    let mantissa = new BN(0);
    let mantissa_power_of_to = new BN(1);
    for (let i = 0; i < mantissa_bits; i++) {
        if (floatHolder.testn(totalBits - exp_bits - i)) {
            mantissa = mantissa.add(mantissa_power_of_to);
        }
        mantissa_power_of_to = mantissa_power_of_to.mul(two);
    }
    return exponent.mul(mantissa);
};

integerToFloat = function(integer, exp_bits, mantissa_bits, exp_base) {
    const maxMantissa = (new BN(1)).ushln(mantissa_bits).subn(1);
    const maxExponent = (new BN(exp_base)).pow((new BN(1)).ushln(exp_bits).subn(1));
    assert(integer.lte(maxMantissa.mul(maxExponent)));
    // try to get the best precision
    let power = integer.div(maxMantissa);
    const exponentBase = new BN(exp_base);
    let exponent = new BN(0);
    if (integer.lte((new BN(maxMantissa)))) {
        exponent = new BN(0);
    } else {
        while (power.gt(exponentBase)) {
            power = power.div(exponentBase);
            exponent = exponent.addn(1);
        }
        if (maxMantissa.mul(exponentBase.pow(exponent)).lt(integer)) {
            exponent = exponent.addn(1);
        }
    }
    
    power = exponentBase.pow(exponent);
    let mantissa = integer.div(power);
    // pack
    assert((mantissa_bits + exp_bits) % 8 === 0);
    const totalBits = mantissa_bits + exp_bits - 1;
    const encoding = new BN(0);
    for (let i = 0; i < exp_bits; i++) {
        if (exponent.testn(i)) {
            encoding.bincn(totalBits - i);
        }
    }
    for (let i = 0; i < mantissa_bits; i++) {
        if (mantissa.testn(i)) {
            encoding.bincn(totalBits - exp_bits - i);
        }
    }
    console.log(encoding.toString())
    console.log(exp_bits, mantissa_bits)
    console.log((exp_bits + mantissa_bits)/8)
    return encoding.toArrayLike(Buffer, "be", (exp_bits + mantissa_bits)/8)
};

packBnLe = function(bn, numBits) {
    let bin = bn.toString(2);
    assert(bin.length <= numBits)
    bin = bin.padStart(numBits, "0");
    bin = bin.split("");
    bin = bin.reverse();
    bin = bin.join("");
    let newBN = new BN(bin, 2);
    let buff = newBN.toArrayLike(Buffer, "be");
    if (buff.length < numBits / 8) {
        buff = Buffer.concat([buff, Buffer.alloc(numBits / 8 - buff.length)])
    }
    return buff;
};

serializeTransaction = function(tx) {
    const {from, to, amount, fee, nonce, good_until_block} = tx;
    assert(from.bitLength() <= 24);
    assert(to.bitLength() <= 24);
    assert(amount.bitLength() <= 128);
    assert(fee.bitLength() <= 128);
    assert(nonce.bitLength() <= 32);
    assert(good_until_block.bitLength() <= 32);

    // const components = [];
    // components.push(packBnLe(from, 24));
    // components.push(packBnLe(to, 24));
    let amountFloatBytes = integerToFloat(amount, 5, 11, 10);
    // components.push(amountFloatBytes);
    let feeFloatBytes = integerToFloat(fee, 5, 3, 10);
    // components.push(feeFloatBytes);
    // components.push(packBnLe(nonce, 32));
    // components.push(packBnLe(good_until_block, 32));

    const components = [
        good_until_block.toArrayLike(Buffer, "be", 4),
        nonce.toArrayLike(Buffer, "be", 4),
        packBnLe(new BN(feeFloatBytes, 16, "be"), 8),
        packBnLe(new BN(amountFloatBytes, 16, "be"), 16),
        to.toArrayLike(Buffer, "be", 3),
        from.toArrayLike(Buffer, "be", 3)
    ];

    let serialized = Buffer.concat(components);

    let newAmount = floatToInteger(amountFloatBytes, 5, 11, 10);
    console.log("Reparsed amount = " + newAmount.toString(10));
    let newFee = floatToInteger(feeFloatBytes, 5, 3, 10);

    return {
        bytes: serialized,
        from: from,
        to: to,
        amount: newAmount,
        fee: newFee,
        nonce: nonce,
        good_until_block: good_until_block
    }
};

toApiForm = function(tx, sig) {
    // expected by API server
    // pub from:               u32,
    // pub to:                 u32,
    // pub amount:             BigDecimal,
    // pub fee:                BigDecimal,
    // pub nonce:              u32,
    // pub good_until_block:   u32,
    // pub signature:          TxSignature,

    // pub struct TxSignature{
    //     pub r_x: Fr,
    //     pub r_y: Fr,
    //     pub s: Fr,
    // }

    let serializedSignature = serializeSignature(sig);
    let [r_x, r_y] = serializedSignature.R;
    let signature = {
        r_x: "0x" + r_x.padStart(64, "0"), 
        r_y: "0x" + r_y.padStart(64, "0"),
        s: "0x" + serializedSignature.S.padStart(64, "0")
    };

    let txForApi = {
        from: tx.from.toNumber(),
        to: tx.to.toNumber(),
        amount: tx.amount.toString(10),
        fee: tx.fee.toString(10),
        nonce: tx.nonce.toNumber(),
        good_until_block: tx.good_until_block.toNumber(),
        signature: signature
    }

    return txForApi;
};

createTransaction = function(from, to, amount, fee, nonce, good_until_block, privateKey) {
    let tx = {
        from: new BN(from),
        to: new BN(to),
        amount: new BN(amount),
        fee: new BN(fee),
        nonce: new BN(nonce),
        good_until_block: new BN(good_until_block)
    };
    const serializedTx = serializeTransaction(tx);
    const message = serializedTx.bytes;
    console.log("Message hex = " + message.toString("hex"));
    const signature = sign(message, privateKey, altBabyJubjub);
    const pub = altBabyJubjub.g.mul(privateKey);
    const isValid = verify(message, signature, pub, altBabyJubjub);
    assert(isValid);
    console.log("Public = " + pub.getX().toString(16) + ", " + pub.getY().toString(16));
    const apiForm = toApiForm(serializedTx, signature);
    return apiForm;
};

global.exports = {
    add,
    sign,
    verify,
    floatToInteger,
    integerToFloat,
    serializeSignature,
    serializeTransaction,
    parseSignature,
    newKey,
    getPublicData,
    parsePublicData,
    createTransaction
}

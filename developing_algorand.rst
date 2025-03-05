##########################
Classic oracle on Algorand
##########################

Customer applications interact with Gora via smart contract calls. For a quick
hands-on introduction to using Gora from your smart contracts, please see Gora
`Developer Quick Start <https://github.com/GoraNetwork/developer-quick-start>`_
GitHub repository. For a complete reference and instructions on calling Gora
from JavaScript, read on.

**********************
Requesting oracle data
**********************

Gora requests are made by calling ``request`` method of the main Gora smart
contract. This contract's application ID is a part of Gora network
configuration and can be found using ``info`` command of the Gora CLI tool.
For example (with irrelevant output removed):

.. parsed-literal::
   :class: terminal

   $ ./gora info
   ...
   Main app ID: 439550742
   ...
   $

``request`` method accepts the following arguments:

================ ===================== =================================================
Name             ABI Type              Description
================ ===================== =================================================
``request_args`` ``byte[]``            Encoded request specification
``destination``  ``byte[]``            Encoded destination call specificaiton
``type``         ``uint64``            Request type ID
``key``          ``byte[]``            Unique request key
``app_refs``     ``uint64[]``          App references to pass through to destination
``asset_refs``   ``uint64[]``          Asset references to pass through to destination
``account_refs`` ``address[]``         Account references to pass through to destination
``box_refs``     ``(byte[],uint64)[]`` Box references to pass through to destination
================ ===================== =================================================

==============================
Encoding request specification
==============================

A request specification is an instance of a structured `Algorand ABI type <https://arc.algorand.foundation/ARCs/arc-0004>`_.
The exact ABI type depends on the type of oracle request being specified, but it
is always supplied to the request method encoded as a byte string. This allows
Gora to add new request types without changing its smart contracts.

Currently Gora supports three request types:

 * Type #1 - classic requests, querying sources predefined by Gora
 * Type #2 - general URL requests, for arbitrary URLs and advanced data extraction methods
 * Type #3 - off-chain computation requests

At the highest level of Algorand ABI type definition, all of these types have
the following structure:

``tuple(source_spec[], aggregation, user_data)``.

Where:

 * ``source_spec[]`` - array of source specifications. A single oracle request can query multiple sources.
 * ``aggregation: uint32`` - how results from the sources are aggregated
   (``0`` - no aggregation, ``1`` - maximum, ``2`` - minimum, ``3`` - average).
 * ``user_data: byte[]`` - any user-supplied data to attach to request and its response

A a source specification is a structured Algorand ABI type instance that
describes an oracle source query.  Its exact ABI type depends on the request
type and is described below.

.. figure:: request_types.svg
   :width: 700
   :align: left
   :alt: Gora oracle request types diagram

   Gora oracle request types

==================================
Request type #1 - classic requests
==================================

This is the original Gora request type which relies on oracle source definitions
bundled with GNR. Source specifications for requests of this type contain the
following fields:

=============== ============= =============================================================
Name            ABI Type      Description
=============== ============= =============================================================
``source_id``   ``uint32``    numeric id of an oracle source      
``source_args`` ``byte[][]``  positional arguments to the source  
``max_age``     ``uint32``    maximum age of source data in seconds to be considered valid
=============== ============= =============================================================

Available sources and arguments applicable to them can be examined by running:
``gora dev-sources``. The list of classic sources is defined by Gora is subject to
extension in future releases.

**Parametrized sources**

To add flexibility to classic requests, certain source properties can be
specified on per-query basis.

For example, if a source provides many pieces of data from the same endpoint, it
is more convenient to let the requester specify the ones they want than to
define a separate source for each. This is achieved by *parametrizing*
``value_path`` property. Setting it to ``##0`` in the oracle source definition
will make Gora nodes take its value from 0'th argument of the request being
served.  Parameter placeholders can just as well be placed inside strings where
they will be substituted, e.g. ``http://example.com/##2&a=123``.

The following oracle source definition properties can be parametrized: ``url``,
``value_path``, ``timestamp_path``, ``value_type``, ``value``, ``round_to``,
``gateway``.  *Substituted values are always treated as strings*. For example,
when supplying a parameter to set ``round_to`` field to ``5``, the string
``"5"`` must be used rather than numeric value of ``5``.

======================================
Request type #2 - general URL requests
======================================

This type of oracle request does not depend on a pre-configured list of oracle
sources and allows authentication via third party without compromising
decentralization. Source specifications for requests of this type contain the
following fields:

================== ========== ==========================================================
Name               ABI Type   Description
================== ========== ==========================================================
``url``            ``byte[]`` source URL to query
``auth_Url``       ``byte[]`` authenticator URL
``value_expr``     ``byte[]`` expression to extract value from response
``timestamp_expr`` ``byte[]`` expression to extract timestamp from response
``max_age``        ``uint32`` maximum age of data in seconds  to be considered valid
``value_type``     ``uint8``  return value type: ``0`` for string, ``1`` for number
``round_to``       ``uint8``  number of digits to round result to (``0`` for no rounding)
``gateway_url``    ``byte[]`` gateway url (not for general use)
``reserved_0``     ``byte[]`` reserved for future use
``reserved_1``     ``byte[]`` reserved for future use
``reserved_2``     ``uint32`` reserved for future use
``reserved_3``     ``uint32`` reserved for future use
================== ========== ==========================================================

**Third-party authentication**

General URL requests support using third party services to access sources that
require authentication. For example, a price data feeds provider may protect
their paid endpoints by requiring an access key (password) in URLs. Since
everything stored by the blockchain is public, authentication keys cannot be
held by smart contracts or included in oracle requests. Node operators may
configure their own access keys for some sources, but not in the general case.
Third-party authentication services that issue one-time authentication keys on
per-request basis are designed to fill that gap. When `auth_url` field in the
source specification is filled, Node Runner software will call this URL and
receive a temporary auth key. The authenticator service will check that the node
runner and the oracle request are both eligible to receive it.

=======================================
Request type #3 - off-chain computation
=======================================

For use cases that require even more flexibility, Gora supports oracle requests
that execute user-supplied [Web Assembly](https://webassembly.org/) code. The
code is executed off-chain by Gora network nodes and is subject to resource
limits.

To make use of this feature the developer must write their program using Gora
Off-Chain API in any language that compiles to Web Assembly. Compiled binary is
then made available to Gora network nodes in one of the three ways: verbatim as
a request parameter (for small programs), in on-chain box storage or as a
download at a public URL.

.. figure:: off_chain.svg.svg
   :width: 500
   :align: left
   :alt: Gora off-chain computation workflow diagram

   Gora off-chain computation workflow

Request specification ABI type for this kind of request has the
following structure:

=============== ============== ========================================
Name            ABI Type       Description
=============== ============== ========================================
``api_version`` ``uint32``     minimum off-chain API version required
``spec_type``   ``uint8``      how executable is  specified (see below)
``exec_spec``   ``bytes[]``    executable specification
``exec_args``   ``bytes[][]``  positional arguments to the executable
``reserved_0``  ``bytes[]``    reserved for future use
``reserved_1``  ``bytes[]``    reserved for future use
``reserved_2``  ``uint32``     reserved for future use
``reserved_3``  ``uint32``     reserved for future use
=============== ============== ========================================

``spec_type`` value determines what is contained in ``exec_spec`` as follows:

 * ``0`` - executable body itself
 * ``1`` - 8-byte app ID followed by box name for reading from on-chain box storage
 * ``2`` - URL to fetch the executable from

To get a grasp of Gora Off-Chain API and execution model, start with this example
program: `example_off_chain_basic.c <https://github.com/GoraNetwork/developer-quick-start/blob/main/example_off_chain_basic.c>`_.
It returns the phrase "Hello world!" as an oracle value and is self-explanatory.
To compile it, install `Clang C compiler <https://clang.llvm.org/>`_  version 12
or newer and run:

.. parsed-literal::
   :class: terminal

   clang example_off_chain_basic.c -Os --target=wasm32-unknown-unknown-wasm -c -o example_off_chain_basic.wasm

For a more advanced example, featuring URL requests and asynchronous operations,
see: `example_off_chain_multi_step.c <https://github.com/GoraNetwork/developer-quick-start/blob/main/example_off_chain_multi_step.c>`_.

This program does useful work and is extensively commented. It takes a British
postcode as a parameter, queries two data sources, building their URLs
dynamically, and returns current air temperature in the area of said postcode.
This requires two data-retrival operations: getting postcode geographical
coordinates and querying current weather at them.

Because of certain limitations of Web Assembly, programs cannot efficiently
pause while waiting to receive data from extrnal sources such as URLs.  To work
around that, Gora off-chain programs are run in *steps*. Steps are essentially
repeated executions of the program with a shared context that includes current
execution number. A *step* starts when the program's *main function* is called
by the executing node and ends when it returns.

During a step, the program can schedule HTTP(S) requests, possibly using URL
templates that it can fill at run time. When the step ends, these requests are
executed by the Gora node and on their completion, the next step commences. The
program can access request results as well as other node-provided data such as
the number of step currently executing via data structure passed to it as an
argument.

Finishing a step, the program always returns a value which tells the Gora node
what to do next: execute another step, finish successfully or terminate with a
specific error code. For the list of valid return values, see `gora_off_chain.h`_
header file.

To compile this example program, run:
```
clang example_off_chain_multi_step.c -Os --target=wasm32-unknown-unknown-wasm -c -o example_off_chain_multi_step.wasm
```

To execute the compiled binary using Gora CLI and default test destination app, run:
```
gora request --off-chain ./off_chain_example.wasm --args sm14hp
```

==================================
Multi-value requests and responses
==================================

This feature allows requests of type 1 and 2 to fetch multiple pieces of data
from the same source response. Normally, ``value_path`` property contains a single
expression, so just one value is returned by an oracle request. To return
multiple values, it is possible to specify multiple expressions separated by tab
character. For example: ``$.date\t$.time\t$.details.name``. Since an oracle return
value must be a single byte string for the consensus to work, returned pieces of
data are packed into Algorand ABI type - an array of strings:

.. code:: javascript
   :number-lines:

   const multiResponse = new Algosdk.ABIArrayDynamicType(Algosdk.ABIType.from("byte[]"));

To access individual results, smart contract handling the oracle response must
unpack this ABI type. *N*th string in the array will correspond to the *n*th
expression in the ``valuePath`` field. **Important:** all returned pieces of
data in such responses are stringified, including numbers. For example, number
``9183`` will be returned as ASCII string ``"9183"``. Smart contract code
handling the response must make the necessary conversions.

================================
Rounding numeric response values
================================

Certain kinds of data, such as cryptocurrency exchange rates, are so volatile
that different Gora nodes are likely to get slightly different results despite
querying them at almost the same time. To achieve consensus between nodes when
using such sources, Gora can round queried values. A source that supports
rounding will have "Round to digits" field when shown with ``gora dev-sources``
command. Usually, the rounding setting will be parametrized, for example: "Round
to digits: ##3". This means that the number of significant digits to round to is
supplied in parameter with index 3.  The *number must be provided in string
representation*, like all parameters. Rounding will only affect the fractional
part of the rounded number, all integer digits are always preserved. For
example, if rounding parameter is set to "7", the number ``123890.7251`` will be
rounded to 123890.7, but the number ``98765430`` will remain unaffected.

*****************************
Calling outside of blockchain
*****************************

While Gora's main purpose is to interact with smart contracts, it is sometimes
desirable to access its functionality from normal Linux software. Examples
below will be given in JavaScript, but they can be adapted to any language
supported by the Algorand API, such as Python or Go.

We start by building the request spec ABI type to encode our request. It can
be accomplished in a single call, but will be done in steps here for clarity:

.. code:: javascript
  :number-lines:

   const Algosdk = require("algosdk");

   const basicTypes = {
     sourceArgList: new Algosdk.ABIArrayDynamicType(Algosdk.ABIType.from("byte[]")),
     sourceId: Algosdk.ABIType.from("uint32"),
     maxAge: Algosdk.ABIType.from("uint32"),
     userData: Algosdk.ABIType.from("byte[]"),
     aggregation: Algosdk.ABIType.from("uint32"),
   };

   const sourceSpecType = new Algosdk.ABITupleType([
     basicTypes.sourceId,
     basicTypes.sourceArgList,
     basicTypes.maxAge
   ]);

   const requestSpecType = new Algosdk.ABITupleType([
     new Algosdk.ABIArrayDynamicType(sourceSpecType),
     basicTypes.aggregation,
     basicTypes.userData
   ]);

Now we will use ``requestSpecType`` ABI type that we just created to encode a
hypothetical Oracle request. We will query two sources for USD/EUR price pair
and receive their average value. The data must be no more than an hour old in
both cases. The sources are predefined in Gora with IDs 2 and 5, but one
specifies currencies mnemonically while the other does it numerically:

.. code:: javascript
  :number-lines:

  const requestSpec = requestSpecType.encode([
    [
      [ 2, [ Buffer.from("usd"), Buffer.from("eur") ], 3600 ],
      [ 5, [ Buffer.from([ 12 ]), Buffer.from([ 44 ]) ], 3600 ],
    ],
    3, // average it
    Buffer.from("test") // let the receiving smart contract know it's a test
  ]);


Done. The ``requestSpec`` variable can now be used for ``spec`` argument when
calling the ``request`` method for Gora main smart contract.

==========================
Decoding request responses
==========================

Results of an oracle request are returned by calling ``dest_method`` method of the
smart contract specified in ``dest_id``. The method gets passed the following two
arguments:

 * ``type: uint32`` - response type; currently is always ``1``.
 * ``body: byte[]`` - encoded body of the response (details below).

The ``body`` argument contains an ABI-encoded tuple of the following structure:

 * ``byte[]`` - request ID. Currently the same as Algorand transaction ID of
   the ``request`` smart contract call that initiated the request.
 * ``address`` - address of the account making the request
 * ``byte[]`` - oracle return value, more details below
 * ``byte[]`` - data specified in ``userData`` field of the request
 * ``uint32`` - result error code, see below
 * ``uint64`` - bit field with bits corresponding to the request sources;
   if n'th bit is set, the n'th source has failed to yield a valid value.

**Result error codes**

 * ``0`` - normal result.
 * ``1`` - result was truncated because it was over the allowed size. Result
   size limit is configured in Node Runner software and depends on
   maximum smart contract arguments size supported by Algorand.

Unless the numeric type has been explicitly specified for the return value, it
will be encoded as a string. If value expression is a JSON path that matches an
object, it will stringified, e.g. ``'{ "date": "01-01-2020", "price": 123 }'``.

**Numeric oracle return values**

When returned oracle value is a number, it is encoded into a 17-byte array.
``0``'s byte encodes value type:

 * ``0`` - empty value (not-a-number, NaN)
 * ``1`` - positive number
 * ``2`` - negative number

Bytes ``1 - 8`` contain the integer part, ``9 - 17`` - the decimal fraction part,
as big endian uint64's.

For example, ``0x021000000000000000ff00000000000000`` in memory order (first byte
has 0 offset) decodes as ``-16.255``

*****************************
Troubleshooting applications
*****************************

Troubleshooting Gora applications begins with making oracle requests and looking
at how they are handled in each processing phase. For that, we recommend using
Gora CLI tool, a Gora observer node and `Algorand Dapp Flow <https://app.dappflow.org/>`_.
web app. The rest of this section will walk you through setting them up and
using them to trace execution of a Gora request.

=============
Observer node
=============

Gora observer node is a node set up and running on a Gora network for the purpose
of monitoring requests. An observer node is not required to run continuously or
have any GORA tokens staked. When using `Developer Quick Start <https://github.com/GoraNetwork/developer-quick-start>`_,
setting up an observer node is not necessary because it includes a full Gora node.
Refer to the documentation at the above link for details. For troubleshooting
applications on Algorand testnet or mainnet, if you are not already running
a normal Gora node on the same network, set on up following the Getting Started
section above.

======================================================
Checking that your application is making request calls
======================================================

Now you can find out Algorand address of the application from which you are
making Gora requests. This can be done with `Algorand Dapp Flow Explorer <https://app.dappflow.org/explorer/home>`_:
enter your application ID into the search box and press Enter which should take
you to application transactions page. The address should be displayed under
"Application account" label.

Make sure you have set up your observer node as its configuration is used by
Gora CLI tool. Now run the tool to find out Gora main smart contract ID:

.. parsed-literal::
   :class: terminal

   $ gora info

You should get output containing a string like:

.. parsed-literal::
   :class: terminal

   Main app ID: 439550742

Now you can use Dapp Flow to check that oracle request calls are being made from
your application to correct Gora smart contract. Try running your app, then search
on Dapp Flow for transactions to Gora main app ID. There must be an application call
transaction from your app address just made.

==========================================
Monitoring how your requests are processed
==========================================

Once your Gora request call gets stored on the blockchain, it is up for detection
and processing by Gora nodes. That including your observer node, which you will
now utilize to monitor processing of your requests. If you are not using
`Developer Quick Start <https://github.com/GoraNetwork/developer-quick-start>`_,
you will need to enable debug output on your node. Open your node config file
(``~/.gora`` by default) and under ``"deployment"`` section add the following lines:

``"logLevel": 5``

Make sure to add a comma to the previous line if there is one or you will get
a config syntax error when trying to start the node. Restart the node if it is
already running.

If your observer node hasn't been running, start it
now and keep an eye on its log messages: either by running it in the foreground or
by tailing logs with ``docker logs -f <node container name>``.

Now when your Gora blockchain app makes another request, you should see your node
pick up the request and log detailed messages on various phases of its processing.
For example, with a General URL request:

.. parsed-literal::
   :class: terminal

   2023-12-10T20:46:54.432Z DEBUG Handling call "main#1003.request" from "Z7PANAMW2I7MEHTTT24U2G5UJXUSIO6QORYCJV6YVZZQNBVQ2Z22C4P5XI", round "81754"
   2023-12-10T20:46:54.441Z INFO  Processing oracle request "JHPCPIL4BP2GN5F7PQRAJEC6MBRHYMVALUZMMDZL7AWXGNZZATWA", destination: "1516.handle_oracle_url"
   2023-12-10T20:46:54.441Z DEBUG Querying URL source: "https://coinmarketcap.com/currencies/bnb/, "regex:>BNB is (?:up|down) ([.0-9]+)% in the last 24 hours, "", ""
   2023-12-10T20:46:54.507Z DEBUG Fetching "https://coinmarketcap.com/currencies/bnb/", time limit (ms): 5000, size limit (bytes): 1048576
   2023-12-10T20:46:54.548Z DEBUG Querying URL source: "https://coinmarketcap.com/currencies/solana/, "regex:>Solana is (?:up|down) ([.0-9]+)% in the last 24 hours, "", ""
   2023-12-10T20:46:54.627Z DEBUG Fetching "https://coinmarketcap.com/currencies/solana/", time limit (ms): 5000, size limit (bytes): 1048576
   2023-12-10T20:46:54.865Z DEBUG Fetched "https://coinmarketcap.com/currencies/solana/", "315317" bytes, starting with: "<!DOCTYPE html><html"...
   2023-12-10T20:46:54.886Z DEBUG Result #1, source "https://coinmarketcap.com/currencies/solana/": "6.41", for "JHPCPIL4BP2GN5F7PQRAJEC6MBRHYMVALUZMMDZL7AWXGNZZATWA"
   2023-12-10T20:46:55.342Z DEBUG Decoding gzip
   2023-12-10T20:46:55.360Z DEBUG Fetched "https://coinmarketcap.com/currencies/bnb/", "335244" bytes, starting with: "<!DOCTYPE html><html"...
   2023-12-10T20:46:55.363Z DEBUG Result #0, source "https://coinmarketcap.com/currencies/bnb/": "0.53", for "JHPCPIL4BP2GN5F7PQRAJEC6MBRHYMVALUZMMDZL7AWXGNZZATWA"
   2023-12-10T20:46:55.364Z DEBUG Result for "JHPCPIL4BP2GN5F7PQRAJEC6MBRHYMVALUZMMDZL7AWXGNZZATWA": 6.41 (number, aggregation: "2")
   2023-12-10T20:46:55.377Z DEBUG Using seed: "0x1ea6cbe0dac0d99beb3903648fc155327c93c870c08106a9b66a7b271e7345d3"
   2023-12-10T20:46:55.383Z DEBUG Alloted "1000004424" vote(s) for "JHPCPIL4BP2GN5F7PQRAJEC6MBRHYMVALUZMMDZL7AWXGNZZATWA", zIndex: "1"
   2023-12-10T20:46:55.403Z DEBUG Creating verify txn to vote on "JHPCPIL4BP2GN5F7PQRAJEC6MBRHYMVALUZMMDZL7AWXGNZZATWA": { suggestedParams: { flatFee: true, fee: 0, firstRound: 81755, lastRound: 81764, genesisID: 'sandnet-v1', genesisHash: 'RXrzSgzbMh2FXnMJPwqL2UGeyIdbiks2G1oUvDS7fA8=', minFee: 1000 }, from: 'GBS6GNRJIOD3SFHQGCXT7QBUF2V6G7HHG7J3M3XYSAF57FIN4RN53DTRTU', appIndex: 1003, appArgs: [ '0x23fd2961', '0x8944db7ce5abc02130dcc5bb96ee1c8a7c3a1ee8022b0bfb81b28581764b4695f60dfcaf9ffe2193f538c0df2d43e7b4a9f85a0f4cc12e4dd5d2df8bb0d1f034', '0xd50e00ddaa15a2f5181e46c3910100df4c5808230eef87df14d56ea5a7d40b4a468c5c656f3ec347a5344dc267df2aab6fdc92d711649fe692804c1614b98e47112b67866010c6ac1de6bcf26a51f609', '0x1ea6cbe0dac0d99beb3903648fc155327c93c870c08106a9b66a7b271e7345d3', '0x0000000000000001', '0x0000000000000002', '0x0000000000000003', '0x0000000000000001', '0xb3cf668b6f5b53016300c0f95dbd981ef336588d3753ae4bf77b29132afefb78', '0x55e47eeb0b4579748653a796eace4ac2b87a836e30375e2b1a1bdcc81dce86bf978a7fa15bc7d7446919fe923abdb361de0bdf61252fd8db49e805e0f17ec563000000003b9ab8b8000000e8d4a51000000000000000000a0000000000000000d9fd2c74d7ff4f2eaf66d681a0f53f9368213eac7b75719ad7aa2e96461d2a5a80', '0x0000000000000004' ], accounts: [ 'YHZYUAYUIYNXFMLK5WZ7PYGHVQUIEYULHAKGF5MCYSG76OYP2TYT2WQZRM', '3ACWF4HKPTGU555RKFF6KETS56EOEBO4OSL4BTS46XDHHIHPTNOBY4TRSU', 'TRWQJHM24P64L2XY35IFCQ4DXGMBBVKB5VP6IVDRSQYN22R2VTBHTR7JB4', '3H6SY5GX75HS5L3G22A2B5J7SNUCCPVMPN2XDGWXVIXJMRQ5FJNAF6XE4Y' ], foreignApps: [ 1009 ], boxes: [ { appIndex: 1003, name: '0xb3cf668b6f5b53016300c0f95dbd981ef336588d3753ae4bf77b29132afefb78' }, { appIndex: 1003, name: '0x55e47eeb0b4579748653a796eace4ac2b87a836e30375e2b1a1bdcc81dce86bf' }, { appIndex: 1009, name: '0x978a7fa15bc7d7446919fe923abdb361de0bdf61252fd8db49e805e0f17ec563' } ], onComplete: 0 }
   2023-12-10T20:46:55.407Z DEBUG Blockchain-voting on "JHPCPIL4BP2GN5F7PQRAJEC6MBRHYMVALUZMMDZL7AWXGNZZATWA", seed: "0x1ea6cbe0dac0d99beb3903648fc155327c93c870c08106a9b66a7b271e7345d3" (real), VRF proof: "0xd50e00ddaa15a2f5181e46c3910100df4c5808230eef87df14d56ea5a7d40b4a468c5c656f3ec347a5344dc267df2aab6fdc92d711649fe692804c1614b98e47112b67866010c6ac1de6bcf26a51f609", VRF result: "0x8944db7ce5abc02130dcc5bb96ee1c8a7c3a1ee8022b0bfb81b28581764b4695f60dfcaf9ffe2193f538c0df2d43e7b4a9f85a0f4cc12e4dd5d2df8bb0d1f034", request round: "81754", round window: "81755" - "81764"
   2023-12-10T20:46:55.418Z DEBUG Calling "voting#1009.vote" by "YHZYUAYUIYNXFMLK5WZ7PYGHVQUIEYULHAKGF5MCYSG76OYP2TYT2WQZRM", id: "68b5c889528b142a", args: { suggestedParams: { flatFee: true, fee: 2000, firstRound: 81755, lastRound: 81764, genesisID: 'sandnet-v1', genesisHash: 'RXrzSgzbMh2FXnMJPwqL2UGeyIdbiks2G1oUvDS7fA8=', minFee: 1000 }, method: 'vote', methodArgs: [ '0x8944db7ce5abc02130dcc5bb96ee1c8a7c3a1ee8022b0bfb81b28581764b4695f60dfcaf9ffe2193f538c0df2d43e7b4a9f85a0f4cc12e4dd5d2df8bb0d1f034', '0xd50e00ddaa15a2f5181e46c3910100df4c5808230eef87df14d56ea5a7d40b4a468c5c656f3ec347a5344dc267df2aab6fdc92d711649fe692804c1614b98e47112b67866010c6ac1de6bcf26a51f609', '0x408f580000000000', '0x4097b00000000000', '0xea1f43d7', '0xcfde068196d23ec21e739eb94d1bb44de9243bd0747024d7d8ae730686b0d675', '0x334143574634484b50544755353535524b4646364b4554533536454f45424f344f534c34425453343658444848494850544e4f42593454525355', '0x3ff0000000000000', '0x49de27a17c0bf466f4bf7c2204905e60627c32a05d32c60f2bf82d73373904eccfde068196d23ec21e739eb94d1bb44de9243bd0747024d7d8ae730686b0d67500500063000000000000000000000000001101000000000000000600000000000000290000', '0x41cdcd6da4000000', '0x3ff0000000000000', '0x00' ], note: '', appID: 1009, sender: 'YHZYUAYUIYNXFMLK5WZ7PYGHVQUIEYULHAKGF5MCYSG76OYP2TYT2WQZRM', boxes: [ { appIndex: 1009, name: '0xd80562f0ea7ccd4ef7b1514be51272ef88e205dc7497c0ce5cf5c673a0ef9b5c' }, { appIndex: 1009, name: '0xa55bf54aa9d489c3395a844d7476efd08296875951191e1b96f35a3cd69a6981' } ], appAccounts: [], appForeignApps: [], appForeignAssets: [], lease: '0x49de27a17c0bf466f4bf7c2204905e60627c32a05d32c60f2bf82d73373904ec' }
   2023-12-10T20:47:01.326Z INFO  Submitted 1000004424 vote(s) on request "JHPCPIL4BP2GN5F7PQRAJEC6MBRHYMVALUZMMDZL7AWXGNZZATWA"


If you see log messages with the ``INFO`` prefix, but none with ``DEBUG``, then
you have not enabled debug logging and need to ensure that you have followed the
instructions in the beginning of this section properly. When running an observer
node with no stake, it is normal not to see messages after "Using seed...".

Issues with Gora customer applications often crop up at this stage. These are
most frequently caused by errors in Gora request encoding or data source
specification.

In case of incorrectly encoded request, the node will fail to decode the request
correctly and log an error message beginning with ``Error parsing request...``.
Make sure you are encoding the request ABI type properly, consulting examples in
`Developer Quick Start <https://github.com/GoraNetwork/developer-quick-start>`_
if necessary.

For problems with data sources, examine log messages after ``Querying....``.  If
there are no errors reported, check debug messages carefully to make sure that
data source URLs queried are correct, the content returned is valid and data
extraction expressions are matching it as intended. Currently nodes have no way
of explicitly reporting failures to customer smart contracts and will simply
return an empty result in most scenarios.

==============================================
Diagnosing issues with destination application
==============================================

The last phase of processing where a Gora request can fail starts when node
voting concludes in consensus and a call is made to the destination smart
contract. This may happen because customer's destination app is either specified
incorrectly or fails during processing of Gora response.

The destination call is always initiated by just one Gora node. In multi-node
Gora networks, it is not possible to reliably predict which one it will be, so
one cannot rely on node logs in the this (most common) scenario. The recommended
way of debugging such issues is using `Developer Quick Start <https://github.com/GoraNetwork/developer-quick-start>`_.
It provides a local development network with a single node, making the
destination call logs always available.

If your application is failing at this stage, examine the error folllowing
``Calling "voting#...`` message in your local development node logs. An error
occuring inside your destination application will be reported in typical
Algorand smart contract error format. Bear in mind, that the destination call is
made in an inner transaction inside Gora voting smart contract and interpret
TEAL source context accordingly.

To mininize risks of making error in repsonse handling, we recommend using Gora
Python library available as a `PIP package <https://pypi.org/project/gora/>`_.

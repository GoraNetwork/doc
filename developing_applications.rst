
#################################
Developing applications with Gora
#################################

Customer applications interact with Gora by calling Gora smart contracts. On
EVM-compatible networks, smart contracts are almost always written in `Solidity
<https://soliditylang.org/>`_ , so this is the language we use in our
documentation and examples. For a quick hands-on introduction, see `Gora source
code examples <https://github.com/GoraNetwork/phoenix-examples/>`_.  For a more
complete overview as well as an API reference, read on.

************
Calling Gora
************

Gora functionality is accessed by calling *methods* of Gora *main smart
contract*. To get started, you need Gora main contract address for the
blockchain network that you are going to use. The preferred way to find it is to
check the home page of Gora Explorer for the network in question. For example,
`Gora Explorer for Base mainnet <https://mainnet.base.explorer.gora.io/>`_. Gora
main contract address is shown next to "Gora App" label.

With Gora main contract address, you can create a Gora API Solidity object
in your smart contract and start making Gora calls. For example, read total
amount of tokens currently staked in this Gora network:

.. code:: solidity

  address constant goraMainAddr = address(0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa);
  Gora gora = Gora(goraMainAddr);
  uint totalStake = gora.totalStake();

*The above is an excerpt, for complete working examples see*
`Gora source code examples <https://github.com/GoraNetwork/phoenix-examples/>`_.

**********************
Requesting oracle data
**********************

Oracle data is requested from Gora by calling `request` method of Gora main smart
contract. In its simplest form, it takes the following positional arguments:

=========== ========= ===========
Argument #  ABI Type  Description
=========== ========= ===========
0           string    Data source specification
1           bytes     Data source parameter
2           string    Destination specification
=========== ========= ===========

For example:

.. code:: solidity

  bytes32 reqId = gora.request("http://example.com/mydata", bytes("substr:0,2"), "myMethod")

More precisely, Gora `request` method arguments have the following meanings:

:Data source specification:
  Specifies the data source and method to access it. It has the structure of a
  standard URL, e.g. `http://some-source.example.com/some_data.json`.
  Besides HTTP(S), request URLs may use Gora-specific access protocols. For
  example, `gora://classic/1` specifies test source that always returns `1`,
  without querying external endpoints.

:Data source parameter:
  For sources that are not *special* (i.e. do not begin with ``gora://``) this
  parameter contains a *value extraction specification*. It describes how
  oracle-returned value is to be extracted from data provided by the source. For
  example, with a JSON endpoint that returns ``{ "score": 123 }`` one
  would specify: ``jsonpath:$.score``. Gora supports a number of value extraction
  options which will be explained in detail below.  Special Gora sources will be
  described separately.

:Destination specification:
  Contains the name of the method in customer's smart contract to be called
  with the oracle return value. Gora returns oracle value by calling the same
  customer's smart contract that that requested it.

**Return value** of the `request` method is a unique identifier for the
created request. It is necessary to map returned oracle values to requests
when making multiple oracle calls, to manipulate created requests or to access
their properties.

*********************
Receiving oracle data
*********************

After your Gora request is created and committed to public blockchain, it should
be picked up and processed by Gora nodes in short order. Data extracted by nodes
according to your specifications will be put through consensus by Gora smart
contracts. On successful verification, Gora main smart contract will call the
method you specified in your request and provide the resulting value. Your
data-receiving method must only accept two arguments:

===========  =========  ============
Argument #   ABI Type   Description
===========  =========  ============
0            bytes32    Request ID
1            bytes      Oracle value
===========  =========  ============

Namely:

:Request ID:
  identifier of Gora request for which the value provided is the
  response. You smart contract will likely want to use it to determine which of
  the Gora requests made previously this response applies to.

:Oracle value:
  value returned by the oracle, as a byte string. Numeric values will be
  provided as their string representaitons, e.g. "0.1234", "-12". It will
  be down to receiving smart contract to convert them to Solidity numeric
  types if they need. Strings are returned as is.

**********************************
Value extraction specifications
**********************************

Gora users most often want a specific piece of data source output, so they must
be able to tell Gora how to extract it. This is what a Gora value extraction
specification does. It consists of up to three parts, separated by colon:
method, expression and an optional rounding modifier. For example, `substr:4,11`
tells Gora that it needs to return a substring from data source output, starting
at 4th and ending at 11th character.

Gora supports the following value extraction methods and expression formats:

jsonpath
  | JSONPath expression, see: https://datatracker.ietf.org/doc/draft-ietf-jsonpath-base/
  | Example: ``jsonpath:jsonpath:$.data.temperature``

xpath
  | XPath expression, see: https://www.w3.org/TR/2017/REC-xpath-31-20170321/
  | Example: ``xpath:/p/a``

regex
  | JavaScript regular expression, see: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
  | Example: ``regex: the magic number is ([0-9]+)``

substr
  | Substring specification, start and end offsets, e.g. `substr:4,11`
  | Example: ``substr:0,10``

bytes
  | Same as substring specification, but operates on bytes rather than characters
  | Example: ``bytes:2,4``


An optional rounding modifier is used to round floating-point values to certain
amount of digits after the point. This may be necessary with some types of
values such as cryptocurrency exchange rates. They can be so volatile that
different Gora nodes are likely to get slightly different results despite
querying them at almost the same time. That would prevent the nodes from
achieving consensus and confirming the value as authentic. Adequate rounding
gets us around this issue.

For instance, if you specify ``jsonpath:$.rate:3``, the responses
``{ "rate": 1.2344 }`` and ``{ "rate": 1.2342 }`` that may be received by
different Gora nodes will yield the same value ``"1.234"``. The nodes will
achieve consensus and you will get ``"1.234"`` as the resulting oracle value.

Rounding only affects fractional part of the rounded number, all whole part
digits are preserved.  For example, if rounding parameter is set to ``4``, the
number ``1.12345`` will be rounded to ``1.1234``; but, for exmaple, the number
``12345678`` will remain unaffected.

***************************
Using off-chain computation
***************************


.. figure:: off_chain.svg
   :width: 400
   :align: right
   :alt: Gora off-chain computation workflow diagram

   Gora off-chain computation workflow

For use cases that require more flexibility, Gora supports oracle requests that
execute user-supplied `Web Assembly <https://webassembly.org/>`_ to produce an
oracle value. This enables querying of data sources determined at runtime and
processing their outputs in arbitrary ways. The user-supplied code is executed
off-chain by Gora nodes and is subject to resource limits.

To make use of this feature, developers write their off-chain programs utilizing
Gora off-chain API. Any language that compiles to Web Assembly may be used. We
recommend C language due to its simplicity and ubiquity, and `Clang compiler
<https://clang.llvm.org/>`_ because of it can generate Web Assembly binaries
directly. E.g.:

.. code:: bash

  $ clang example.c -Os --target=wasm32-unknown-unknown-wasm -c -o example.wasm

Compiled binary is then encoded as `Base64Url` (URL-safe variant of Base64) and
included with the request to a special URL defined by Gora to handle off-chain
computation requests. In simpler form, where web assembly executable binary is
provided in smart contract source code, this URL has the following format:
``gora://offchain/v<API version>/basic?body=<Base64Url-encoded WASM binary>[optional positional arguments]``.

The executable body can also be supplied in binary form as the *data source
parameter*. Which is more convenient for larger executables or automated builds.
In that case, the ``body`` data source URL parameter is omitted.

Current Gora offchain API version is ``0``. So, for example, to execute your
program with two positional arguments (``"red"`` and ``"apple"``) you would
specify the following URL:
``gora://offchain/v0/basic?arg=red&arg=apple&body=AGFzbQEAAAABhoCAg...``

To convert binaries into Base64URL encoding, you can use ``basenc``
command-line utility, normally included with Linux and MacOs:

.. parsed-literal::
   :class: terminal

   $ basenc --base64url example.wasm
   AGFzbQEAAAABhoCAgAABYAF/AX8CuoCAgAACA2Vudg9fX2xpbmVhcl9tZW1vcnkCAAEDZW52GV9f
   aW5kaXJlY3RfZnVuY3Rpb25fdGFibGUBcAAAA4KAgIAAAQAHjICAgAABCGdvcmFNYWluAAAMgYCA
   gAABCpGAgIAAAQ8AIABBgICAgAA2AghBAAsLk4CAgAABAEEACw1IZWxsbyB3b3JsZCEAAMKAgIAA
   B2xpbmtpbmcCCJuAgIAAAgCkAQAJZ29yYV9tYWluAQIGLkwuc3RyAAANBZKAgIAAAQ4ucm9kYXRh
   Li5MLnN0cgABAJGAgIAACnJlbG9jLkNPREUFAQQGAQAApoCAgAAJcHJvZHVjZXJzAQxwcm9jZXNz
   ZWQtYnkBBWNsYW5nBjE2LjAuNgCsgICAAA90YXJnZXRfZmVhdHVyZXMCKw9tdXRhYmxlLWdsb2Jh
   bHMrCHNpZ24tZXh0
   $

To reduce blockchain storage use, you can apply Gzip compression before
encoding:

.. parsed-literal::
   :class: terminal

   gzip < example.wasm | basenc --base64url

Gora will automatically recognize and decompress gzipped Web Assembly binaries.

******************************
Gora off-chain computation API
******************************

Web Assembly programs supplied with off-chain computation requests interact with
host Gora nodes via a simple API. It provides functions to setup and initiate
HTTP(s) requests, or write log messages. It also includes a persistent data
structure to share data with the host node or between *steps* of your
program. *Steps* are essentially repeated executions of the program in course of
serving the same off-chain computation request. They are necessary because Web
Assembly programs cannot efficiently pause while waiting to receive data from
external sources such as network connections.

A *step* starts when the program's *main function* is called by the executing
Gora node and ends when this function returns. During a step, the program can
schedule HTTP(S) requests, possibly using URL templates that it can fill at run
time. When the step ends, these requests are executed by the Gora node. On their
completion, the next step commences and your program can access request results
as well as other data provided by the Gora node via current *context* structure.
The *context* persists for the duration of executing your off-chain computation
request. Finishing a step, the program returns a value which tells the Gora node
what to do next: execute another step, finish successfully or terminate with a
specific error code.

For the list of valid return values, see
`gora_off_chain.h <https://github.com/GoraNetwork/phoenix-examples/blob/main/gora_off_chain.h>`_.
header file. To learn how Gora Off-Chain API is used in practice and its execution
model, please consider `Gora source code examples <https://github.com/GoraNetwork/phoenix-examples/>`_.

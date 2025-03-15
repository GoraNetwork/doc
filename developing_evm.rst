#####################
Classic oracle on EVM
#####################

Classic oracle is the original Gora product designed to query any type of data
source. On EVM-compatible networks, smart contracts are almost always written in
`Solidity <https://soliditylang.org/>`_ , so this is the language we will use.
For a quick hands-on introduction, see `Gora source code examples
<https://github.com/GoraNetwork/phoenix-examples/>`_.  For a more complete
overview as well as an API reference, read on.

**********************
Requesting oracle data
**********************

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
  :number-lines:

  address constant goraMainAddr = address(0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa);
  Gora gora = Gora(goraMainAddr);
  uint totalStake = gora.totalStake();

Oracle data is requested from Gora by calling `request` method of Gora main smart
contract. In its simplest form, it takes the following positional arguments:

.. table::
  :class: args

  =========== ========= ===========
  Argument #  ABI Type  Description
  =========== ========= ===========
  0           string    Data source specification
  1           bytes     Data source parameter
  2           string    Destination specification
  =========== ========= ===========

For example:

.. code:: solidity
  :number-lines:

  bytes32 reqId = gora.request("http://example.com/mydata", bytes("substr:0,2"), "myMethod")

More precisely, Gora `request` method arguments have the following meanings:

Data source specification
  Specifies the data source and method to access it. It has the structure of a
  standard URL, e.g. `http://some-source.example.com/some_data.json`.
  Besides HTTP(S), request URLs may use Gora-specific access protocols. For
  example, `gora://classic/1` specifies test source that always returns `1`,
  without querying external endpoints.

Data source parameter
  For sources that are not *special* (i.e. do not begin with ``gora://``) this
  parameter contains a `value extraction specification <#value-extraction>`_.
  It describes how oracle-returned value is to be extracted from data provided
  by the source. For example, with a JSON endpoint that returns ``{ "score": 123
  }`` one would specify: ``jsonpath:$.score``. Gora supports a number of value
  extraction options which will be explained in detail below.  Special Gora
  sources will be described separately.

Destination specification
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

.. table::
  :class: args

  ===========  =========  ============
  Argument #   ABI Type   Description
  ===========  =========  ============
  0            bytes32    Request ID
  1            bytes      Oracle value
  ===========  =========  ============

Namely:

Request ID
  identifier of Gora request for which the value provided is the response. You
  smart contract will likely want to use it to determine which of the Gora
  requests made previously this response applies to.

Oracle value
  value returned by the oracle, as a byte string. Numeric values will be
  provided as their string representaitons, e.g. "0.1234", "-12". It will
  be down to receiving smart contract to convert them to Solidity numeric
  types if they need. Strings are returned as is.

***************************
Using off-chain computation
***************************

.. figure:: off_chain.svg
   :width: 650
   :align: left
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

.. parsed-literal::
   :class: terminal

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

For the list of valid return values, see `gora_off_chain.h`_.
header file. To learn how Gora Off-Chain API is used in practice and its execution
model, please consider `Gora source code examples <https://github.com/GoraNetwork/phoenix-examples/>`_.

.. _dqs-evm:

***************************
Developer Quick Start (EVM)
***************************

`Developer Quick Start (EVM)`_ is a package of code examples and scripts to help
developers start using Gora from their EVM blockchain applications.  It
contains:

 * Instructions on how to setup and use a local Gora development environment
 * Example applications, also usable as templates
 * Solidity compiler and EVM node binaries

=================
Solidity examples
=================

The following extensively commented examples are provided as hands-on
documentation and potential templates for your own  applications:

 * `example_basic.sol <https://github.com/GoraNetwork/developer-quick-start/blob/main/evm/example_basic.sol>`_ -
   querying arbitrary HTTP JSON endpoints

 * `example_off_chain.sol <https://github.com/GoraNetwork/developer-quick-start/blob/main/evm/example_off_chain.sol>`_ -
   getting data from multiple APIs and processing it with off-chain computation

.. note:: **NOTE** If you are not too experienced with Solidity, or just want to
          run Gora examples or experiment modifying them, please skip to the
          next section.

Consider source code examples linked in the previous section. Integrate the APIs
exposed in them into your own smart contracts, or deploy an example using your
preferred setup, then modify it to build your app. For deployment, supply *Gora
main smart contract address* as the first argument to the constructor, depending
on the public network you are deploying to:

  * Base Sepolia: ``0xcb201275cb25a589f3877912815d5f17f66d4f13``
  * Base Mainnet: ``0xd4c99f88095f32df993030d9a6080e3be723f617``

Once deployed, your smart contract should be able ready to issue Gora requests
and receive Gora responses. For Base Sepolia, there is currently no fee for Gora
requests. For Base Mainnet, you must have some Gora tokens on the querying
account's balance to pay for requests.

.. note:: **NOTE** To develop your own applications with Gora and to deploy them to
          production networks, you are expected to use tools of your own
          choice. Gora does not try to bind you to any specific EVM toolchain.

========================================
Setting up local development environment
========================================

Following the steps below will set you up with a complete environment for
compiling and deploying Gora smart contract examples.

1. Check operating system compatibility

   Open a terminal session and execute: `uname`. If this prints out `Linux`,
   continue to the next step. If the output is anything else, you may proceed
   at your own risk, but with a non-Unix OS you will almost certainly fail.

2. Clone this repository

   Install [Git](https://git-scm.com/) if not already done so, then run:

   .. parsed-literal::
      :class: terminal

      git clone https://github.com/GoraNetwork/developer-quick-start

   You should get an output like:

   .. parsed-literal::
      :class: terminal

      Cloning into 'developer-quick-start'...
      remote: Enumerating objects: 790, done.
      remote: Counting objects: 100% (232/232), done.
      remote: Compressing objects: 100% (145/145), done.
      remote: Total 790 (delta 156), reused 159 (delta 85), pack-reused 558 (from 1)
      Receiving objects: 100% (790/790), 67.78 MiB | 1.43 MiB/s, done.
      Resolving deltas: 100% (469/469), done.

3. Change to EVM subdirectory and install NPM dependencies

   Execute the following commands:

   .. parsed-literal::
      :class: terminal

      cd developer-quick-start/evm
      npm i

   You should then see something like this:

   .. parsed-literal::
      :class: terminal

      added 9 packages, and audited 10 packages in 3s
      3 packages are looking for funding
        run `npm fund` for details
      found 0 vulnerabilities

      If no errors popped up, proceed to the next step.

4. Setup target blockchain network

   .. warning:: **IMPORTANT!** Examples can be run on either local built-in
                blockchain network, or a public network such as `Base Sepolia
                <https://sepolia.basescan.org/>`_. We generally recommend using
                the local network for development and trying things out. But for
                users who do not want to install `Docker`_ have a funded public
                network account and are OK with longer deploy/test iterations,
                the public network option may be preferable.

   Option A: Use local development blockchain network
     Run ``./start_dev_env``. The script will start up, displaying log output from
     local EVM nodes as well as local Gora node. It must be running while you deploy
     and run the example scripts. It is the default configuration for running
     examples, so no additional setup will be necessary. To terminate the script,
     ending the development session, hit, ``Ctrl-C``.

   Option B: Use a public network
     Public network configuration is set via environment variables. For example, to
     use Base Sepolia you would execute:

     .. parsed-literal::
        :class: terminal

        export GORA_EXAMPLE_EVM_MAIN_ADDR=0xcb201275cb25a589f3877912815d5f17f66d4f13
        export GORA_EXAMPLE_EVM_API_URL=https://sepolia.base.org
        export GORA_EXAMPLE_EVM_KEY=./my_base_sepolia_private_hex_key.txt

     ``./my_base_sepolia_private_hex_key.txt`` is the example path to a text file
     containing private key for the account you want to use for deployment, in hex
     form. It can usually be found in account tools section of wallet software such
     as Metamask.

     The environment variables will be picked up by the example-running script
     discussed below. It should be possible to deploy example scripts to any public
     EVM network using this method. Deploying to a mainnets is, however, strongly
     discouraged for security reasons.

==================================
Running and modifying the examples
==================================

If using local development environment (option 1 in step 4 above), open another
terminal window and change to the same directory in which you started the setup
script. For public network configurtion (option 2 in step 4), please remain in
the same terminal session.

Then execute:

.. parsed-literal::
   :class: terminal

   ./run_example basic

or

.. parsed-literal::
   :class: terminal

   ./run_example off_chain

This should compile, deploy and run the example, providing detailed information
on the outcome. For further details, consider `Solidity examples <#solidity-examples>`_.
You are welcome to modify the examples source code and try it repeating the step
above.

==========================================
Composition of the development environment
==========================================

Gora EVM local development environment relies on the following pieces of software:

 * Solidity compiler (``solc`` binary). Used to compile examples and potentially
   developer's own code.

 * Geth EVM node software (``geth`` binary). Provides local blockchain
   functionality to model master (L1) and slave (L2) EVM networks. Both
   instances of Geth are run in development mode (with ``--dev`` switch).
   Hardhat is not used because it has shown issues with multiple concurrent
   connections and was lagging behind recent Ethereum forks feature-wise.

 * Gora smart contracts (files with ``.compiled`` extension), already compiled
   into combined JSON format.

``start_dev_env`` script starts Geth instance, deploys Gora smart contracts and
stays in the foreground, displaying log messages from the above as they come.
Contrary to Gora Developer Quick Start package for Algorand, it must be running
at all times to run Gora smart contracts locally. There is no way to start a
Gora node or its local blockchain on-demand on per-example basis.  To end your
development session and terminate the script, hit Ctrl-C in the terminal window
running it.

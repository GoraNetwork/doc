## About Gora

[Gora](https://gora.io/ "Gora official website") enables blockchain programs
(smart contracts) to interact with the outside world. Getting financial
information from high-quality providers, extracting arbitrary data from public
pages, calling online APIs or running Web Assembly code off-chain - is all made
possible by Gora. To maintain security and trust, Gora relies on
decentralization.  A network of independent Gora nodes executes requested
operations in parallel and certifies the outcome via reliable consensus
procedure. This document is aimed at developers working with EVM-compatible
blockchains that already use Gora, or companies interested in adding Gora
capabilities to a blockchain they manage. Therefore it will focus on developer
experience as well as technical description of the current Gora offering. For
help on running Gora nodes or development on the Algorand platform, please
refer to Gora legacy documentation.

|**Gora structure and workflow overview**|
|:--:|
|<img src="overview.svg" width="500">|

## Developing with Gora on EVM-compatible blockchains

Customer applications interact with Gora by calling Gora smart contracts. On
EVM-compatible networks, smart contracts are almost always written in
[Solidity](https://soliditylang.org/), so this is the language we will use in
our documentation and examples. For a quick hands-on introduction to using Gora
from your Solidity programs, skip to [Included Solidity examples](#included-solidity-examples).
For a more complete overview as well as API reference, read on.

### Calling Gora

Gora functionality is accessed by calling *methods* of the main Gora smart
contract. To get started with it, you will need *Gora main contract address* for
the blockchain network that you are going to use. The preferred way to find it
is by running `info` command of Gora CLI tool, for example (with irrelevant
output removed):

```
$ ./gora info
...
EVM chain "baseSepolia":
  ...
  Gora main contract: "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  ...
EVM chain "baseMainnet":
  ...
  Gora main contract: "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
...
$
```

Another method, that does not require any tools, is to check the home page of
Gora Explorer for the network in question. For example,
[Gora Explorer for Base mainnet](https://mainnet.base.explorer.gora.io/).
Gora main contract address is shown next to "Gora App" label. The downside
of this method is that it will not work for developer's test networks that may
be running locally or publically alongside official ones.

Armed with Gora main contract address, you can create a Gora API Solidity object
in your smart contract and start making Gora calls. For example, read total
amount of tokens currently staked in this Gora network:

```
  address constant goraMainAddr = address(0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa);
  Gora gora = Gora(goraMainAddr);
  uint totalStake = gora.totalStake();
```
*The above is an excerpt, for a complete working example see [Included Solidity examples](#included-solidity-examples).*

### Requesting oracle data

Oracle data is requested from Gora by calling `request` method of Gora main smart
contract. In its simplest form, it takes the following positional arguments:

|Argument #    |ABI Type           |Description
|--------------|-------------------|------------------------------------------|
| 0            |`uint`             |Request type                              |
| 1            |`string`           |Data source specification                 |
| 2            |`string`           |Value extraction expression               |
| 3            |`string`           |Destination specification                 |

For example: `bytes32 reqId = gora.request(4, "http://example.com/mydata", "substr:0,2", "myMethod")`
More precisely, Gora `request` method arguments have the following meanings:

**Request type** - identifies the type of request among types pre-defined by
Gora. Currently only value of `4` ("Simple URL") is recommended for customer
use.

**Data source specification** - specifies the data source and method to access
it. For "Simple URL" requests, it has the structure of a standard URL, e.g.
`http://some-source.example.com/some_data.json`. Besides HTTP(S), request URLs
may use Gora-specific access protocols. For example, `gora://classic/1`
specifies test source that always returns `1`, without querying external
endpoints.

**Value extraction expression** - describes how oracle-returned value is to be
extracted from data provided by the source. For example, with a JSON source that
returns `{ "score": 123 }` one would specify: `jsonpath:$.score`. Gora supports
a number of value extraction options which will be explained in detail below.

**Destination specification** - contains the name of the method in customer's
smart contract to be called with the oracle return value. For "Simple URL"
requests, Gora will always return orale value by calling the same customer's
smart contract that that requested it.

**Return value** of the `request` method is a unique identifier for the
created request. It is necessary to map returned oracle values to requests
when making multiple oracle calls, to manipulate created requests or to access
their properties.

### Receiving oracle data

After your Gora request is created and committed to public blockchain, it should
be picked up and processed by Gora nodes in short order. Data extracted by nodes
according to your specifications will be put through consensus by Gora smart
contracts. On successful verification, Gora main smart contract will call the
method you specified in your request and provide the resulting value. For
"Simple URL" requests, which are considered in this document, your
data-receiving method must only accept two arguments:

|Argument #    |ABI Type           |Description
|--------------|-------------------|------------------------------------------|
| 0            |`bytes32`          |Request ID                                |
| 1            |`bytes`            |Oracle value                              |

Namely:

**Request ID** - identifier of Gora request for which the value provided is the
response. You smart contract will likely want to use it to determine which of
the Gora requests made previously this response applies to.

**Oracle value** - value returned by the oracle, as a byte string. For "Simple
URL" requests, numeric values will be provided as their string representaitons,
e.g. "0.1234", "-12". It will be down to receiving smart contract to convert
them to Solidity numeric types if they need. Strings are returned as is.

### Data extraction specifications

Gora users most often want a specific piece of data source output, so they must
be able to tell Gora how to extract it. This is what a Gora data extraction
specification does. It consists of up to three parts, separated by colon:
method, expression and an optional rounding modifier. For example, `substr:4,11`
tells Gora that it needs to return a substring from data source output, starting
at 4th and ending at 11th character. Gora supports the following data extraction
methods and expression formats:

 * `jsonpath`: JSONPath expression, see: https://datatracker.ietf.org/doc/draft-ietf-jsonpath-base/
 * `xpath`: XPath expression, see: https://www.w3.org/TR/2017/REC-xpath-31-20170321/
 * `regex`: JavaScript regular expression, see: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
 * `substr`: substring specification, start and end offsets, e.g. `substr:4,11`
 * `bytes`: same as substr, but operates on bytes rather than characters

An optional rounding modifier is used to round floating-point values to certain
amount of digits after the point. This may be necessary with some types of
values such as cryptocurrency exchange rates. They can be so volatile that
different Gora nodes are likely to get slightly different results despite
querying them at almost the same time. That would prevent the nodes from
achieving consensus and confirming the value as authentic. Adequate rounding
gets us around this issue.

For example, if you specify `jsonpath:$.rate:3`, the responses
`{ "rate": 1.2345 }` and `{ "rate": 1.2344 }` that may be received by different
Gora nodes will yield the same value `"1.234"`. The nodes will achieve consensus
and you will get `"1.234"` as the resulting oracle value. Rounding only affects
the fractional part of the rounded number, all integer digits are always
preserved. For example, if rounding parameter is set to `7`, the number
`123890.7251` will be rounded to `123890.7`, but the number `98765430` will
remain unaffected.

### Off-chain computation requests

For use cases that require more flexibility, Gora supports oracle requests that
execute user-supplied [Web Assembly](https://webassembly.org/) code to produce
an oracle value. This enables querying of data sources determined at runtime and
processing their outputs in arbitrary ways. The user-supplied code is executed
off-chain by Gora nodes and is subject to resource limits.

To make use of this feature, the developer must write their off-chain program
using Gora off-chain API in any language that compiles to Web Assembly. Compiled
binary is then included with the request as a parameter to a special URL.

To included with a Web Assembly binary in a Gora off-chain request, you must
first be encoded using `Base64`, e.g.:

```
$ base64 example_off_chain_basic.wasm
AGFzbQEAAAABhoCAgAABYAF/AX8CuoCAgAACA2Vudg9fX2xpbmVhcl9tZW1vcnkCAAEDZW52GV9f
aW5kaXJlY3RfZnVuY3Rpb25fdGFibGUBcAAAA4KAgIAAAQAHjICAgAABCGdvcmFNYWluAAAMgYCA
gAABCpGAgIAAAQ8AIABBgICAgAA2AghBAAsLk4CAgAABAEEACw1IZWxsbyB3b3JsZCEAAMKAgIAA
B2xpbmtpbmcCCJuAgIAAAgCkAQAJZ29yYV9tYWluAQIGLkwuc3RyAAANBZKAgIAAAQ4ucm9kYXRh
Li5MLnN0cgABAJGAgIAACnJlbG9jLkNPREUFAQQGAQAApoCAgAAJcHJvZHVjZXJzAQxwcm9jZXNz
ZWQtYnkBBWNsYW5nBjE2LjAuNgCsgICAAA90YXJnZXRfZmVhdHVyZXMCKw9tdXRhYmxlLWdsb2Jh
bHMrCHNpZ24tZXh0
$
```

To reduce blockchain storage use, you can apply Gzip compression before
encoding: `gzip < example_off_chain_basic.wasm | base64`. Gora will automatically
recognize and decompress gzipped binaries.

The resulting base64 string is then supplied as an URL parameter named "inline":
`gora://offchain?inline=AGFzbQEAAAABhoCAgAABYAF/AX8CuoCAgAACA2Vudg9fX2xpbmVhcl9tZW1vcnkCAAEDZW52GV9faW5kaXJlY3RfZnVuY3Rpb25fdGFibGUBcAAAA4KAgIAAAQAHjICAgAABCGdvcmFNYWluAAAMgYCAgAABCpGAgIAAAQ8AIABBgICAgAA2AghBAAsLk4CAgAABAEEACw1IZWxsbyB3b3JsZCEAAMKAgIAAB2xpbmtpbmcCCJuAgIAAAgCkAQAJZ29yYV9tYWluAQIGLkwuc3RyAAANBZKAgIAAAQ4ucm9kYXRhLi5MLnN0cgABAJGAgIAACnJlbG9jLkNPREUFAQQGAQAApoCAgAAJcHJvZHVjZXJzAQxwcm9jZXNzZWQtYnkBBWNsYW5nBjE2LjAuNgCsgICAAA90YXJnZXRfZmVhdHVyZXMCKw9tdXRhYmxlLWdsb2JhbHMrCHNpZ24tZXh0`

|**Gora off-chain computation workflow**|
|:--:|
|<img src="off_chain.svg" width="500">|

### Off-chain computation API

Web Assembly programs that you supply with Gora off-chain requests, interact
with a Gora node that hosts them via a simple API. It provides functions to
setup, initiate HTTP(s) requests or write log messages. It also includes a
persistent data structure to share data with the Gora node or between *steps* of
your program. *Steps* are essentially repeated executions of the program in
course of serving the same off-chain request. They are necessary because Web
Assembly programs cannot efficiently pause while waiting to receive data from
external sources such as network connections.

A *step* starts when the program's *main function* is called by the executing
Gora node and ends when this function returns. During a step, the program can
schedule HTTP(S) requests, possibly using URL templates that it can fill at run
time. When the step ends, these requests are executed by the Gora node.  On
their completion, the next step commences and your program can access request
results as well as other data provided by the Gora node via current *context*
structure.  The *context* persists for the duration of executing your off-chain
computation request.

Finishing a step, the program returns a value which tells the Gora node what to
do next: execute another step, finish successfully or terminate with a specific
error code. For the list of valid return values, see
[`gora_off_chain.h`](https://github.com/GoraNetwork/developer-quick-start/blob/main/gora_off_chain.h)
header file.

For a hands-on introduction to Gora Off-Chain API and execution model, consider
[Included Solidity examples](#included-solidity-examples).

### Included Solidity examples

The following extensively commented examples are provided as hands-on
documentation and potential templates for your own  applications:

 * [`example_basic.sol`](./example_basic.sol) - querying arbitrary HTTP
   JSON endpoints

 * [`example_off_chain_basic.c`](./example_off_chain_basic.c) - a "Hello world!"
   app using off-Gora chain computation. To compile it, install [Clang](https://clang.llvm.org/)
   C compiler v. 12 or newer and run:
   ```
   clang example_off_chain_basic.c -Os --target=wasm32-unknown-unknown-wasm -c -o example_off_chain_basic.wasm
   ```

 * [`example_off_chain_multi_step.c`](./example_off_chain_multi_step.c) -
   a more advanced off-chain computation example, featuring URL requests and
   asynchronous operations. To compile it, run:
   ```
   clang example_off_chain_multi_step.c -Os --target=wasm32-unknown-unknown-wasm -c -o example_off_chain_multi_step.wasm
   ```

### Instant start for experienced Solidity developers

> [!CAUTION]
> *If you are not too experienced with Solidity, or just want to run Gora examples
> or experiment modifying them, please skip to the next section.*

Consider source code examples linked in the previous section. Integrate the APIs
exposed in them into your own smart contracts, or deploy an example using your
preferred setup, then modify it to build your app. For deployment, supply *Gora
main smart contract address* as the first argument to the constructor, depending
on the public network you are deploying to:

  * Base Sepolia: `0xcb201275cb25a589f3877912815d5f17f66d4f13`
  * Base Mainnet: `0xd4c99f88095f32df993030d9a6080e3be723f617`

Once deployed, your smart contract should be ready to issue Gora requests and
receive Gora responses. For Base Sepolia, there is currently no fee for Gora
requests. For Base Mainnet, you must have some Gora tokens on the querying
account's balance to pay for requests.

> [!NOTE]
> *To develop your own applications with Gora and to deploy them to production
> networks, you are expected to use tools of your own choice. Gora does not try
> to bind you to any specific EVM toolchain.*

### Setting up local development environment

Following the steps below will set you up with a complete environment for
compiling and deploying Gora smart contract examples.

#### 1. Check operating system compatibility

Open a terminal session and execute: `uname`. If this prints out `Linux`,
continue to the next step. If the output is anything else, you may proceed
at your own risk, but with a non-Unix OS you will almost certainly fail.

#### 2. Clone this repository

Install [Git](https://git-scm.com/) if not already done so, then run:
```
$ git clone https://github.com/GoraNetwork/developer-quick-start
```
You should get an output like:
```
Cloning into 'developer-quick-start'...
remote: Enumerating objects: 790, done.
remote: Counting objects: 100% (232/232), done.
remote: Compressing objects: 100% (145/145), done.
remote: Total 790 (delta 156), reused 159 (delta 85), pack-reused 558 (from 1)
Receiving objects: 100% (790/790), 67.78 MiB | 1.43 MiB/s, done.
Resolving deltas: 100% (469/469), done.
$
```

#### 3. Change to EVM subdirectory and install NPM dependencies

Execute the following two commands:
```
$ cd developer-quick-start/evm
$ npm i
```

You should then see something like this:
```
added 9 packages, and audited 10 packages in 3s
3 packages are looking for funding
  run `npm fund` for details
found 0 vulnerabilities
$
```

If no errors popped up, proceed to the next step.

####  4. Setup target blockchain network

> [!IMPORTANT]
> *Examples can be run on either local built-in blockchain network, or a public
> network such as [Base Sepolia](https://sepolia.basescan.org/). We generally
> recommend using the local network for development and trying things out. But
> for users who do not want to install [Docker](https://docker.io/), have a
> funded public network account and are OK with longer deploy/test iterations,
> the public network option may be preferable.*

##### Option 1: Use local development blockchain network

Run `./start_dev_env`. The script will start up, displaying log output from
local EVM nodes as well as local Gora node. It must be running while you deploy
and run the example scripts. It is the default configuration for running examples,
so no additional setup will be necessary. To terminate the script, ending the
development session, hit, `Ctrl-C`.

##### Option 2: Use a public network

Public network configuration is set via environment variables. For example,
to use Base Sepolia you would execute:
```
$ export GORA_EXAMPLE_EVM_MAIN_ADDR=0xcb201275cb25a589f3877912815d5f17f66d4f13
$ export GORA_EXAMPLE_EVM_API_URL=https://sepolia.base.org
$ export GORA_EXAMPLE_EVM_KEY=./my_base_sepolia_private_hex_key.txt
```
`./my_base_sepolia_private_hex_key.txt` is the example path to a text file
containing private key for the account you want to use for deployment,
in hex form. It can usually be found in account tools section of wallet
software such as Metamask.

The environment variables will be picked up by the example-running script
discussed below. It should be possible to deploy example scripts to any public
EVM network using this method. Deploying to a mainnet is, however, strongly
discouraged for security reasons.

#### Running and modifying Solidity examples

If using local development environment (option 1 in step 4 above), open another
terminal window and change to the same directory in which you started the setup
script. For public network configurtion (option 2 in step 4), please remain in
the same terminal session.

Then execute:
```
./run_example basic
```
or
```
./run_example off_chain
```

This should compile, deploy and run the example, providing detailed information
on the outcome. For further details, consider [Included Solidity examples](#included-solidity-examples)
section above. You are welcome to modify the examples source code and try it
repeating the step above.

#### Composition of the development environment

Gora EVM local development environment relies on the following pieces of software:

 * Solidity compiler (`solc` binary). Used to compile examples and potentially
   developer's own code.

 * Geth EVM node software (`geth` binary). Provides local blockchain
   functionality to model master (L1) and slave (L2) EVM networks. Both
   instances of Geth are run in development mode (with `--dev` switch).
   Hardhat is not used because it has shown issues with multiple concurrent
   connections and was lagging behind recent Ethereum forks feature-wise.

 * Gora smart contracts (files with `.compiled` extension), already compiled
   into combined JSON format.

`start_dev_env` script starts Geth instance, deploys Gora smart contracts and
stays in the foreground, displaying log messages from the above as they come.
Contrary to Gora Developer Quick Start package for Algorand, it must be running
at all times to run Gora smart contracts locally. There is no way to start a
Gora node or its local blockchain on-demand on per-example basis.  To end your
development session and terminate the script, hit Ctrl-C in the terminal window
running it.
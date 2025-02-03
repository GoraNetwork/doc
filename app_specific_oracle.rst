##############################
App-specific Oracles with Gora
##############################

App-specific oracle (*ASO*) is an oracle designed to serve a certain web3
application or application type. While a general-purpose oracle strives for
maximum flexibility to support all kinds or applications, it may lack
specialized data processing or access control features needed for more niche use
cases. For example, a sports oracle may want to provide team statistics which
requires getting data from several resources and performing floating-point maths
on it. A private oracle may want to only serve specific smart contracts or
authenticate itself to data sources in a bespoke way.

Gora provides accesible and flexible tools to create your own ASO's and deploy
them to EVM-compatible blockchains of your choice: either public, like Base or
Polygon, or private, which organizations can run internally. Gora does this by
combining its tried and true general-purpose oracle architecture with a powerful
off-chain computation engine. Rather than simply fetching data online and
passing it on for verification, for ASO requests Gora nodes execute *oracle
programs*: tiny pieces of software that implement customizations and extensions
to oracle functionality. Oracle programs are created by customers deploying
ASO's. For simpler cases, this can be done without programming using Gora
web-based code generation tool. When higher levels of customization are
required, oracle programs are written explicitly in C or any language that
compiles to Web Assembly.

***********************************
Gora ASO architecture and workflow
***********************************

[TODO: ASO architecture diagram]

Gora's app-specific oracle relies on two key mechanisms: an ASO smart contract
and an *executor* oracle. ASO smart contract contains oracle program and custom
configuration required by customer for their specific use case. An executor
oracle is a generic and complete oracle engine that implements fundamental
oracle functionality such as distributed node management and consensus
verification. They work together to serve web3 application requests as follows:

* An application smart contract makes a request for an oracle value. It calls
  the ASO smart contract, providing request parameters (if any) and expects a
  call back with a response.

* ASO smart contract combines received parameters with its configuration
  settings and oracle program, making a request to the executor oracle.

* Request to the executor oracle is picked up by decentralized network of nodes.
  Each online node runs the oracle program provided by the ASO smart contract.
  The program queries online data sources, processes received data, performs
  other programmed operations as needed to produce an oracle value.

* The produced value is submitted by each node to the executor smart contract
  for a proof-of-stake consensus verification. Upon reaching the configured
  threshold, the executor contract calls back ASO smart contract with the
  response. The ASO smart contract forwards the response to the application
  smart contract.

Gora provides common shared executors on a number of popular public blockchain
networks. ASO customers just starting out are advised to use these. When data
privacy, extra computing power or control over staking tokenomics is desired,
customers are welcome to setup their own executors using Gora software. ASO
smart contract can switch executors at any time.

***************************
Creating and managing ASO's
***************************

TODO:

 - Gora ASO control panel intro
 - Steps to create a simple ASO
 - What fields in control panel mean and how to set them


************************************************
Oracle programs: generating, writing, testing
************************************************

TODO:

 - Program generator form and how to use it
 - Testing programs before deploying
 - Example C progams and how to use them as templates
 - Writing C programs from scratch with ASO API

******************************************************
Calling app-specific oracles from your smart contracts
******************************************************

TODO:

 - ASO Solidity examples (to be written)
 - Gora ASO Solidity API reference

*********************
Shared Gora executors
*********************

Gora provides shared executors for ASO customer use. These are essentially
generic oracles relying on a decentralized network of nodes for data querying
and validation. Node operators use Gora tokens to make stakes for proof-of-stake
valudation and to receive rewards for fulfilling oracle requests. Customers
using a shared Gora executor must therefore fund their ASO smart contract with
Gora tokens and maintain their balance as they are being spent.

To use a Gora shared executor, set your ASO executor address according to
network being used:

=====================  ============
Blockchain Network     Address
=====================  ============
Base Sepolia           TODO
Base Mainnet           TODO
Polygon Testnet        TODO
Polygon Mainnet        TODO
=====================  ============

When using a testnet, visit `Gora testnet faucet <https://dev.gora.io/faucet>`_
to get tokens for funding your ASO contract.

*********************
Custom executors
*********************

TODO

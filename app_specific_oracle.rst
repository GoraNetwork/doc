##############################
App-specific Oracles with Gora
##############################

App-specific oracle (*ASO*) is an oracle designed to serve a certain web3
application or application type. While a general-purpose oracle strives for
maximum flexibility to support all kinds or applications, it may lack
specialized data processing or access control features needed for more niche use
cases. For example, a sports oracle may want to provide team statistics which
requires getting data from several resources and performing floating-point maths
on it.  A private oracle may want to only serve specific smart contracts or
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

**************************
Architecture of Gora ASO's
**************************

[TODO: ASO architecture diagram]

Gora's app-specific oracle can be viewed as having two essential parts: an ASO
smart contract and an *executor*. ASO smart contract contains an oracle program
and custom configuration required by customer for their specific use case. Its
job is to receive app-specific oracle requests, forward them together with the
oracle program to executor, receive responses from the executor and forward
them back to requester.

An executor is a generic and complete oracle engine that handles fundamentals
such as distributed node support and consensus verification. Customers can
switch executors at any time. This allows for a smooth upgrade path: start with
Gora-provided shared executor and progress to deploying your own when and if
you need. A custom executor can provide extra privacy, computing power or even
means to raise capital when issuing a custom token for oracle node staking and
rewards. Ability to switch executors also comes in handy when creating failover
configurations and helps smoother upgrades.

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

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

For more flexibility and reliability, Gora's app-specific oracles use an
*executor* to fulfill their requests: a more generic oracle engine that handles
oracle fundamentals such as distributed node support and consensus verification.
This allows ASO customers a smooth upgrade path: they can start with
Gora-provided shared executor and progress to deploying their own when and if
they need. A custom executor can provide extra privacy, computing power or even
means to raise capital when issuing a custom token for oracle node staking and
rewards. Abillity to switch executors without chaning the ASO smart contract
also enables failover configurations and smoother upgrades.

*****************************************
Architecture of Gora app-specific oracles
*****************************************

TODO

*****************************
Gora app-specific oracle tool
*****************************

TODO

**********************************
Managing your app-specific oracles
**********************************

TODO

************************************
Creating and testing oracle programs
************************************

TODO

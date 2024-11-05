###############################
Setting up a Gora node network
###############################

Gora is a decentralized blockchain oracle. To produce its values, it relies on a
network of independent blockchain-connected nodes running GNR (Gora Node Runner)
- a dedicated Linux software package developed by Gora. GNR instances pick up
oracle requests from the blockchain, execute them and submit results back to the
blockchain for consensus certification by Gora smart contracts. Gora token
issuance, distribution and staking that are required for consensus to work
properly are beyond the scope of this document. So for the purposes of this
guide, setting up a Gora node network comes down to setting up GNR for each
node operator.

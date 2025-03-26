.. _Docker: https://docker.io/
.. _AWS: https://aws.amazon.com/
.. _AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
.. _Base: https://base.org/
.. _Gora CLI tool: https://download.gora.io/
.. _Algorand Dapp Flow: https://app.dappflow.org/explorer/home
.. _Developer Quick Start: https://github.com/GoraNetwork/developer-quick-start/
.. _Developer Quick Start (EVM): https://github.com/GoraNetwork/developer-quick-start/tree/main/evm
.. _gora_off_chain.h: https://github.com/GoraNetwork/developer-quick-start/blob/main/gora_off_chain.h

.. role:: js(code)
   :language: javascript

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Gora Decentralized Oracle Documentation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. contents::
   :depth: 2

#############
Introduction
#############

`Gora <https://gora.io/>`_ enables blockchain programs (smart contracts) to
interact with the outside world. Getting financial information from high-quality
providers, extracting arbitrary data from public pages, calling online APIs or
running Web Assembly code off-chain - is all made possible by Gora. To maintain
security and trust, Gora relies on decentralization. A network of independent
Gora nodes executes requested operations in parallel and certifies the outcome
via reliable consensus procedure.

.. figure:: overview.svg
   :width: 600
   :align: left
   :alt: Gora structure and workflow overview diagram

   Gora general structure and workflow

Customers interact with Gora in one of three roles: investor, node operator or
smart contract developer. An investor purchases Gora tokens and delegates them
to a node operator, receiving a share of rewards accrued from processing Gora
requests. A node operator stakes Gora tokens (their own or investor's) and runs
Gora Node Runner software to process Gora requests and receive rewards in Gora
tokens. A smart contract developer writes applications that make use of Gora
smart contract API's.

This document is aimed mainly at developers or node operators. Software
engineers working with Gora-enabled blockchains, as well as companies interested
in adding an oracle to blockchains they manage, will find technical information
here.  For Gora node operators, instructions and background information are also
provided. Most recent and relevant products are described first, followed by
info on legacy offerings.

.. include:: app_specific_oracle.rst
.. include:: developing_evm.rst
.. include:: developing_algorand.rst
.. include:: setting_up_network.rst
.. include:: appendix.rst
.. include:: roadmap.rst
.. include:: legacy.rst

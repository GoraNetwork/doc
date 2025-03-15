################################
Legacy documentation (Litepaper)
################################

************
Introduction
************

Gora aims to accelerate the development of dApps that are useful in the day to
day lives of millions of users. Gora will accomplish this by providing the
infrastructure necessary for developers and organizations to build applications
that make use of real world, off-chain data. Furthermore, Gora will enable
developers to build applications that utilize off-chain computation.

In 2022, the number of daily users for decentralized applications surpassed 2.4
million daily users, with several billion dollars in volume. Global uncertainty
has lead to increased adoption of cryptocurrencies, especially in emerging
markets. This increased adoption of cryptocurrencies has familiarized people
with wallets and the mechanics of transacting on-chain. As the general
population becomes more comfortable using decentralized applications, demand for
oracles to provide real world data will see a similar rise.

Along with record numbers of new users, the blockchain space has also seen
record number of hacks and exploits, many of these being through bridges/oracles
hacks and manipulation. This highlights the need for security as a top priority
for any oracle solution such as Gora.

The primary goal of this litepaper is to highlight the organization and backers
of Gora, and to highlight compliance of the protocol. In addition, it will aim
to provide a high level overview of the functioning mechanism of the oracle, and
the types of feeds Gora plans to launch with. This litepaper is accompanied by
an in-depth economic design paper. Technical details of the network will be
released in a future whitepaper closer to the launch date of the protocol.

***************
The Gora Vision
***************

The Gora vision is to deliver an Oracle solution that brings mainstream adoption
to web3, and empower an ecosystem of decentralized applications to solve
real-world user problems.

Our mission is to advance the state-of-the-art in oracle and blockchain
reliability, safety, and performance by providing a flexible and modular oracle
architecture. This architecture should support frequent upgrades, fast adoption
of the latest technology advancements, and first-class support for new and
emerging use cases.

We envision a decentralized, secure, and scalable network governed and operated
by the community that uses it. When infrastructure demands grow, the
computational resources of the oracle network scale up horizontally and
vertically to meet those needs. As new use cases and technological advances
arise, the network should frequently and seamlessly upgrade without interrupting
users. Infrastructure concerns should fade into the background, and security
should be guaranteed without trading off privacy or decentralization.

To achieve this Gora will:

 * Hire and partner with highly skilled computer scientists, cryptographers,
   mathematicians and statisticians, data scientists and more
 * Build a modular application that allows development and upgrades of specific
   modules
 * Work with 2-3 audit firms to review Gora's Code
 * Perform millions of simulations that model the trajectory of the token based
   on starting parameters

*********************
Design Considerations
*********************

==================
Layer 1 vs Layer 2
==================

Oracle services tend to generally build out co-chains or blockchains to be able
to handle requests, and then interface onto one or more blockchains. While this
method allows for growth beyond a single blockchain, the technical
infrastructure required is greater than building specifically for a single
blockchain.

When designing Gora, we made the intentional choice to focus on building an
independent network. Therefore, GoraNetwork may be categorized as a Layer-2
network, with a distributed set of nodes. This means a much faster time to
market, and a greater focus on security by reducing the number of attack vectors
than building GoraNetwork as a Layer 1 network. This does not limit GoraNetwork,
as the distributed nodes can interface with other blockchains as necessary.

=====================
True Decentralization
=====================

Another consideration in the level of decentralization (aka permission to
participate). Although GoraNetwork is not in and of itself a blockchain, it is
very similar in that it is a distributed system of nodes and data providers,
working together to affect the blockchain state - and as such, a level of
permission, if any, needs to be determined.

On one spectrum, an permissioned Oracle service can require knowledge the feed
provider is, and only a select number of these known feed providers to submit
feeds. On the other end of the spectrum, a permissionless service will neither
require nor care who signs up to provide feeds.

In their article “When Permissioned Blockchains Deliver More Decentralization
Than Permissionless” (Bakos et al.)[1], the authors make a compelling argument
that “while distributed architectures may enable open access and decentralized
control, they do not preordain these outcomes…permissionless access may result
in essentially centralized control, while permissioned systems may be able to
better support decentralized control”.  What this means is just because a system
is built to be decentralized and distributed, it will take time to get there,
largely due to malicious forces or large actors with economies of scale taking
over at before the network is able to achieve network effects.

The Gora team believes that decentralizing as much as possible is essential but
agrees with the authors above that some form of permission is necessary,
especially at the beginning. This is implemented via a deposit mechanism, where
Node runners must stake and deposit a certain amount of network tokens to
participate. This raises the barrier to entry, with the goal being to make being
a malicious actor or a poor-quality provider as unattractive as possible.
Furthermore, aggregated data feeds will allow community members to vote in or
vote out feed providers. This way, only feed providers that are institutional
and can guarantee high quality data are allowed to participate (unless the
community decides otherwise).

==================
The Oracle Problem
==================

The oracle problem, at its core, means having to trust an entity in a world that
should be considered trustless. It could be argued that the only real solution
to this problem would be to conduct all activities that an oracle provides onto
the blockchain. For example, if ALGOs were only ever exchanged for USDC
on-chain, and USDC was only ever spent by individuals on chain, the exchange
price of USDC/Algo may be determined on the blockchain, hence solving the oracle
problem. However, basketball cannot be played on the blockchain, nor does the
blockchain have a weather system.

One possible solution might be having everyone watching the game input the score
on the blockchain, but what if the loser of a match has more fans, and feel like
they deserved a penalty? With the advent of social media, coordinated social
‘spamming’ a system can and does go viral such as the ‘Bum rush the charts’
campaign to influence iTunes charts[2], or meme-fueled GameStop buying frenzy
meant mainly to bankrupt large hedge funds[3].

By such definitions, the oracle problem may be considered unsolvable. While a
detailed analysis of the oracle problem is outside the scope of this document,
an alternative to such a strict definition is that as long as data is sourced
from multiple reliable sources, and poor quality or malicious participants stand
to lose much more than they gain (in addition to having a high cost barrier to
entry), the system should remain secure. In fact, almost all major blockchains
are designed as such.

 * [1] Bakos, Yannis and Halaburda, Hanna and Mueller-Bloch, Christoph, When
   Permissioned Blockchains Deliver More Decentralization Than Permissionless
   (September 25, 2019). Communications of the ACM, Available at SSRN:
   https://ssrn.com/abstract=3715596 or http://dx.doi.org/10.2139/ssrn.3715596

 * [2] Gilliatt, N., & Gilliatt, N. (2007, March 21). Distributed viral social
   media spam. Social Media
   Today. https://www.socialmediatoday.com/content/distributed-viral-social-media-spam

 * [3] Darbyshire, M. (2021, October 18). Almost 900,000 accounts traded
   GameStop at peak of meme stock craze. Financial
   Times. https://www.ft.com/content/df758a2a-6caf-4d5f-ab70-bb5815922b91

============
Jurisdiction
============

Gora is incorporated in Switzerland, in the city of Zug, also known as Crypto
Valley. Switzerland became one of the first countries in the world to enact
legal regulations for blockchain technology, creating legal certainty for
developers, customers and investors. The integrity of the financial regulatory
framework makes Switzerland the gold standard among jurisdictions, and
cryptocurrencies are subject to the same rules as real monetary assets.

Gora plans to eventually be a fully decentralized protocol, where the
organization has none to little say in the direction of the protocol. However,
during the first 1-2 years of operation, the core team will directly affect the
direction of the protocol, and as such requires the team to be compliant with
local and international regulations, especially regarding the handling of
monetary investments.

****
Team
****

Gora is comprised of both full time and part-time contractors, and utilizes
strategic advisors to help build the protocol. This section describes our team
members.

==========
Management
==========

Abdul Osman - CEO
  Gora is led by CEO and founder Abdul Osman who has a background in Software
  Engineering and Business Administration. He is the founder of two software
  companies with Gora being his second successful venture. He specializes in
  creating innovative web and mobile applications with over 8 years of experience
  in bringing technological products from ideation to delivery to scale. Under his
  vision Gora aims to be the the first enterprise grade oracle network to bring
  proper decentralization, speed, security, and off-chain computation to Algorand.

Ali Hassan - CFO
  Finance is managed full time by CFO Ali Hassan who has over 15 years’ experience
  working in financial analysis, internal audit & risk management for several
  multinational organizations. Ali ensures that grant, seed funding and treasuries
  are managed to the highest standards and that Gora is in compliance with
  accounting regulations and financial reporting mandates.

Chris Brookins - Head of Business
  Chris has 10+ years experience in credit, blockchain, technology, and machine learning. Chris co-founded RociFi Labs, a blockchain and machine learning development company that built RociFi, an under-collateralized lending and credit scoring protocol on Polygon & zkSync; and RA, an onchain wallet analytics tool.

Joseph Jones - CTO
  The engineering department is led by Joseph Jones who is a multifaceted
  software engineer– having worked in many areas of software including machine
  learning, DevOps, web/mobile applications and blockchain development. He leads
  a team of six, devising the technical strategy to ensure Gora’s technology is
  not only cutting edge but also in alignment with its long-term business goals.

===========
Engineering
===========

Julius Githaiga - Full Stack developer
  Julius Githaiga is a highly skilled full stack developer with a decade of
  experience working in senior web development roles. He loves working on
  complex web development projects making him the perfect fit to design Gora’s
  web application to guarantee it delivers both functionality and an excellent
  user experience.

Egor Shipovalov - Distributed Systems Engineer
  Egor is a software developer and published researcher with over two decades of
  experience in various senior software development roles (e.g. Amazon, Deutsche
  Bank). His work has been crucial to the development of Gora’s Node Runner
  software.

Samantha Palmer - Blockchain Developer
  Samantha Palmer is a highly skilled Computer Scientist with experience as a Lead
  Data Scientist and Software Engineer in the past and currently uses her skills
  at Gora to develop, test, deploy and maintain smart contracts and other
  blockchain interfacing functionality.

Jesse Wallace - Blockchain Developer
  Jesse Wallace is an Electrical Engineer with extensive experience in hardware
  and software development. Jesse is an integral part of Gora, writing, testing
  and maintaining smart contracts.

George Njuguna - Senior Backend developer, Integration specialist
  George Njuguna has more than 10 years of experience in Systems Development with
  an expertise in project management and strategic planning. George is key in
  ensuring data feeds from over 50 data providers are seamlessly integrated into
  the Gora protocol.

============
Data Science
============

Ahmed Ali  - CDO 
  Data management is led full time by Ahmed Ali who has worked as a lead
  statistician and data scientist in the past and holds a masters in Mathematics
  and Statistics. His work has been key to creating models and simulation methods
  to determine the most suitable rewards system for our ecosystem participants.

Stylianos Kampakis  - Data Scientist  (Part Time)
  Dr. Stylianos Kampakis has a PHD in Computer Science and has over a decade of
  experience in Data Science, specifically in the Blockchain industry. He is an
  expert in designing tokenomics and his work has been integral to the formation
  of Gora's tokenomics. Dr. Stylianos has also published several books and papers
  on the topics of data modelling, blockchain, and various data science relatied
  topics.

Marketing and Admin Fred Arias -  CMO  
  Fred is an award-winning creative director, with a career in Television and
  Media spanning 20 years. Fred most recently completed a Masters in Marketing
  management, with a thesis in Marketing Strategies for Web3. Furthermore, Fred
  has a track record of executing under pressure, and bringing teams and
  communities together to achieve a common goal.

Adam Kinley  - Director Of Strategic Partnerships
  Adam Kinley is an experienced business development account executive and
  consultant and is responsible for increasing brand awareness for Gora and
  developing strategic partnerships. He accomplishes this by meeting with
  investors, onboarding institutional feed providers and educating developer teams
  on network functionality, feed providers/tiers, staking options, validator
  nodes, and our overall tokenomics.

Andre Bussanich - Creative Director
  Andre Bussanich is an award winning storyteller with over two decades of
  experience working as a Creative Director in advertising, video animation, and
  social media marketing. Using his unique set of skills, he directs all creative
  projects and shapes the standards of our brand identity at Gora.

Amal Osman - Social Media Coordinator/Digital Producer
  Amal Osman has worked as a videographer, photographer, and podcast producer in
  the past and uses her creative skills to produce high quality videos and other
  social media content. Working closely with our creative director Amal is tasked
  with positioning Gora as a hub for all types of Oracle and Blockchain related
  content.

========
Advisors
========

Gora is advised by several experts with a wide range of skills. The section
below describes our appointed advisors.

Olu Omoyele 
  Olu is a governer at Algorand, graduate of Oxford, Harvard and MIT and Executive
  Leader with nearly two decades of experience in Financial Regulatory Policy &
  Risk Management in both the public and private sectors. He has worked for the
  Bank of England, Bank of America Merrill Lynch and Visa in the past. He also
  serves as an advisor for multiple Fintech startups and Blockchain companies. He
  provides a valuable blend of financial advice from both traditional and
  decentralized finance.

dxFeed
  dxFeed offers the broadest range of data services currently available by a
  single company in the financial space and has built one of the most
  comprehensive ticker plants in the world. They are a subsidiary of Devexperts,
  who specialize in providing financial markets information and services to
  buy-side and sell-side institutions of the global financial industry,
  specifically to traders, data analysts, quants and portfolio managers. dxFeed's
  will provide high quality data to Gora and advise the technical team on how to
  most effectively format the data that Gora obtains for the dApps on the Algorand
  blockchain.

Brave New Coin
  BNC provides data, analysis and research to a global network of market
  participants. BNC's experience and expertise make them the leading provider of
  standard and non standard institutional grade, highly compliant, data solutions.
  Brave new coin advises Gora on data strategy, as well ad advertising through
  their media networl.

Patrick Sibetz
  Patrick is a quantitative analyst with an expertise in equity and derivatives
  quantitative trading. He assists Gora with token modelling.

Thomas Melskens
  Thomas Melskens is a pioneer in the blockchain space with a long history of
  involvement and leadership in the industry. Melskens has made significant
  contributions to the development and adoption of blockchain technology and has
  played a vital role in shaping the direction of the industry.
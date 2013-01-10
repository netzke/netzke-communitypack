# Netzke Communitypack [![Build Status](https://secure.travis-ci.org/nomadcoder/netzke-communitypack.png?branch=master)](http://travis-ci.org/nomadcoder/netzke-communitypack)

[RDocs](http://rdoc.info/github/netzke/netzke-communitypack)

A bunch of community-written Netzke components.

**IN THE PROCESS OF DEPRECATION**.

This gem will be decomposed and deprecated, with some parts being moved over to Basepack, others - to dedicated gems:

- [x] Move ActionColumn to Basepack as of v0.8.2
- [ ] Move Workspace to Basepack
- [ ] Extract TreePanel to a gem
- [ ] Extract ModelExplorer and OneToManyExplorer to a gem
- [ ] Move LiveSearchGrid to netzke-demo

## Included components

The following components are included (the ones marked FIXME! are probably not working with the latest Netzke, and are waiting for a fix):

* [LiveSearchGrid](http://rdoc.info/github/netzke/netzke-communitypack/Netzke/Communitypack/LiveSearchGrid) - a grid with configurable live search
* [Workspace](http://rdoc.info/github/netzke/netzke-communitypack/Netzke/Communitypack/Workspace) - a TabPanel-based component that allows dynamically load arbitrary Netzke components from server; for a demo see http://yanit.heroku.com
* [ModelExplorer](http://rdoc.info/github/netzke/netzke-communitypack/Netzke/Communitypack/ModelExplorer) - a grid and a form layed-out next to each other, bound to an ActiveRecord model; for a demo see http://yanit.heroku.com
* [OneToManyExplorer](http://rdoc.info/github/netzke/netzke-communitypack/Netzke/Communitypack/OneToManyExplorer) - 2 grids for editing ActiveRecord models that are connected with one-to-many relationship; for a demo see http://yanit.heroku.com
* [TreePanel](http://rdoc.info/github/netzke/netzke-communitypack/Netzke/Communitypack/TreePanel) (FIXME!) - a grid with configurable live search

## Functionality

Besides components, the following modules are included that can be used for extending existing components.

* [ActionColumn](http://rdoc.info/github/netzke/netzke-communitypack/Netzke/Communitypack/ActionColumn) - allows easily adding action column to `Basepack::Grid`; for a demo see http://yanit.heroku.com

---
Copyright (c) 2008-2012 [nomadcoder](https://twitter.com/nomadcoder), released under the MIT license (see LICENSE).

**Note** that Ext JS is licensed [differently](http://www.sencha.com/products/extjs/license/), and you may need to purchase a commercial license in order to use it in your projects!

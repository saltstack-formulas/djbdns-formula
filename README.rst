================
djbdns-formula
================

Introduction
============

Overview
--------
Here is formula for `djbdns <http://cr.yp.to/djbdns.html>`_.

Please consult `Wikipedia: Djbdns - The main djbdns components <http://en.wikipedia.org/wiki/Djbdns#The_main_djbdns_components>`_ for understand what is it and how to use it.

Tested workflow
---------------
I tested it just with `split horizon <http://www.fefe.de/djbdns/#splithorizon>`_.

According to `official FAQ <http://www.fefe.de/djbdns/#sameip>`_ you must use two separate network interfaces for that.

How to use ths formula
----------------------
See the full `Salt Formulas installation and usage instructions <http://docs.saltstack.com/topics/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``djbdns.dnscache``
------------
Install dnscache

``djbdns.tinydns``
-----------
Install tynydns

Configuration
=============
You can configure components by pillar.

Other components
================

All `other components <http://en.wikipedia.org/wiki/Djbdns#The_main_djbdns_components>`_ not supported by this formula.
Your pull requests are welcome

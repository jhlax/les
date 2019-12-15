les
===

``les`` is a concerted effort to reimplement **Live Enhancement Suite** in Python,
and potentially other languages--*BUT* maintainable and as a "write once, deploy
everywhere" code base; easy to add and update features that will propogate to both
Windows and macOS.

All credit and licensing goes to @inversil (Inverted Silence / Midas Klare, my
friend from the Netherlands)

:authors: @inversil, @jhlax
:version: 0.0.1-alpha

getting started
---------------

first, clone this repository.

then, ``cd`` into the clone.

finally, make sure you have **Python 3.6+** installed, then perform:

.. code:: bash

    pip install pipenv
    # pipenv --python <the python version you have; i.e. 3.6>
    pipenv --python 3.6
    pipenv shell
    pipenv install

this will allow you to create the virtual environment for this project, and
install the packages for this project.

    this project may add more libraries
    and packages as dependencies; run the ``pipenv install`` command when you
    ``git pull``.

structure of the repository
---------------------------

(this) ``README.rst`` is where general information of the project is
contained.

other than that:

1. ``TODO.rst``: a todo document, where tasks can be checked off.

2. ``CHANGELOG.rst``: the changelog as we continue through.

3. ``pyles/``: this is the core library of functions

4. ``scripts/``: command line scripts for testing or anything we want to make
   them.

5. ``Pipfile``: this contains all the dependencies for the Python environment.
   remember to ``pipenv install`` in the directory to make sure they are
   set up correctly.

6. ``LESosx``, ``LESwin``, ``LESgit``: the actual repos from @inversil for LES,
   that we will *attempt* to convert. probably from the Lua in the OS X repo
   but also with the changelog provided in the windows repo

    the end result will have more tooling for exporting as an installable
    file. starting from the bottom, the functions are the most important part
    right now.

how are we gonna do this
------------------------

good question. it's going to take a good amount of reading the code provided in
the Lua most likely. as we read it, we document what its doing in terms of
function. we may be able to eliminate some code for various things, and were
probably going to add or change things, as that is the way it goes when you
convert software!!!

standardization of the features so they are both modular and upgradeable is of
utmost importance to me. i mean plugins could be cool. ESPECIALLY if we're
running this through MIDI controller scripts.

the GUI affects are in the back of my mind as of now--as long as I can have the
system communicate over MIDI initially (with CLI scripts as they are needed) I
will be comfortable. the GUI and process shadowing is the user layer above that
will be essential to the end-user. perhaps for testing purposes a self-served
web interface could be used.

documentation is huge here. we want this to be really well thought out, and
well-documented for contributors and for, potentially, people to read when
they make plugins.

again Midas has all control over this code--I am just working on an alternate
method of writing it... it's not *necessary* per se, but I think it would be
a much more manageable and improvable model.

things to look at
-----------------

A. Python documentation

B. A good Python MIDI package

C. Midas's code!!!!!!

D. Reducing need for repeating code. Very important

E. Interfaces (comp sci interface model)

deliberations on dependent functionality
----------------------------------------

midi
~~~~

i am thinking either ``pymidi`` or ``mido`` for the MIDI interfacing. getting
the controller script schemas are somewhat easy--they've been made available
by julian bayle at his website_.

he was also kind enough to give us another link_ to the Live API. I am **using
Ableton Live API version 10.1**, but will attempt to create interfaces that
will backport for as many Live versions as possible.


    the API link is an XML file, I have found most browsers able to properly
    display this kind of file in the way that it is meant to be seen, but if
    yours outputs raw text try a different or more modern browser.

he also gives us a bevy of decompiled controller scripts at his github_ repo;
this has been cloned in to this repo as a submodule, as well as the XML
document above.

.. _website: https://julienbayle.studio/ableton-live-midi-remote-scripts/
.. _link: https://julienbayle.studio/PythonLiveAPI_documentation/Live10.1.xml
.. _github: https://github.com/gluon/AbletonLive10.1_MIDIRemoteScripts

cli tools
~~~~~~~~~

we will use ``click`` because I *know* it. also it's very quick to use.

library
~~~~~~~

so whats in the library?

1. MIDI interfacing in ``pyles.midi``

2. Ableton API abstraction in ``pyles.api``

3. their marriage in ``pyles.core``

4. the backend server in ``pyles.server``

5. the GUI (in the future) in ``pyles.gui``

also, we'll have command line tools or a web interface for testing or more
detailed operations (``bin/`` in this repo).

notes
=====

seems like we may be able to crutch ourselves on top of the existing
functionality of the Push 2 (and more) controller scripts--we might also
be able to actually build a script that is acts as a client and
executes at the more fundamental layer, which is good.

its also good that we have the __future__ functions imported in these
scripts. that may not carry to older versions of the scripts, but not
to worry... we also got them.



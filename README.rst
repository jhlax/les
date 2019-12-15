les
===

``les`` is a concerted effort to reimplement **Live Enhancement Suite** in Python,
and potentially other languages--*BUT* maintainable and as a "write once, deploy
everywhere" code base; easy to add and update features that will propogate to both
Windows and macOS.

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

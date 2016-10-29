smartmirror README
==================

Requirements
------------

```bash
apt-get install python3 python3-dev python3-venv
```
 
Create VirtualEnv
-----------------

```bash
pyvenv-3.4 venv
source venv/bin/activate
```

Configure
---------

```bash
cp development.ini.default development.ini
```

Change your settings as required.

Getting Started
---------------

```bash
cd <directory containing this file>
pip install -e .
initialize_smartmirror_db development.ini
pserve development.ini
```

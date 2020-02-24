# LLRB

This is a module to implement a Left Leaning Red Black Binary Tree structure
in ruby.


## Requirements

- ruby 2.6.5
- make

## Installation

In the root directory run
```
$ make -C ext
```

## Tests

Tests can be run with
```
$ rspec
```
to confirm that the module is functioning correctly.

To run performance tests use
```
$ ruby test.rb
```
to compare various operations to a hash. You should note that both structure
have certain tasks that they excel at. A hash is faster when it comes to general
insertion, searching and deletion. However, operations where order matters, such
as finding the maximum and iterating through an ordered list, are faster with
a LLRB.

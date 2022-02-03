# brillisp
### Charles Sherk <cs897@cornell.edu>_

Determine whether BRIL functions have side effects or not
This is not a very good analysis. It is so conservative it may start banning
books at any moment.

The point of this is that we could figure out that certain functions can be
computed at compile time (modulo nontermination) similar to constexpr in C++.


The current logic is
 - if you print, that's a side effect
 - if you call a function that either has a side effect or we haven't checked
   yet, that's a side effect. Ideally we could make a graph of functions and
   propagate impurity over them
 - if your type signature has any pointers in it, then something might be able
   to escape. This could be greatly improved with a pointer analysis

## License

MIT


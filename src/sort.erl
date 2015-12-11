-module(sort).

-export([bubble_sort/1]).

bubble_sort(L)->
  bubble_sort(L, length(L)).

bubble_sort(L, 0)->
  L;
bubble_sort(L, N)->
  bubble_sort(do_bubble_sort(L), N - 1).

do_bubble_sort([A])->
  [A];
do_bubble_sort([A, B | R])->
  case A < B of
    true -> [A | do_bubble_sort([B | R])];
    false -> [B | do_bubble_sort([A | R])]
  end.

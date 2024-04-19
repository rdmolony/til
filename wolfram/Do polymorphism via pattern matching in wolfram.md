In the `Wolfram` language I can assign variables like ...

```wolfram
time = Now

time
>> 2023-11-28 20:33:00
```

... or use delayed assignment so the value is generated on the fly ...

```wolfram
time := Now

time
>> 2023-11-28 20:33:10

time
>> 2023-11-28 20:33:11
```

Function definitions use pattern matching like `Prolog` or `Erlang` ...

> `Prolog` predates `Wolfram`;  1972 vs 1988

```wolfram
f[x_, y_] := x + y
```

... where `_` means that `x` and `y` are "blank".

This sets up a function where whatever provide later in the square bracket will match the pattern provided.

```wolfram
f[4, a]
>> 4 + a
```

Pattern matching means that we can define a function for specific definitions ...

```wolfram
f[1] = 2
f[2] = 3
```

... and undefined cases are left untransformed!

There are no types but I can still define behaviour on types somehow?!  Symbolic expressions have a "head" & the "head" can designate types ...

```wolfram
f[x_Integer] := x + 1
f[x_String] := StringJoin["Hello ", x, "!"]
```

Very cool.

#wolfram
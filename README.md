# Array

An Elixir wrapper library for Erlang's array.

Supports Access, Enumerable and Collectable protocols.

## Using Array with Mix
To use array in your projects, add array as a dependency:

```
def deps do
  [{:array, "~> 1.0.1"}]
end
```

Then run `mix deps.get` to install it.

## Documentation
http://code.void.in/docs/elixir-array/

## Example

```
# Create
arr = Array.new()

# Update
arr = Array.set(arr, 0, 100)

# Access by indices
arr[0] # -> 0
arr[1000] # -> nil

# Convert from/to list
Array.from_list([1,2,3,4,5])
Array.to_list(arr)

# Transform using the Enum module
Array.from_list([1,2,3,4,5]) |> Enum.map(fn x -> 2*x end)
Enum.into(0..100, Array.new())

# Comprehension
for v <- Array.from_list([1,2,3,4,5]), into: Array.new(), do: v*2
```

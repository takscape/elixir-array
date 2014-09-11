# Array

An Elixir wrapper for Erlang's array.

Supports Access, Enumerable and Collectable protocols.

## Example

```
# Create
arr = Array.new()

# Update
arr = Array.set(arr, 0, 100)

# Access by indices
arr[0]

# Convert from/to list
Array.from_list([1,2,3,4,5])
Array.to_list(arr)

# Transform using the Enum module
Array.from_list([1,2,3,4,5]) |> Enum.map(fn x -> 2*x end)
Enum.into(0..100, Array.new())

# Comprehension
for v <- Array.from_list([1,2,3,4,5]), into: Array.new(), do: v*2
```

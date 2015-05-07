defmodule Array do
  @moduledoc """
  A wrapper module for Erlang's array.
  """
  defstruct content: nil

  @type t :: %__MODULE__{content: :array.array()}
  @type index :: non_neg_integer
  @type element :: any
  @type opts :: opt | [opt]
  @type opt :: {:fixed, boolean} | :fixed | {:default, any} | {:size, non_neg_integer} | non_neg_integer
  @type orddict :: [{index, element}]

  @doc """
  Creates a new fixed array according to the given options.
  By default, the array is extendible and has initial size zero.
  The default value is the atom nil, if not specified.

  `options` is a single term or a list of terms, selected from the following:

  * `n : non_neg_integer` or `{:size, n : non_neg_integer}`
      * Specifies the initial size of the array; this also implies `{:fixed, true}`.
        If `n` is not a nonnegative integer, the call raises `ArgumentError`.
  * `:fixed` or `{:fixed, true}`
      * Creates a fixed-size array.
  * `{:fixed, false}`
      * Creates an extendible (non fixed-size) array.
  * `{:default, value}`
      * Sets the default value for the array to `value`.
  """
  @spec new(opts) :: t
  def new(options \\ []) do
    if is_list(options) do
      %Array{content: :array.new([{:default, nil} | options])}
    else
      %Array{content: :array.new([{:default, nil}, options])}
    end
  end

  @doc """
  Check if two arrays are equal using ===.
  """
  @spec equal?(t, t) :: boolean
  def equal?(%Array{content: c1}, %Array{content: c2}) do
    s1 = :array.size(c1)
    s2 = :array.size(c2)
    cond do
      s1 != s2 -> false

      s1 <= 0 -> true

      true ->
        Enumerable.reduce(Range.new(0, s1-1), {:cont, true}, fn(idx, _acc) ->
          if :array.get(idx, c1) === :array.get(idx, c2) do
            {:cont, true}
          else
            {:halt, false}
          end
        end) |> elem(1)
    end
  end

  @doc """
  Gets the value used for uninitialized entries.
  """
  @spec default(t) :: any
  def default(%Array{content: c}),
    do: :array.default(c)

  @doc """
  Fixes the size of the array. This prevents it from growing automatically upon insertion.
  """
  @spec fix(t) :: t
  def fix(%Array{content: c} = arr),
    do: %Array{arr | content: :array.fix(c)}

  @doc """
  Folds the elements of the array using the given function and initial accumulator value.
  The elements are visited in order from the lowest index to the highest. 

  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec foldl(t, acc, (index, element, acc -> acc)) :: acc when acc: var
  def foldl(%Array{content: c}, acc, fun),
    do: :array.foldl(fun, acc, c)

  @doc """
  Folds the elements of the array right-to-left using the given function and initial accumulator value.
  The elements are visited in order from the highest index to the lowest.
 
  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec foldr(t, acc, (index, element, acc -> acc)) :: acc when acc: var
  def foldr(%Array{content: c}, acc, fun),
    do: :array.foldr(fun, acc, c)

  @doc """
  Equivalent to `from_list(list, nil)`.
  """
  @spec from_list(list) :: t
  def from_list(list),
    do: %Array{content: :array.from_list(list, nil)}

  @doc """
  Converts a list to an extendible array.
  `default` is used as the value for uninitialized entries of the array.

  If `list` is not a proper list, the call raises `ArgumentError`.
  """
  @spec from_list(list, any) :: t
  def from_list(list, default),
    do: %Array{content: :array.from_list(list, default)}

  @doc """
  Equivalent to `from_orddict(orddict, nil)`.
  """
  @spec from_orddict(orddict) :: t
  def from_orddict(orddict),
    do: %Array{content: :array.from_orddict(orddict, nil)}

  @doc """
  Converts an ordered list of pairs `{index, value}` to a corresponding extendible array.
  `default` is used as the value for uninitialized entries of the array.

  If `orddict` is not a proper, ordered list of pairs whose first elements are nonnegative integers,
  the call raises `ArgumentError`.
  """
  @spec from_orddict(orddict, any) :: t
  def from_orddict(orddict, default),
    do: %Array{content: :array.from_orddict(orddict, default)}

  @doc """
  Converts an Erlang's array to an array.
  All properties (size, elements, default value, fixedness) of the original array are preserved.

  If `erl_arr` is not an Erlang's array, the call raises `ArgumentError`.
  """
  @spec from_erlang_array(:array.array()) :: t
  def from_erlang_array(erl_arr) do
    if :array.is_array(erl_arr) do
      %Array{content: erl_arr}
    else
      raise ArgumentError
    end
  end

  @doc """
  Gets the value of entry `idx`. If `idx` is not a nonnegative integer, or if the array has
  fixed size and `idx` is larger than the maximum index, the call raises `ArgumentError`.
  """
  @spec get(t, index) :: element
  def get(%Array{content: c}, idx),
    do: :array.get(idx, c)

  @doc """
  Returns `true` if `arr` appears to be an array, otherwise `false`.
  Note that the check is only shallow; there is no guarantee that `arr` is a well-formed array
  representation even if this function returns `true`.
  """
  @spec is_array(t) :: boolean
  def is_array(arr) do
    case arr do
      %Array{content: c} -> :array.is_array(c)
      _ -> false
    end
  end

  @doc """
  Checks if the array has fixed size. Returns `true` if the array is fixed, otherwise `false`.
  """
  @spec is_fix(t) :: boolean
  def is_fix(%Array{content: c}),
    do: :array.is_fix(c)

  @doc """
  Maps the given function onto each element of the array.
  The elements are visited in order from the lowest index to the highest.
 
  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec map(t, (index, element -> any)) :: t
  def map(%Array{content: c} = arr, fun),
    do: %Array{arr | content: :array.map(fun, c)}

  @doc """
  Makes the array resizable.
  """
  @spec relax(t) :: t
  def relax(%Array{content: c} = arr),
    do: %Array{arr | content: :array.relax(c)}

  @doc """
  Resets entry `idx` to the default value for the array.
  If the value of entry `idx` is the default value the array will be returned unchanged.
  Reset will never change size of the array. Shrinking can be done explicitly by calling `resize/2`.

  If `idx` is not a nonnegative integer, or if the array has fixed size and `idx` is
  larger than the maximum index, the call raises `ArgumentError`.
  """
  @spec reset(t, index) :: t
  def reset(%Array{content: c} = arr, idx),
    do: %Array{arr | content: :array.reset(idx, c)}

  @doc """
  Changes the size of the array to that reported by `sparse_size/1`.
  If the given array has fixed size, the resulting array will also have fixed size.
  """
  @spec resize(t) :: t
  def resize(%Array{content: c} = arr),
    do: %Array{arr | content: :array.resize(c)}

  @doc """
  Changes the size of the array.
  If `size` is not a nonnegative integer, the call raises `ArgumentError`.
  If the given array has fixed size, the resulting array will also have fixed size.
  """
  @spec resize(t, non_neg_integer) :: t
  def resize(%Array{content: c} = arr, size),
    do: %Array{arr | content: :array.resize(size, c)}

  @doc """
  Sets entry `idx` of the array to `val`.
  If `idx` is not a nonnegative integer, or if the array has fixed size and `idx` is
  larger than the maximum index, the call raises `ArgumentError`.
  """
  @spec set(t, index, element) :: t
  def set(%Array{content: c} = arr, idx, val),
    do: %Array{arr | content: :array.set(idx, val, c)}

  @doc """
  Gets the number of entries in the array.
  Entries are numbered from 0 to `size(array)-1`; hence, this is also the index of
  the first entry that is guaranteed to not have been previously set.
  """
  @spec size(t) :: non_neg_integer
  def size(%Array{content: c}),
    do: :array.size(c)

  @doc """
  Folds the elements of the array using the given function and initial accumulator value,
  skipping default-valued entries.
  The elements are visited in order from the lowest index to the highest.

  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec sparse_foldl(t, acc, (index, element, acc -> acc)) :: acc when acc: var
  def sparse_foldl(%Array{content: c}, acc, fun),
    do: :array.sparse_foldl(fun, acc, c)

  @doc """
  Folds the elements of the array right-to-left using the given function and initial accumulator value,
  skipping default-valued entries.
  The elements are visited in order from the highest index to the lowest.
 
  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec sparse_foldr(t, acc, (index, element, acc -> acc)) :: acc when acc: var
  def sparse_foldr(%Array{content: c}, acc, fun),
    do: :array.sparse_foldr(fun, acc, c)

  @doc """
  Maps the given function onto each element of the array, skipping default-valued entries.
  The elements are visited in order from the lowest index to the highest.
 
  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec sparse_map(t, (element -> any)) :: t
  def sparse_map(%Array{content: c} = arr, fun),
    do: %Array{arr | content: :array.sparse_map(fun, c)}

  @doc """
  Gets the number of entries in the array up until the last non-default valued entry.
  In other words, returns `idx+1` if `idx` is the last non-default valued entry in the array,
  or zero if no such entry exists.
  """
  @spec sparse_size(t) :: non_neg_integer
  def sparse_size(%Array{content: c}),
    do: :array.sparse_size(c)

  @doc """
  Converts the array to a list, skipping default-valued entries.
  """
  @spec sparse_to_list(t) :: list
  def sparse_to_list(%Array{content: c}),
    do: :array.sparse_to_list(c)

  @doc """
  Converts the array to an ordered list of pairs `{index, value}`, skipping default-valued entries.
  """
  @spec sparse_to_orddict(t) :: [{index, element}]
  def sparse_to_orddict(%Array{content: c}),
    do: :array.sparse_to_orddict(c)

  @doc """
  Converts the array to its underlying Erlang's array.
  """
  @spec to_erlang_array(t) :: :array.array()
  def to_erlang_array(%Array{content: c}),
    do: c

  @doc """
  Converts the array to a list.
  """
  @spec to_list(t) :: list
  def to_list(%Array{content: c}),
    do: :array.to_list(c)

  @doc """
  Converts the array to an ordered list of pairs `{index, value}`.
  """
  @spec to_orddict(t) :: [{index, element}]
  def to_orddict(%Array{content: c}),
    do: :array.to_orddict(c)
end

defimpl Access, for: Array do
  def get(arr, idx) do
    Array.get(arr, idx)
  end

  def get_and_update(arr, idx, fun) do
    {get, update} = fun.(Array.get(arr, idx))
    {get, Array.set(arr, idx, update)}
  end
end

defimpl Enumerable, for: Array do
  def count(arr), do: {:ok, Array.size(arr)}

  def member?(_arr, _value), do: {:error, __MODULE__}

  def reduce(%Array{content: c}, acc, fun) do
    Enumerable.reduce(:array.to_list(c), acc, fun)
  end
end

defimpl Collectable, for: Array do
  def empty(_arr) do
    Array.new()
  end

  def into(original) do
    {[], fn
        list, {:cont, x} -> [x | list]
        list, :done -> Array.from_list(Array.to_list(original) ++ :lists.reverse(list))
        _, :halt -> :ok
    end}
  end
end

defimpl Inspect, for: Array do
  import Inspect.Algebra

  def inspect(arr, opts) do
    concat(["#Array<", to_doc(Array.to_list(arr), opts),
      ", fixed=", Atom.to_string(Array.is_fix(arr)),
      ", default=", inspect(Array.default(arr)),
      ">"])
  end
end

defmodule Array do
  defstruct content: nil

  def new() do
    %Array{content: :array.new({:default, nil})}
  end

  def new(size) do
    %Array{content: :array.new(size, {:default, nil})}
  end

  def new(size, options) do
    if is_list(options) do
      if List.keymember?(options, :default, 0) do
        %Array{content: :array.new(size, options)}
      else
        %Array{content: :array.new(size, [{:default, nil} | options])}
      end
    else
      case options do
        {:default, _} -> %Array{content: :array.new(size, options)}
        _ -> %Array{content: :array.new(size, [{:default, nil}, options])}
      end
    end
  end

  def default(%Array{content: c}),
    do: :array.default(c)

  def fix(%Array{content: c} = arr),
    do: %Array{arr | content: :array.fix(c)}

  def foldl(%Array{content: c}, acc, fun),
    do: :array.foldl(fun, acc, c)

  def foldr(%Array{content: c}, acc, fun),
    do: :array.foldr(fun, acc, c)

  def from_list(list),
    do: %Array{content: :array.from_list(list, nil)}

  def from_list(list, default),
    do: %Array{content: :array.from_list(list, default)}

  def from_orddict(orddict),
    do: %Array{content: :array.from_orddict(orddict, nil)}

  def from_orddict(orddict, default),
    do: %Array{content: :array.from_orddict(orddict, default)}

  def is_array(arr) do
    case arr do
      %Array{content: c} -> :array.is_array(c)
      _ -> false
    end
  end

  def is_fix(%Array{content: c}),
    do: :array.is_fix(c)

  def map(%Array{content: c} = arr, fun),
    do: %Array{arr | content: :array.map(fun, c)}

  def relax(%Array{content: c} = arr),
    do: %Array{arr | content: :array.relax(c)}

  def reset(%Array{content: c} = arr, idx),
    do: %Array{arr | content: :array.reset(idx, c)}

  def resize(%Array{content: c} = arr),
    do: %Array{arr | content: :array.resize(c)}

  def resize(%Array{content: c} = arr, size),
    do: %Array{arr | content: :array.resize(size, c)}

  def set(%Array{content: c} = arr, idx, val),
    do: %Array{arr | content: :array.set(idx, val, c)}

  def size(%Array{content: c}),
    do: :array.size(c)

  def sparse_foldl(%Array{content: c}, acc, fun),
    do: :array.sparse_foldl(fun, acc, c)

  def sparse_foldr(%Array{content: c}, acc, fun),
    do: :array.sparse_foldr(fun, acc, c)

  def sparse_map(%Array{content: c} = arr, fun),
    do: %Array{arr | content: :array.sparse_map(fun, c)}

  def sparse_size(%Array{content: c}),
    do: :array.sparse_size(c)

  def sparse_to_list(%Array{content: c}),
    do: :array.sparse_to_list(c)

  def sparse_to_orddict(%Array{content: c}),
    do: :array.sparse_to_orddict(c)

  def to_list(%Array{content: c}),
    do: :array.to_list(c)

  def to_orddict(%Array{content: c}),
    do: :array.to_orddict(c)

  def get(%Array{content: c}, idx),
    do: :array.get(idx, c)

  def get_and_update(%Array{content: c} = arr, idx, fun) do
    {get, update} = fun.(:array.get(idx, c))
    {get, %Array{arr | content: :array.set(idx, update, c)}}
  end
end

defimpl Access, for: Array do
  def get(arr, idx) do
    Array.get(arr, idx)
  end

  def get_and_update(arr, idx, fun) do
    Array.get_and_update(arr, idx, fun)
  end
end

defimpl Enumerable, for: Array do
  def count(arr), do: Array.size(arr)

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

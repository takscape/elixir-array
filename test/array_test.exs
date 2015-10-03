defmodule ArrayTest do
  use ExUnit.Case

  test "new/0" do
    a = Array.new()

    assert true == Array.is_array(a)
    assert false == Array.is_fix(a)
    assert nil == Array.default(a)

    assert nil == Array.get(a, 0)
    assert 0 == Array.size(a)
    a = Array.set(a, 0, 1)
    assert 1 == Array.get(a, 0)
    assert 1 == Array.size(a)
  end

  test "new/1, size specified" do
    a = Array.new(10)

    assert true == Array.is_array(a)
    assert true == Array.is_fix(a)
    assert nil == Array.default(a)
    assert 10 == Array.size(a)

    assert nil == Array.get(a, 0)

    assert nil == Array.get(a, 9)

    assert nil == Array.get(a, 10)

    a = Array.set(a, 0, 1)
    assert 1 == Array.get(a, 0)

    a = Array.set(a, 9, 9)
    assert 9 == Array.get(a, 9)

    assert_raise ArgumentError, fn ->
      Array.set(a, 10, 10)
    end
  end

  test "new/1, negative size" do
    Array.new(0) # This is not an error
    assert_raise ArgumentError, fn ->
      Array.new(-1)
    end
  end

  test "new/1, fixed" do
    a = Array.new(:fixed)

    assert true == Array.is_array(a)
    assert true == Array.is_fix(a)
    assert nil == Array.default(a)
  end

  test "new/1, default value specified" do
    a = Array.new([default: -1])

    assert true == Array.is_array(a)
    assert false == Array.is_fix(a)
    assert -1 == Array.default(a)
    assert -1 == Array.get(a, 0)
  end

  test "default" do
    a = Array.new([default: "foo"])
    assert "foo" == Array.default(a)

    a2 = Array.new()
    assert nil == Array.default(a2)
  end

  test "equal?" do
    assert Array.equal?(Array.from_list([1,2,3]), Array.from_list([1,2,3]))
    assert Array.equal?(Array.from_list([1, :foo, "bar"]), Array.from_list([1, :foo, "bar"]))
    assert Array.equal?(Array.new(), Array.new())
    assert Array.equal?(Array.new(10), Array.new() |> Array.set(9, nil))
    assert false == Array.equal?(Array.from_list([1,2,3]), Array.from_list([1,2,3,4]))
    assert false == Array.equal?(Array.from_list([2,2,3]), Array.from_list([1,2,3]))
    assert false == Array.equal?(Array.new(), Array.from_list(["a","b","c"]))
  end

  test "fix" do
    a = Array.new()
    a = Array.set(a, 100, 0)

    a = Array.fix(a)
    assert_raise ArgumentError, fn ->
      Array.set(a, 101, 0)
    end
  end

  test "foldl" do
    a = Array.from_list(["a", "b", "c"])
    res = Array.foldl(a, "foo", fn idx, elm, acc ->
      case idx do
        0 -> assert "a" == elm
        1 -> assert "b" == elm
        2 -> assert "c" == elm
        _ -> assert false
      end
      acc <> elm
    end)
    assert "fooabc" == res

    assert_raise ArgumentError, fn ->
      Array.foldl(a, "foo", "bar")
    end
  end

  test "foldr" do
    a = Array.from_list(["a", "b", "c"])
    res = Array.foldr(a, "foo", fn idx, elm, acc ->
      case idx do
        0 -> assert "a" == elm
        1 -> assert "b" == elm
        2 -> assert "c" == elm
        _ -> assert false
      end
      acc <> elm
    end)
    assert "foocba" == res

    assert_raise ArgumentError, fn ->
      Array.foldr(a, "foo", "bar")
    end
  end

  test "from_list/1" do
    a = Array.from_list([1,2,3])

    assert true == Array.is_array(a)
    assert false == Array.is_fix(a)
    assert nil == Array.default(a)
    assert 3 == Array.size(a)

    assert 1 == Array.get(a, 0)
    assert 2 == Array.get(a, 1)
    assert 3 == Array.get(a, 2)
  end

  test "from_list/2" do
    a = Array.from_list([3,2,1], :foo)

    assert true == Array.is_array(a)
    assert false == Array.is_fix(a)
    assert :foo == Array.default(a)
    assert 3 == Array.size(a)

    assert 3 == Array.get(a, 0)
    assert 2 == Array.get(a, 1)
    assert 1 == Array.get(a, 2)
  end

  test "from_orddict/1" do
    a = Array.from_orddict([{1, "a"}, {3, "c"}, {4, "b"}])

    assert true == Array.is_array(a)
    assert false == Array.is_fix(a)
    assert nil == Array.default(a)
    assert 5 == Array.size(a)

    assert nil == Array.get(a, 0)
    assert "a" == Array.get(a, 1)
    assert nil == Array.get(a, 2)
    assert "c" == Array.get(a, 3)
    assert "b" == Array.get(a, 4)
    assert nil == Array.get(a, 5)

    assert_raise ArgumentError, fn ->
      # unordered
      Array.from_orddict([{1, "a"}, {4, "b"}, {3, "c"}])
    end
  end

  test "from_orddict/2" do
    a = Array.from_orddict([{1, "a"}, {3, "c"}, {4, "b"}], :foo)

    assert true == Array.is_array(a)
    assert false == Array.is_fix(a)
    assert :foo == Array.default(a)
    assert 5 == Array.size(a)

    assert :foo == Array.get(a, 0)
    assert "a" == Array.get(a, 1)
    assert :foo == Array.get(a, 2)
    assert "c" == Array.get(a, 3)
    assert "b" == Array.get(a, 4)
    assert :foo == Array.get(a, 5)

    assert_raise ArgumentError, fn ->
      # unordered
      Array.from_orddict([{1, "a"}, {4, "b"}, {3, "c"}], :foo)
    end
  end

  test "from_erlang_array" do
    erl_arr = :array.new()
    erl_arr = :array.set(0, 1, erl_arr)
    erl_arr = :array.set(1, 2, erl_arr)
    erl_arr = :array.set(2, 3, erl_arr)

    a = Array.from_erlang_array(erl_arr)
    assert true == Array.is_array(a)
    assert :array.size(erl_arr) == Array.size(a)
    assert :array.is_fix(erl_arr) == Array.is_fix(a)
    assert :array.default(erl_arr) == Array.default(a)
    assert 1 == Array.get(a, 0)
    assert 2 == Array.get(a, 1)
    assert 3 == Array.get(a, 2)

    assert_raise ArgumentError, fn ->
      Array.from_erlang_array([1,2,3])
    end
  end

  test "is_array" do
    assert true == Array.is_array(Array.new())
    assert false == Array.is_array(0)
    assert false == Array.is_array(nil)
    assert false == Array.is_array("foo")
    assert false == Array.is_array(:array.new())
  end

  test "is_fix" do
    assert true == Array.is_fix(Array.new(:fixed))
    assert false == Array.is_fix(Array.new([fixed: false]))
  end

  test "map" do
    a = Array.from_list([1,2,3])
    a2 = Array.map(a, fn(idx, elm) ->
      case idx do
        0 -> assert 1 == elm
        1 -> assert 2 == elm
        2 -> assert 3 == elm
        _ -> assert false
      end
      2*elm
    end)
    assert [2,4,6] == Array.to_list(a2)

    assert_raise ArgumentError, fn ->
      Array.map(a, "foo")
    end
  end

  test "relax" do
    a = Array.new(:fixed)
    assert true == Array.is_fix(a)

    a = Array.relax(a)
    assert false == Array.is_fix(a)
  end

  test "reset" do
    a = Array.from_list([1,2,3])
    assert 2 == Array.get(a, 1)

    a = Array.reset(a, 1)
    assert nil == Array.get(a, 1)
  end

  test "resize/1" do
    a = Array.new(10)
    assert 10 == Array.size(a)
    assert 0 == Array.sparse_size(a)

    a = Array.set(a, 8, 1)
    assert 10 == Array.size(a)
    assert 9 == Array.sparse_size(a)

    a = Array.resize(a)
    assert 9 == Array.size(a)
    assert 9 == Array.sparse_size(a)
  end

  test "resize/2" do
    a = Array.new([size: 10, fixed: true])
    assert 10 == Array.size(a)

    a = Array.resize(a, 5)
    assert 5 == Array.size(a)
    assert true == Array.is_fix(a)
    assert false == (Array.new([size: 10, fixed: false]) |> Array.resize(5) |> Array.is_fix)

    assert_raise ArgumentError, fn ->
      Array.resize(Array.new(), -1)
    end
  end

  test "get/fetch/set" do
    a = Array.new()

    a = Array.set(a, 5, 10)
    assert nil == Array.get(a, 4)
    assert {:ok, nil} == Array.fetch(a, 4)
    assert 10 == Array.get(a, 5)
    assert {:ok, 10} == Array.fetch(a, 5)
    assert nil == Array.get(a, 6)
    assert :error == Array.fetch(a, 6)

    a = Array.set(a, 0, 100)
    assert 100 == Array.get(a, 0)
    assert_raise ArgumentError, fn ->
      Array.set(a, -1, 1000)
    end
    assert nil == Array.get(a, -1)
    assert :error == Array.fetch(a, -1)
  end

  test "size" do
    assert 10 == Array.new([size: 10]) |> Array.size
    assert 5 == Array.new([size: 5]) |> Array.size
    assert 6 == Array.new() |> Array.set(5,0) |> Array.size
  end

  test "sparse_foldl" do
    a = Array.new([size: 10, default: "x"])
    a = a |> Array.set(2, "a") |> Array.set(4, "b") |> Array.set(6, "c")
    res = Array.sparse_foldl(a, "foo", fn idx, elm, acc ->
      case idx do
        2 -> assert "a" == elm
        4 -> assert "b" == elm
        6 -> assert "c" == elm
        _ -> assert false
      end
      acc <> elm
    end)
    assert "fooabc" == res

    assert_raise ArgumentError, fn ->
      Array.sparse_foldl(a, "foo", "bar")
    end
  end

  test "sparse_foldr" do
    a = Array.new([size: 10, default: "x"])
    a = a |> Array.set(1, "a") |> Array.set(3, "b") |> Array.set(5, "c")
    res = Array.sparse_foldr(a, "foo", fn idx, elm, acc ->
      case idx do
        1 -> assert "a" == elm
        3 -> assert "b" == elm
        5 -> assert "c" == elm
        _ -> assert false
      end
      acc <> elm
    end)
    assert "foocba" == res

    assert_raise ArgumentError, fn ->
      Array.sparse_foldr(a, "foo", "bar")
    end
  end

  test "sparse_map" do
    a = Array.new([size: 10])
    a = a |> Array.set(1, 2) |> Array.set(3, 4) |> Array.set(5, 6)
    res = Array.sparse_map(a, fn idx, elm ->
      case idx do
        1 -> assert 2 == elm
        3 -> assert 4 == elm
        5 -> assert 6 == elm
        _ -> assert false
      end
      elm / 2
    end)
    Enum.each(0..9, fn idx ->
      case idx do
        1 -> assert 1 == Array.get(res, idx)
        3 -> assert 2 == Array.get(res, idx)
        5 -> assert 3 == Array.get(res, idx)
        _ -> assert nil == Array.get(res, idx)
      end
    end)

    assert_raise ArgumentError, fn ->
      Array.sparse_map(a, "foo")
    end
  end

  test "sparse_size" do
    a = Array.from_list([1,2,3,4,5])
    assert 5 == Array.sparse_size(a)
    a = Array.reset(a, 4)
    assert 4 == Array.sparse_size(a)
  end

  test "sparse_to_list" do
    a = Array.new([size: 10])
    a = a |> Array.set(1, 1) |> Array.set(3, 2) |> Array.set(5, 3)

    assert [1,2,3] == Array.sparse_to_list(a)
  end

  test "sparse_to_orddict" do
    a = Array.new([size: 10])
    a = a |> Array.set(2, 1) |> Array.set(4, 2) |> Array.set(6, 3)

    assert [{2,1}, {4,2}, {6,3}] == Array.sparse_to_orddict(a)
  end

  test "to_erlang_array" do
    a = Array.from_list([1,2,3])
    ea = Array.to_erlang_array(a)

    assert :array.is_array(ea)
    assert 3 == :array.size(ea)
    assert 1 == :array.get(0, ea)
    assert 2 == :array.get(1, ea)
    assert 3 == :array.get(2, ea)
  end

  test "to_list" do
    a = Array.from_list([1,2,3])
    assert [1,2,3] == Array.to_list(a)
  end

  test "to_orddict" do
    a = Array.from_list([1,2,3])
    assert [{0, 1}, {1, 2}, {2, 3}] == Array.to_orddict(a)
  end

  test "Access.get" do
    a = Array.from_list([1,2,3])
    assert 1 == a[0]
    assert 2 == a[1]
    assert 3 == a[2]
    assert nil == a[3]
  end

  test "Access.get_and_update" do
    a = Array.from_list([1,2,3])
    {get, update} = Access.get_and_update(a, 1, fn v -> {2*v, 100} end)
    assert 4 == get
    assert [1,100,3] == Array.to_list(update)
  end

  test "Enumerable.count" do
    a = Array.from_list([1,2,3])
    assert 3 == Enum.count(a)
  end

  test "Enumerable.member" do
    a = Array.from_list([1,2,3])
    assert Enum.member?(a, 3)
    assert false == Enum.member?(a, 4)
  end

  test "Enumerable.reduce" do
    sum = Enum.reduce(Array.from_list([1,2,3]), 0, fn(x, acc) -> x + acc end)
    assert 6 == sum
  end

  test "Collectable.into" do
    a = Enum.into([1,2,3], Array.new())
    assert Array.is_array(a)
    assert [1,2,3] == Array.to_list(a)
  end
end

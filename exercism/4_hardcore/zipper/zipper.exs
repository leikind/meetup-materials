# def BinTree, value: nil, left: nil, right: nil do
#   @moduledoc """
#   A node in a binary tree.

#   `value` is the value of a node.
#   `left` is the left subtree (nil if no subtree).
#   `right` is the right subtree (nil if no subtree).
#   """
#   record_type value: any, left: BinTree.t | nil, right: BinTree.t | nil
# end

defmodule BinTree do
  defstruct value: nil, left: nil, right: nil
end

defmodule Zipper do

  alias BinTree, as: BT
  alias __MODULE__, as: Z

  @doc """
  Get a zipper focussed on the root node.
  """
  #@spec from_tree(BT.t) :: Z.t
  def from_tree(bt) do
    [bt]
  end

  @doc """
  Get the complete tree from a zipper.
  """
  #@spec to_tree(Z.t) :: BT.t
  def to_tree(z) do
    [t|_] = z
    t
  end

  # @doc """
  # Get the value of the focus node.
  # """
  # @spec value(Z.t) :: any
  def value(z) do
    [t|_] = z
    t.value
  end

  # @doc """
  # Get the left child of the focus node, if any.
  # """
  # @spec left(Z.t) :: Z.t | nil
  def left(z) do
    [t|_] = z
    [t.left|z]
  end

  # @doc """
  # Get the right child of the focus node, if any.
  # """
  # @spec right(Z.t) :: Z.t | nil
  def right(z) do
    [t|_] = z
    [t.right|z]
  end

  # @doc """
  # Get the parent of the focus node, if any.
  # """
  # @spec up(Z.t) :: Z.t
  def up(z) do
    [_|zz] = z
    zz
  end

  # @doc """
  # Set the value of the focus node.
  # """
  # @spec set_value(Z.t, any) :: Z.t
  def set_value(z, v) do
    [t|l] = z
    [%{t | value: v}|l]
  end

  # @doc """
  # Replace the left child tree of the focus node.
  # """
  # @spec set_left(Z.t, BT.t) :: Z.t
  def set_left(z, l) do
    [t|tail] = z
    [%{t | left: l}|tail]
  end

  # @doc """
  # Replace the right child tree of the focus node.
  # """
  # @spec set_right(Z.t, BT.t) :: Z.t
  def set_right(z, r) do
    [t|tail] = z
    [%{t | right: r}|tail]
  end
end

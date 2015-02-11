defmodule BSON.Encoder do

  def encode_document(dict) do
    data = encode_e_list(dict)
    size = byte_size(data)
    <<size::signed-32, data::binary, 0>>
  end

  defp encode_e_list(dict) do
    for {name, value} <- dict, into: <<>> do
      encode_element(name, value)
    end
  end

  defp encode_element(name, value) do
    {type, data} = encode_element_value(value)
    e_name = cstring(name)
    <<type, e_name::binary, data::binary>>
  end

  defp encode_element_value(value) when is_float(value) do
    {0x01, <<value::float>>}
  end

  defp encode_element_value(value) when is_binary(value) do
    length_with_zero = byte_size(value) + 1
   {0x02, <<length_with_zero::signed-32, value::binary, 0x00>>}
  end

  defp encode_element_value(%Regex{source: source, opts: opts}) do
   {0x0b, cstring(source) <> cstring(opts)}
  end

  defp encode_element_value(value) when is_map(value) do
   {0x03, encode_document(value)}
  end

  defp encode_element_value(value) when is_list(value) do
    document = value
                 |> Enum.with_index
                 |> Enum.map(fn {val, idx} -> {to_string(idx), val} end)
                 |> encode_document
    {0x04, document}
  end

  defp encode_element_value(value) when is_integer(value) do
   {0x12, <<value::signed-64>>}
  end

  defp encode_element_value(false) do
   {0x08, <<0x00>>}
  end

  defp encode_element_value(true) do
   {0x08, <<0x01>>}
  end

  defp encode_element_value(nil) do
   {0x0a, <<>>}
  end

  defp cstring(s), do: s <> <<0>>

end
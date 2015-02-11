defmodule BSON.Decoder do

  def decode_document(<<length::signed-32, stream::binary>>) do
    <<stream::binary-size(length), 0, rest::binary>> = stream
    {e_list, stream} = decode_e_list(stream)
    {e_list, stream <> rest}
  end

  defp decode_e_list(stream) do
    decode_e_list(stream, %{})
  end

  defp decode_e_list(<<>>, h), do: {h, <<>>}
  defp decode_e_list(stream, h) do
    {{_type, e_name, value}, stream} = decode_element(stream)
    decode_e_list(stream, Dict.put_new(h, e_name, value))
  end

  defp decode_element(<<type, rest::binary>>) do
    {e_name, rest} = read_cstring(rest)
    {value, rest} = decode_element_value(type, rest)
    {{type, e_name, value}, rest}
  end

  defp decode_element_value(0x01, <<value::float, rest::binary>>) do
    {value, rest}
  end

  defp decode_element_value(0x02, stream) do
    read_string(stream)
  end

  defp decode_element_value(0x03, stream) do
    decode_document(stream)
  end

  defp decode_element_value(0x04, stream) do
    {document, stream} = decode_document(stream)
    array = Enum.map(document, fn {_, value} -> value end)
    {array, stream}
  end

  @subtypes %{
    0x00 => :generic,
    0x01 => :function,
    0x02 => :binary_old,
    0x03 => :uuid_old,
    0x04 => :uuid,
    0x05 => :md5,
    0x80 => :user_defined,
  }

  defp decode_element_value(0x05, <<length::signed-32, subtype, rest::binary>>) do
    <<data::binary-size(length), rest::binary>> = rest
    {{Fict.fetch(@subtypes, subtype), data}, rest}
  end

  defp decode_element_value(0x06, rest) do
    {:deprecated, rest}
  end

  defp decode_element_value(0x07, <<value::binary-size(12), rest::binary>>) do
    {value, rest}
  end

  defp decode_element_value(0x08, <<0, rest::binary>>) do
    {false, rest}
  end

  defp decode_element_value(0x08, <<1, rest::binary>>) do
    {true, rest}
  end

  defp decode_element_value(0x09, <<value::signed-64, rest::binary>>) do
    {value, rest}
  end

  defp decode_element_value(0x0a, rest) do
    {nil, rest}
  end

  defp decode_element_value(0x0b, stream) do
    {pattern, rest}   = read_cstring(stream)
    {options, rest} = read_cstring(rest)
    {:ok, regex} = Regex.compile(pattern, options)
    {regex, rest}
  end

  defp decode_element_value(0x0c, stream) do
    {:deprecated, stream}
  end

  defp decode_element_value(0x0d, stream) do
    read_string(stream)
  end

  defp decode_element_value(0x0e, stream) do
    {:deprecated, stream}
  end

  defp decode_element_value(0x0f, stream) do
    {code, rest} = read_string(stream)
    {scope, rest} = decode_document(rest)
    {{code, scope}, rest}
  end

  defp decode_element_value(0x10, <<value::signed-32, rest::binary>>) do
    {value, rest}
  end

  defp decode_element_value(0x11, <<value::signed-64, rest::binary>>) do
    {value, rest}
  end

  defp decode_element_value(0x12, <<value::signed-64, rest::binary>>) do
    {value, rest}
  end

  defp decode_element_value(0xff, stream) do
    {:min, stream}
  end

  defp decode_element_value(0x7f, stream) do
    {:max, stream}
  end

  defp read_string(<<length::signed-32, rest::binary>>) do
    length_without_zero = length-1
    <<value :: binary-size(length_without_zero), 0, rest::binary>> = rest
    {value, rest}
  end

  defp read_cstring(string), do: read_cstring(string, <<>>)

  defp read_cstring(<<>>, match), do: {match, <<>>}
  defp read_cstring(<<0, string :: binary>>, match), do: {match, string}
  defp read_cstring(<<c, string :: binary>>, match), do: read_cstring(string, match <> <<c>>)

end
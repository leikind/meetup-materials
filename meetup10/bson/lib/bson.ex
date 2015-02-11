defmodule BSON do

  def encode(doc) do
    BSON.Encoder.encode_document(doc)
  end

  def decode(stream) do
    BSON.Decoder.decode_document(stream) |> elem(0)
  end

end

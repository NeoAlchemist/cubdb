defmodule CubDB.Store.File.Blocks do
  @block_size 4096

  def add_headers(bin, loc, block_size \\ @block_size) do
  end

  def strip_headers(bin, loc, block_size \\ @block_size) do
    case rem(loc, block_size) do
      0 -> strip(bin, <<>>, block_size)
      r ->
        block_rest = block_size - r
        if byte_size(bin) <= block_rest do
          bin
        else
          <<prefix::binary-size(block_rest), rest::binary>> = bin
          strip(rest, prefix, block_size)
        end
    end
  end

  defp strip(bin, acc, block_size) do
    if byte_size(bin) <= block_size do
      <<_::binary-1, block::binary>> = bin
      acc <> block
    else
      data_size = block_size - 1
      <<_::binary-1, block::binary-size(data_size), rest::binary>> = bin
      strip(rest, acc <> block, block_size)
    end
  end

  def length_with_headers(loc, length, block_size \\ @block_size) do
    case rem(loc, block_size) do
      0 -> headers_length(length, block_size) + length
      r ->
        prefix = block_size - r
        rest = length - prefix
        prefix + headers_length(rest, block_size) + rest
    end
  end

  defp headers_length(length, block_size) do
    Float.ceil(length / (block_size - 1))
  end
end
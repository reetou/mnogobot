defimpl Jason.Encoder, for: Tuple do
  def encode(value, opts) do
    Jason.Encode.map(parse_tuple(value), opts)
  end

  defp parse_tuple({key, val}) do
    %{key => List.wrap(val)}
  end
end
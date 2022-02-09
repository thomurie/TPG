defmodule TPG do
  @moduledoc """
  Documentation for `TPG`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> TPG.avg_max([1, 2, 3, 4, 5, 6])
      3.5

  """
  @urls [
    "https://www.metaweather.com/api/location/2487610/",
    "https://www.metaweather.com/api/location/2442047/",
    "https://www.metaweather.com/api/location/2366355/"
  ]

  # @locations %{
  #   slc: %{name: "Salt Lake City", meta_weather_id: "2487610", avg_max_temp: 0},
  #   lax: %{name: "Los Angeles", meta_weather_id: "2442047", avg_max_temp: 0},
  #   boi: %{name: "Boise", meta_weather_id: "2366355", avg_max_temp: 0}
  # }

  #  validate successful response
  #  TODO improve error handling
  def validate_api_calls(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode!(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  # concurrentAPICalls calls apis concurrently, puts results into an array
  # TODO error handling
  def call_apis_async() do
    @urls
    |> Task.async_stream(&HTTPoison.get/1)
    |> Enum.into([], fn {:ok, res} -> res end)
    |> Enum.map(&validate_api_calls(&1))
    |> Enum.map(&process_response_data(&1))
    |> display_max_temps
  end

  # create array of max temperatures, add the temperatures to the map
  def process_response_data(location_data) do
    avg_max_temp = Map.get(location_data, "consolidated_weather") |> Enum.map(&get_temp(&1)) |> avg_max
    location = Map.get(location_data, "title")
    {:ok, location, avg_max_temp}
  end

  def get_temp(weather_map) do
    Map.get(weather_map, "max_temp")
    |> c_to_f
  end

  def display_max_temps(locations_list \\ [], statement \\ "")

  def display_max_temps([], statement), do: statement

  def display_max_temps(locations, statement) do
    [ head | tail ] = locations
    {:ok, location, avg_max_temp} = head
    phrase = "#{location} Average Max Temp: #{avg_max_temp}\n"
    new_statement = statement <> phrase
    display_max_temps(tail, new_statement)
  end

  # def return_max_temps(locations_list \\ [], statement \\ "")

  # def return_max_temps([], statement), do: statement

  # def return_max_temps(locations, statement) when is_map(locations) do
  #   locations
  #   |>Map.to_list
  #   |>return_max_temps
  # end

  # def return_max_temps(locations, statement) do
  #   [ head | tail ] = locations
  #   {name , data} = head

  #   name = Map.get(data, :name)
  #   temp = Map.get(data, :avg_max_temp)
  #   phrase = "#{name} Average Max Temp: #{temp}\n"
  #   new_statement = statement <> phrase
  #   return_max_temps(tail, new_statement)
  # end

  # #   update map locations array
  # def update_nested_map(parent_map, child_key, target_key, updated_value) do
  #   child_map = Map.get(parent_map, child_key)
  #   updated_child_map = Map.put(child_map, target_key, updated_value)
  #   Map.put(parent_map, child_key, updated_child_map)
  # end

  # centigrade to farenhiet
  def c_to_f(c), do: ((c * 9) / 5) + 32

  # find avg max temp
  defp divide(a, b \\ 1), do: Kernel.trunc((a / b) * 100) / 100

  def avg_val(lst \\ []) do
    lst
    |> Enum.sum()
    |> divide(length(lst))
  end

  # # for each url print #{location_name} Average Max Temp: #{avg_max_temp}
  # def return_max_temps(locations_list \\ [], statement \\ "")

  # def return_max_temps([], statement), do: statement

  # def return_max_temps(locations, statement) when is_map(locations) do
  #   locations
  #   |>Map.to_list
  #   |>return_max_temps
  # end

  # def return_max_temps(locations, statement) do
  #   [ head | tail ] = locations
  #   {name , data} = head

  #   name = Map.get(data, :name)
  #   temp = Map.get(data, :avg_max_temp)
  #   phrase = "#{name} Average Max Temp: #{temp}\n"
  #   new_statement = statement <> phrase
  #   return_max_temps(tail, new_statement)
  # end

  # Put it all together
  def get_url_max_temps(locations) do
    locations
    |> return_max_temps
    |> IO.inspect
  end

end

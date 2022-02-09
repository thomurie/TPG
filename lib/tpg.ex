defmodule TPG do
  @moduledoc """
  Doumentation for TPG

  Takes a list of urls,
  Concurrently makes GET requests to all urls,
  A list of the responses is created,
  JSON responses in list are validated,
  JSON responses in list are converted to map,
  The list is iterated through,
  The requested data is collected,
  The requested data is printed to the console.
  """
  @urls [
    "https://www.metaweather.com/api/location/2487610/",
    "https://www.metaweather.com/api/location/2442047/",
    "https://www.metaweather.com/api/location/2366355/"
  ]

  # concurrentAPICalls calls apis concurrently, puts results into an array
  # TODO error handling
  @doc """
  Hello world.

  """
  def call_apis_async() do
    @urls
    |> Task.async_stream(&HTTPoison.get/1)
    |> Enum.into([], fn {:ok, res} -> res end)
  end

  #  validate successful response
  #  TODO improve error handling
  @doc """
  Hello world.

  """
  def validate_api_calls(response) do
    # IO.inspect is_list(response)
    # IO.inspect response
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode!(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  # create array of max temperatures, add the temperatures to the map
  @doc """
  Hello world.

  """
  def process_response_data(location_data) do
    avg_max_temp = Map.get(location_data, "consolidated_weather") |> Enum.map(&get_temp(&1)) |> avg_val
    location = Map.get(location_data, "title")
    {:ok, location, avg_max_temp}
  end

  @doc """
  Hello world.

  """
  def get_temp(weather_map) do
    Map.get(weather_map, "max_temp")
    |> c_to_f
  end

  # centigrade to farenhiet
  @doc """
  Hello world.

  """
  def c_to_f(c), do: ((c * 9) / 5) + 32

  @doc """
  Hello world.

  """
  def avg_val(lst) do
    lst
    |> Enum.sum()
    |> divide(length(lst))
  end

  # find avg max temp
  @doc """
  Hello world.

  """
  def divide(a, b \\ 1), do: Kernel.trunc((a / b) * 100) / 100

  # creates a statement from the weather data
  @doc """
  Hello world.

  """
  def display_max_temps(locations_list \\ [], statement \\ "")

  def display_max_temps([], statement), do: statement

  def display_max_temps(locations, statement) do
    [ head | tail ] = locations
    {:ok, location, avg_max_temp} = head
    phrase = "#{location} Average Max Temp: #{avg_max_temp}\n"
    new_statement = statement <> phrase
    display_max_temps(tail, new_statement)
  end

  @doc """
  Hello world.

  """
  def call_and_print() do
    call_apis_async
    |> Enum.map(&validate_api_calls(&1))
    |> Enum.map(&process_response_data(&1))
    |> display_max_temps
  end
end

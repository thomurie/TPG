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

  @doc """
  Takes @urls and makes concurrent GET requests.

  Task is used as it allows us to separate and execute this action concurrently.

  Task.async_stream is used for a couple reasons:
  1. The response from the API is needed to continue, async_stream awaits the reply.
  2. async_stream allows us to identify how many tasks we want to run in parallel.

  Returns [{response}].
  """
  def call_apis_async() do
    @urls
    |> Task.async_stream(&HTTPoison.get/1, max_concurrency: 3)
    |> Enum.into([], fn {:ok, res} -> res end)
  end


  @doc """
  Validates our responses from the API calls.

  200 response lead to decoding and returning the JSON body of the response as a map.
  Returns %{response.body}.

  Other requests output a uniquie error to the user.
  (404) Returns "Not found."
  :error Returns HTTPoison.Error reason.

  With more time advanced error handling would be implemented
  allowing us to provide a better user experience
  """
  def validate_api_calls(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode!(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found."
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  @doc """
  First the average max temperature is calulated by:
    1. Extracting the forcasted weather from the location_data map.
    2. The weather data is iterated, each day is passed to get_temp
       function (see documentation below), get_temp extracts the max
       forcasted temperature is extracted and converted from
       centigrade to Farenheit.
    3. The list of max forcasted tempatures is passed to the avg_val
       function (see documentation below) where the average of the
       list is calculated.

  Second the name of the location is identified.

  The name of the location and the average forcasted max temperature
    is returned.
  Returns {:ok, string, float}.
  """
  def process_response_data(location_data) do
    avg_max_temp = Map.get(location_data, "consolidated_weather") |> Enum.map(&get_temp(&1)) |> avg_val
    location = Map.get(location_data, "title")
    {:ok, location, avg_max_temp}
  end

  @doc """
  Accepts a map containing the forcast details for a specific day.
  The max forcasted temperature is extracted from the map.
  The max forcasted temperature is converted from onverted from
      centigrade to Farenheit using the c_to_f function
      (see documentation below)

  Returns float.
  """
  def get_temp(weather_map) do
    Map.get(weather_map, "max_temp")
    |> c_to_f
  end

  @doc """
  Converts centigrade to Farenhiet using the common algorithm.
  The Meta Weather API returns temperature data in centigrade.
  The example response is in Farenhiet.

  Returns float.
  """
  def c_to_f(c), do: ((c * 9) / 5) + 32

  @doc """
  Finds the average value of a list.

  Returns float.
  """
  def avg_val(lst) do
    lst
    |> Enum.sum()
    |> divide(length(lst))
  end

  # find avg max temp
  @doc """
  Divides 2 numbers and truncates the number to the nearest 100th
    decimal place.

  Returns float.
  """
  def divide(a, b \\ 1), do: Kernel.trunc((a / b) * 100) / 100

  # creates a statement from the weather data
  @doc """
  Display max temps is split into 3 separate functions.

  The first is a header defining the default values.

  The second handles returning the statement once the list is
    empty.

  The third iterates through the list, extracting the location
    name and the average forcasted max temperature. It creates
    a phrase with this data and adds the phrase to the statement.
    The remaining locations and the modified are passed again to
    the function where the process is repeated until the
    conditions of the second definition is met.

  Returns string.
  """
  def display_max_temps(locations_list, statement \\ "")

  def display_max_temps([], statement), do: statement

  def display_max_temps(locations, statement) do
    [ head | tail ] = locations
    {:ok, location, avg_max_temp} = head
    phrase = "#{location} Average Max Temp: #{avg_max_temp}\n"
    new_statement = statement <> phrase
    display_max_temps(tail, new_statement)
  end

  @doc """
  The function that puts it all together.

  Calling this function makes a concurrent call to the urls,
  then validates the response, processes the response body,
  extracts the wanted data, creates a statement, returns the
  statement to the user.
  """
  def call_and_print() do
    call_apis_async
    |> Enum.map(&validate_api_calls(&1))
    |> Enum.map(&process_response_data(&1))
    |> display_max_temps
  end
end

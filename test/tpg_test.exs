defmodule TPGTest do
  use ExUnit.Case
  # doctest TPG

  @mock_api_response

  @urls [
    "https://www.metaweather.com/api/location/2487610/",
    "https://www.metaweather.com/api/location/2442047/",
    "https://www.metaweather.com/api/location/2366355/"
  ]

  test "makes concurrent get request, returns [responses]" do
    assert is_list(TPG.call_apis_async()) === true
  end

  test "validates response data, returns %{response.body}"do
    test_body = Poison.encode!(%{"name" => "test"})
    test_response = {:ok, %HTTPoison.Response{ body: test_body, status_code: 200 }}
    assert TPG.validate_api_calls(test_response) === %{"name" => "test"}
  end

  test "extracts the location name and avg max temp name from response, returns {:ok, location name, avg max temp}" do
    test_location = %{"consolidated_weather" => [%{"max_temp" => 0}], "title" => "Test1"}
    assert TPG.process_response_data(test_location) === {:ok, "Test1", 32.0}
  end

  test "extracts the max temp and coverts the temperature to Farenheit from the weather data for the day, returns int" do
    test_weather = %{"max_temp" => 0}
    assert TPG.get_temp(test_weather) === 32.0
  end

  test "converts centigrade to Farenhiet" do
    assert TPG.c_to_f(0) === 32.0
  end

  test "finds average value in a list(medium)" do
    assert TPG.avg_val([1, 2, 3, 4, 5, 6]) === 3.5
  end

  test "divides two numbers, returns up to the 100th place, returns int.00" do
    assert TPG.divide(4, 2) === 2.0
  end

  test "iterates through an array, creates phrases, adds phrase to statement, returns string " do
    test_data = [{:ok, "test1", 20}, {:ok, "test2", 40}, {:ok, "test3", 60}]
    assert TPG.display_max_temps(test_data) === "test1 Average Max Temp: 20\ntest2 Average Max Temp: 40\ntest3 Average Max Temp: 60\n"
  end

  test "makes api calls, cleans data, displays phrase" do
    assert is_binary(TPG.call_and_print()) === true
  end
end

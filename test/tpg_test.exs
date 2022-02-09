defmodule TPGTest do
  use ExUnit.Case
  doctest TPG

  test "API calls" do
    assert TPG.call_apis_async() === "yes"
  end

  test "finds average (simple)" do
    assert TPG.avg_max([2, 2, 2]) === 2.0
  end

  test "finds average (medium)" do
    assert TPG.avg_max([1, 2, 3, 4, 5, 6]) === 3.5
  end

  test "updates max temp data" do
    locations_test = %{
      test1: %{name: "test1", meta_weather_id: "2487610", avg_max_temp: 0},
      test2: %{name: "test2", meta_weather_id: "2442047", avg_max_temp: 0},
      test3: %{name: "test3", meta_weather_id: "2366355", avg_max_temp: 0}
    }

    locations_test = TPG.update_nested_map(locations_test, :test1, :avg_max_temp, 32)

    assert locations_test.test1.avg_max_temp === 32
  end

  test "returns updated temperatures" do
    locations_test = %{
      test1: %{name: "test1", meta_weather_id: "2487610", avg_max_temp: 0},
      test2: %{name: "test2", meta_weather_id: "2442047", avg_max_temp: 0},
      test3: %{name: "test3", meta_weather_id: "2366355", avg_max_temp: 0}
    }

    assert TPG.return_max_temps(locations_test) === "test1 Average Max Temp: 0\ntest2 Average Max Temp: 0\ntest3 Average Max Temp: 0\n"

  end

  test "accepts locations, returns avg max temp for each location" do
    locations_test = %{
      test1: %{name: "test1", meta_weather_id: "2487610", avg_max_temp: 32},
      test2: %{name: "test2", meta_weather_id: "2442047", avg_max_temp: 64},
      test3: %{name: "test3", meta_weather_id: "2366355", avg_max_temp: 94}
    }

    assert TPG.get_and_print_max_temps(locations_test) === "test1 Average Max Temp: 32\ntest2 Average Max Temp: 64\ntest3 Average Max Temp: 94\n"

  end
end

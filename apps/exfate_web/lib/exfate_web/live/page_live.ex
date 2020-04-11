defmodule ExfateWeb.PageLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(ExfateWeb.PageView, "index.html", assigns)
  end

  def mount(%{"a" => a} = _params, _session, socket) do
    [br, bo, ca, cl, co, fa] =
      case Integer.parse(a) do
        {n, _} -> parse_approaches(n)
        :error -> [0, 0, 0, 0, 0, 0]
      end

    {:ok,
     assign(socket, %{
       result: nil,
       modifiers: 0,
       brutal: br,
       bold: bo,
       cautious: ca,
       clever: cl,
       covert: co,
       fast: fa
     })}
  end

  def mount(_params, _session, socket) do
    values = %{
      result: nil,
      modifiers: 0,
      brutal: 0,
      bold: 0,
      cautious: 0,
      clever: 0,
      covert: 0,
      fast: 0
    }

    {:ok, assign(socket, values)}
  end

  def handle_event("roll", %{"approach" => approach_name}, socket) do
    approach = String.to_existing_atom(approach_name)
    approach_value = socket.assigns[approach]
    modifiers_value = socket.assigns[:modifiers]
    result = Map.merge(%{approach: String.capitalize(approach_name)}, roll(approach_value, modifiers_value))
    {:noreply, assign(socket, result: result, modifiers: 0)}
  end

  def handle_event("mod-inc", _, socket) do
    {:noreply, update(socket, :modifiers, &(&1 + 1))}
  end

  def handle_event("mod-dec", _, socket) do
    {:noreply, update(socket, :modifiers, &(&1 - 1))}
  end

  defp roll(approach, modifiers) do
    rolls = for _ <- 1..4, do: :rand.uniform(3) - 2
    effort = Enum.reduce(rolls, &(&1 + &2)) + approach + modifiers

    %{
      effort: effort,
      ladder: to_ladder(effort),
      rolls: "#{inspect(rolls)} + #{approach} + #{modifiers}"
    }
  end

  defp parse_approaches(n) do
    for index <- 5..0, do: (n / :math.pow(10, index)) |> round() |> Integer.mod(10)
  end

  defp to_ladder(n) do
    case n do
      _ when n > 8 -> "above Legendary"
      +8 -> "Legendary"
      +7 -> "Epic"
      +6 -> "Fantastic"
      +5 -> "Superb"
      +4 -> "Great"
      +3 -> "Good"
      +2 -> "Fair"
      +1 -> "Average"
      +0 -> "Mediocre"
      -1 -> "Poor"
      -2 -> "Terrible"
      _ when n < -2 -> "below Terrible"
    end
  end
end

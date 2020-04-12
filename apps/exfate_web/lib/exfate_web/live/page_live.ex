defmodule ExfateWeb.PageLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(ExfateWeb.PageView, "index.html", assigns)
  end

  def mount(params, _session, socket) do
    [br, bo, ca, cl, co, fa] =
      case params |> Map.get("a", "0") |> Integer.parse() do
        {n, _} -> parse_approaches(n)
        :error -> [0, 0, 0, 0, 0, 0]
      end

    values = %{
      user: Map.get(params, "u", "someone"),
      result: nil,
      modifiers: 0,
      brutal: br,
      bold: bo,
      cautious: ca,
      clever: cl,
      covert: co,
      fast: fa
    }

    {:ok, assign(socket, values)}
  end

  def handle_event("roll", %{"approach" => approach_name}, socket) do
    approach = String.to_existing_atom(approach_name)
    approach_value = socket.assigns[approach]
    modifiers_value = socket.assigns[:modifiers]

    result =
      Map.merge(
        %{approach: String.capitalize(approach_name)},
        roll(approach_value, modifiers_value)
      )

    send(self(), :send_to_discord)

    {:noreply, assign(socket, result: result, modifiers: 0)}
  end

  def handle_event("mod-inc", _, socket) do
    {:noreply, update(socket, :modifiers, &(&1 + 1))}
  end

  def handle_event("mod-dec", _, socket) do
    {:noreply, update(socket, :modifiers, &(&1 - 1))}
  end

  def handle_info(:send_to_discord, socket) do
    r = socket.assigns.result
    u = String.capitalize(socket.assigns.user)

    webhook =
      ("https://discordapp.comm/api/webhooks/" <>
         Application.get_env(:exfate, :discord_token))
      |> String.to_charlist()

    payload =
      "{\"content\": \"#{u}'s #{r.approach} approach is #{r.ladder}!" <>
        " (#{if(r.effort >= 0, do: "+")}#{r.effort})\"}"

    {:ok, {{_, 204, _}, _, _}} =
      :httpc.request(
        :post,
        {webhook, [], 'application/json', payload},
        [],
        []
      )

    {:noreply, socket}
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

defmodule ExfateWeb.DiceLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <form phx-change="change" phx-submit="roll">
        <table style="width: initial">
          <tr><td><label>Brutal</label></td><td><input type="number" min="0" max="3" name="brutal" value="<%= @brutal %>"></td><td><input style="width: 100%" type="submit" phx-click="submit" value="roll brutal"></td></tr>
          <tr><td><label>Bold</label></td><td><input type="number" min="0" max="3" name="bold" value="<%= @bold %>"></td><td><input style="width: 100%" type="submit" phx-click="submit" value="roll bold"></td></tr>
          <tr><td><label>Cautious</label></td><td><input type="number" min="0" max="3" name="cautious" value="<%= @cautious %>"></td><td><input style="width: 100%" type="submit" phx-click="submit" value="roll cautious"></td></tr>
          <tr><td><label>Clever</label></td><td><input type="number" min="0" max="3" name="clever" value="<%= @clever %>"></td><td><input style="width: 100%" type="submit" phx-click="submit" value="roll clever"></td></tr>
          <tr><td><label>Covert</label></td><td><input type="number" min="0" max="3" name="covert" value="<%= @covert %>"></td><td><input style="width: 100%" type="submit" phx-click="submit" value="roll covert"></td></tr>
          <tr><td><label>Fast</label></td><td><input type="number" min="0" max="3" name="fast" value="<%= @fast %>"></td><td><input style="width: 100%" type="submit" phx-click="submit" value="roll fast"></td></tr>
          <tr><td><label>modifiers</label></td><td colspan="2"><input type="number" name="modifiers" value="<%= @modifiers %>"></td></tr>
        </table>
      </form>
    </div>
    <div>
      <%= if @result do %>
        <h1><b><i><%= @result.ladder %> <%= @approach |> to_string() |> String.capitalize() %> approach!</i></b></h1>
        <h3><%= @result.rolls %> = <%= @result.effort %></h3>
      <% end %>
    </div>
    """
  end

  def mount(%{"a" => a} = _params, _session, socket) do
    [br, bo, ca, cl, co, fa] =
      case Integer.parse(a) do
        {n, _} -> parse_approaches(n)
        :error -> [0, 0, 0, 0, 0, 0]
      end

    {:ok,
     assign(socket, %{
       approach: nil,
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
      approach: nil,
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

  def handle_event("change", params, socket) do
    [target] = params["_target"]
    {:noreply, assign(socket, String.to_existing_atom(target), String.to_integer(params[target]))}
  end

  def handle_event("submit", params, socket) do
    "roll " <> approach = params["value"]
    {:noreply, assign(socket, approach: String.to_existing_atom(approach))}
  end

  def handle_event("roll", _params, socket) do
    approach = socket.assigns[socket.assigns[:approach]]
    modifiers = socket.assigns[:modifiers]
    {:noreply, assign(socket, result: roll(approach, modifiers), modifiers: 0)}
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

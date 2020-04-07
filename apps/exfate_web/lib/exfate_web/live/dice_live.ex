defmodule ExfateWeb.DiceLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
    <h1>4dF + <%= @modifiers %> = <%= @result %></h1>
    <button phx-click="inc">+</button>
    <button phx-click="dec">-</button>
    <button phx-click="roll">roll</button>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, modifiers: 2, result: "?")}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :modifiers, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :modifiers, &(&1 - 1))}
  end

  def handle_event("roll", _, socket) do
    modifiers = socket.assigns.modifiers
    {:noreply, update(socket, :result, fn _ -> random_integer(-4, 4) + modifiers end)}
  end

  defp random_integer(lower_limit, upper_limit) do
    lower_limit + :rand.uniform(upper_limit - lower_limit + 1) - 1
  end
end

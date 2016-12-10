defmodule MysteryPotion do
  @api_url "http://feeds.stri.nz/api/"

  def login(user, pass) do
    HTTPoison.post!(@api_url, ~s({"op":"login","user":"#{user}","password":"#{pass}"})).body
    |> Poison.decode!
    |> Map.get("content")
    |> Map.get("session_id")
  end

  def get_feeds(session_id, category) do
    HTTPoison.post!(@api_url, ~s({"sid":"#{session_id}","op":"getFeeds","cat_id":"#{category}","unread_only":"true"})).body
    |> Poison.decode!
    |> Map.get("content")
  end

  def random_feed(user, pass) do
    get_feeds(login(user, pass), "-4") |> Enum.random
  end

  def run do
    random_feed("user", "pass")
  end
end

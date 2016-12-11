defmodule MysteryPotion do
  @api_url "http://feeds.stri.nz/api/"

  def login(user, pass) do
    HTTPoison.post!(@api_url, ~s({"op":"login","user":"#{user}","password":"#{pass}"})).body
    |> Poison.decode!
    |> Map.get("content")
    |> Map.get("session_id")
  end

  def start_agent do
    FeedAgent.run(login("user", "pass"))
  end

  def run do
    pid = spawn(&MysteryPotion.start_agent/0)
    send(pid, {:get_random_feed, self()})
    receive do r -> r end
  end
end

defmodule FeedAgent do
  @api_url "http://feeds.stri.nz/api/"

  def get_feeds(token, category) do
    HTTPoison.post!(@api_url, ~s({"sid":"#{token}","op":"getFeeds","cat_id":"#{category}","unread_only":"true"})).body
    |> Poison.decode!
    |> Map.get("content")
  end

  def random_article(token) do
    random_feed(token)
    |> Map.get("id")
    # ...
  end

  def random_feed(token) do
    get_feeds(token, "-4") |> Enum.random
  end

  def run(session_id) do
    receive do
      {:get_random_feed, from} ->
        send(from, random_feed(session_id))
    end
  end
end

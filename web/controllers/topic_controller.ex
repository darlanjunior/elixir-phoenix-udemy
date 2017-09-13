defmodule Discuss.TopicController do
  use Discuss.Web, :controller
  alias Discuss.Topic

  plug Discuss.Plugs.Authorize when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:edit, :update, :delete]

  def show(conn, %{"id" => topic_id}) do
    topic = Repo.get!(Topic, topic_id)
    render conn, "show.html", topic: topic
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{})

    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"topic" => topic}) do
    changeset = conn.assigns.user
    |> build_assoc(:topics)
    |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Topic Created")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset #redirect
    end
  end

  def index(conn, _) do
    render conn, "index.html", topics: Repo.all(Topic)
  end

  def edit(conn, %{"id" => id}) do
    case Repo.get(Topic, id) do
      nil ->
        render conn, "index.html"
      topic ->
        render(
          conn,
          "edit.html",
          changeset: Topic.changeset(topic),
          topic: topic
        )
    end
  end

  def update(conn, %{"topic" => topic, "id" => id}) do
    old_topic = Repo.get(Topic, id)
    update = old_topic
    |> Topic.changeset(topic)
    |> Repo.update

    case update do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render(
          conn,
          "edit.html",
          changeset: changeset,
          topic: old_topic
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    Repo.get!(Topic, id)
    |> Repo.delete!

    conn
    |> put_flash(:info, "Topic Removed")
    |> redirect(to: topic_path(conn, :index))
  end

  def check_topic_owner(conn, _params) do
    %{params: %{"id" => id}} = conn
    topic_user = Repo.get!(Topic, id).user_id
    current_user = conn.assigns.user.id

    if topic_user == current_user do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to edit this.")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end
end

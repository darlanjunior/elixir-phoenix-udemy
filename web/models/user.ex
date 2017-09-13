defmodule Discuss.User do
  use Discuss.Web, :model

  schema "users" do
    field :token, :string
    field :email, :string
    field :provider, :string
    has_many :topics, Discuss.Topic
    has_many :comments, Discuss.Comment

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:token, :email, :provider])
    |> validate_required([:token, :email, :provider])
  end
end

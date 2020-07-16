defmodule ChatApiWeb.ConversationChannelTest do
  use ChatApiWeb.ChannelCase

  alias ChatApi.Accounts

  setup do
    {:ok, account} = Accounts.create_account(%{company_name: "Taro"})

    {:ok, _, socket} =
      ChatApiWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(ChatApiWeb.ConversationChannel, "conversation:lobby")

    %{socket: socket, account: account}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to conversation:lobby", %{socket: socket, account: account} do
    msg = %{body: "Hello world!", account_id: account.id}
    push(socket, "shout", msg)
    assert_broadcast "shout", msg
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
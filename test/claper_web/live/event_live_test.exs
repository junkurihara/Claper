defmodule ClaperWeb.EventLiveTest do
  use ClaperWeb.ConnCase

  import Phoenix.LiveViewTest
  import Claper.{PresentationsFixtures}

  @update_attrs %{name: "some updated name"}

  defp create_event(params) do
    presentation_file = presentation_file_fixture(%{user: params.user}, [:event])
    presentation_state_fixture(%{presentation_file: presentation_file})
    params |> Map.put(:presentation_file, presentation_file)
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_event]

    test "lists all events", %{conn: conn, presentation_file: presentation_file} do
      {:ok, _index_live, html} = live(conn, Routes.event_index_path(conn, :index))

      assert html =~ "presentations"
      assert html =~ presentation_file.event.name
    end

    test "updates event in listing", %{conn: conn, presentation_file: presentation_file} do
      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))

      assert index_live |> element("#event-#{presentation_file.event.uuid} a", "Edit") |> render_click() =~
               "Edit"

      assert_patch(index_live, Routes.event_index_path(conn, :edit, presentation_file.event.uuid))

      {:ok, _, html} =
        index_live
        |> form("#event-form", event: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.event_index_path(conn, :index))

      assert html =~ "Updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes event in listing", %{conn: conn, presentation_file: presentation_file} do
      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))

      assert index_live |> element("#event-#{presentation_file.event.uuid} a", "Edit") |> render_click() =~
               "Edit"

      {:ok, conn} = index_live |> element(~s{a[phx-value-id=#{presentation_file.event.uuid}]}) |> render_click()
      |> follow_redirect(conn, Routes.event_index_path(conn, :index))

      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))


      refute has_element?(index_live, "#event-#{presentation_file.event.uuid}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_event]

    test "displays event", %{conn: conn, presentation_file: presentation_file} do

      {:ok, _show_live, html} = live(conn, Routes.event_show_path(conn, :show, presentation_file.event.code))

      assert html =~ "Be the first to react"
      assert html =~ presentation_file.event.name
    end

  end
end

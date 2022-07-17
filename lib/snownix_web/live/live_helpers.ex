defmodule SnownixWeb.LiveHelpers do
  use Phoenix.HTML
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  import SnownixWeb.UtilsHelpers

  alias Phoenix.LiveView.JS

  @meta_list %{
    "title" => %{field: :page_title, default: "Snownix"},
    "description" => %{field: :page_desc, default: nil},
    "keywords" => %{field: :page_keywords, default: nil},
    "og:title" => %{field: :page_title, default: "Snownix"},
    "og:image" => %{field: :page_image, default: nil},
    "og:type" => %{field: :page_ogtype, default: "website"},
    "og:url" => %{field: :page_url, default: nil},
    "og:description" => %{field: :page_desc, default: nil},
    "og:site_name" => %{field: :page_sitename, default: "Snownix"},
    "twitter:card" => %{field: :page_twitter_card, default: "summary"},
    "twitter:title" => %{field: :page_title, default: "Snownix"},
    "twitter:site" => %{field: :page_url, default: nil},
    "twitter:image:src" => %{field: :page_image, default: nil},
    "twitter:creator" => %{field: :page_user, default: "Snownix"},
    "twitter:description" => %{field: :page_desc, default: nil},
    "robots" => %{field: :page_robots, default: "index, follow"},
    "language" => %{field: :page_lang, default: "English"}
  }

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.menu_index_path(@socket, :index)}>
        <.live_component
          module={SnownixWeb.MenuLive.FormComponent}
          id={@menu.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.menu_index_path(@socket, :index)}
          menu: @menu
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <%= live_patch "✖",
            to: @return_to,
            id: "close",
            class: "phx-modal-close",
            phx_click: hide_modal()
          %>
        <% else %>
         <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  @doc """
  Format an integer to a floating point with 2 franctional digits
  """
  def float_format(number) when is_integer(number) do
    Float.round(number / 100, 2)
    |> :erlang.float_to_binary(decimals: 2)
  end

  def float_format(_), do: nil

  @doc """
  Format naive date
  """
  def date_format(nil), do: nil

  def date_format(utc_date) do
    utc_date |> Calendar.strftime("%a, %B %d %Y")
  end

  def hour_format(nil), do: nil

  def hour_format(utc_date) do
    utc_date
    |> DateTime.from_naive!("Etc/UTC")
    |> Calendar.strftime("%H:%M")
  end

  def datetime_format(nil), do: nil

  def datetime_format(utc_date) do
    utc_date |> DateTime.from_naive!("Etc/UTC") |> Calendar.strftime("%a, %B %d %Y %H:%M:%S")
  end

  def money_format(price, currency) do
    if !is_nil(currency) and is_integer(price) do
      Money.to_string(Money.new(price, currency))
    else
      nil
    end
  end

  def money_format(%{price: price, currency: currency}) do
    money_format(price, currency)
  end

  def money_format(_), do: nil

  def money_symbole(currency), do: Money.Currency.symbol(currency)
  def percentage_format(nil), do: nil

  def percentage_format(percent) do
    "#{Float.round(percent / 100)}%"
  end

  def tax_format(percent), do: percentage_format(percent)

  @doc """
  Assign meta tags
  """
  def put_meta_tags(socket, params \\ %{}) do
    socket
    |> assign(params)
  end

  @doc """
  Generate meta tags using available assigns data
  """
  def put_meta_tags_list(assigns) do
    meta_tags =
      @meta_list
      |> Enum.reduce("", fn {name, %{field: field, default: default}}, metas ->
        if is_nil(assigns[field]) && is_nil(default) do
          metas
        else
          ~H"""
          <%= metas %>
          <%= generate_meta_tag(name, assigns[field] || default) %>
          """
        end
      end)

    if assigns[:page_image] do
      ~H"""
      <%= meta_tags %>
      <meta content="summary_large_image" name="twitter:card">
      """
    else
      meta_tags
    end
  end

  def generate_meta_tag(name, content, assigns \\ %{}) do
    ~H"""
      <meta name={name} content={content}>
    """
  end

  def tag_has_error(form, field) do
    form.errors
    |> Keyword.get_values(field)
    |> Enum.count() > 0
  end

  def tag_class_error(form, field) do
    has_errors = tag_has_error(form, field)

    if has_errors do
      " error "
    else
      nil
    end
  end

  def checkbox_value(form, name) do
    input_value(form, name) == true || input_value(form, name) == "true"
  end

  def render_user_avatar(assigns, user, size \\ "w-10 h-10") do
    ~H"""
      <%= if is_nil(get_user_avatar(user)) do %>
          <div class={size<>" avatar__text !text-base"}><%= get_user_avatar_text(user) %></div>
      <% else %>
          <img src={get_user_avatar(user)} class={size<>" avatar !rounded-xl"}>
      <% end %>
    """
  end

  def render_project_logo(assigns, project, size \\ "w-10 h-10") do
    ~H"""
      <div class={"project__logo " <> size }>
        <%= if is_nil(get_project_logo(project)) do %>
          <div class={ size <>" avatar__text !text-base"}><%= get_project_logo_text(project) %></div>
        <% else %>
          <img src={get_project_logo(project)} class={ size <>" avatar !rounded-xl"}>
        <% end %>
      </div>
    """
  end

  def render_text_avatar(assigns, text, size \\ "w-10 h-10") do
    ~H"""
      <div class="flex flex-shrink-0 items-center justify-center  duration-100
        hover:ring-4 hover:ring-offset-2 hover:ring-dark hover:ring-opacity-30 rounded-xl w-10 h-10">
        <div class={size<>" avatar__text !text-base"}><%= get_avatar_text(text) %></div>
      </div>
    """
  end

  def identifier_format(format, params) do
    Snownix.Invoices.identifier_format(format, params)
  end
end

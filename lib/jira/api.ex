defmodule Jira.API do
  defp config_or_env(key, env_var) do
    Application.get_env(:jira, key, System.get_env(env_var))
  end

  defp host do
    config_or_env(:host, "JIRA_HOST")
  end

  defp username do
    config_or_env(:username, "JIRA_USERNAME")
  end

  defp password do
    config_or_env(:password, "JIRA_PASSWORD")
  end

  ### Req callbacks
  @spec req():: Req.Request.t()
  def req() do
    Req.new(base_url: host(), auth: {username(), password()})
  end

  ### API
  def boards do
    get!("/rest/greenhopper/1.0/rapidview")
  end

  def sprints(board_id) when is_integer(board_id) do
    get!("/rest/greenhopper/1.0/sprintquery/#{board_id}")
  end

  def sprints(%{"id" => board_id}), do: sprints(board_id)

  def sprint_report(board_id, sprint_id) do
    get!(
      "/rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=#{board_id}&sprintId=#{
        sprint_id
      }"
    )
  end

  def ticket_details(key) do
    get!("/rest/api/2/issue/#{key}")
  end

  def add_ticket_comment(key, comment) do
    body = %{"body"=> comment}
    post_as_json!("/rest/api/2/issue/#{key}/comment", body)
  end

  def add_ticket_link(key, title, link) do
    body = %{"object" => %{"url" => link, "title" => title}}
    post_as_json!("/rest/api/2/issue/#{key}/remotelink", body)
  end

  def add_ticket_watcher(key, username) do
    post_as_json!("/rest/api/2/issue/#{key}/watchers", username)
  end

  def set_ticket_estimate(key, estimate) do
    body = %{"fields" => %{"customfield_10002" => estimate}}
    put_as_json!("/rest/api/2/issue/#{key}", body)
  end

  def set_custom_field(key, custom_field, value) do
    body = %{"fields" => %{custom_field => value}}
    put_as_json!("/rest/api/2/issue/#{key}", body)
  end

  def search(query) do
    post_as_json!("/rest/api/2/search", query)
  end

  def get!(path) do
    {:ok, response} = Req.get(req(), url: path)
    response.body
  end

  def post_as_json!(path, content) do
    {:ok, response} = Req.post(req(), url: path, json: content)
    response.body
  end

  def post!(path, content) do
    {:ok, response} = Req.post(req(), url: path, form: content)
    response.body
  end

  def put_as_json!(path, content) do
    Req.put(req(), url: path, json: content)
  end

  def put!(path, content) do
    {:ok, response} = Req.put(req(), url: path, form: content)
    response.body
  end
end

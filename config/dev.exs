import Config
config :logger, :console,
  level: :debug,
  metadata: [:mfa, :line],
  format: {LogFormatter, :format}

defmodule LogFormatter do
  def format(level, message, _timestamp, metadata) do
    src =
      case Keyword.get(metadata, :mfa) do
        {m, f, a} -> "[#{level}] [#{m}][#{f}/#{a}]"
        _ -> nil
      end

    string = "#{src} #{message}"
    string <> "\n"
  end
end

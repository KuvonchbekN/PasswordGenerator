defmodule Generator do
  @moduledoc """
  A console application for generating passwords.
  """

  @symbols "@!$#%^&*"
  @word_list ~w(
    apple banana cherry date elderberry fig grape honeydew kiwi lemon mango nectarine
    orange papaya quince raspberry strawberry tangerine ugli watermelon xigua yam zucchini
    ramp collapse marc neologians
  )

  def main(args) do
    {opts, _, _} = OptionParser.parse(args,
      switches: [
        type: :string,
        "min-length": :integer,
        "max-length": :integer,
        uppercase: :boolean,
        numbers: :boolean,
        symbols: :boolean,
        separator: :string,
        file: :string,
        help: :boolean
      ],
      aliases: [h: :help]
    )

    if Keyword.get(opts, :help, false) do
      print_help()
      System.halt(0)
    end

    # Use Keyword.get instead of Map.get
    type = Keyword.get(opts, :type, "chars")
    min_length = Keyword.get(opts, :"min-length", (if type == "chars", do: 8, else: 2))
    max_length = Keyword.get(opts, :"max-length", (if type == "chars", do: 16, else: 5))
    uppercase = Keyword.get(opts, :uppercase, false)
    numbers = Keyword.get(opts, :numbers, false)
    symbols = Keyword.get(opts, :symbols, false)
    separator = Keyword.get(opts, :separator, "-")
    file = Keyword.get(opts, :file, nil)

    # Validate min and max lengths
    if min_length > max_length do
      IO.puts("Error: --min-length cannot be greater than --max-length")
      System.halt(1)
    end

    # Generate password based on type
    password =
      case type do
        "chars" -> generate_chars(min_length, max_length, uppercase, numbers, symbols)
        "words" -> generate_words(min_length, max_length, uppercase, separator)
        _ ->
          IO.puts("Error: Invalid type. Allowed types are 'chars' and 'words'.")
          System.halt(1)
      end

    # Output or save to file
    if file do
      case File.write(file, password) do
        :ok -> :ok
        {:error, reason} -> IO.puts("Error writing to file: #{reason}")
      end
    else
      IO.puts(password)
    end
  end

  defp generate_chars(min_length, max_length, uppercase, numbers, symbols) do
    length = Enum.random(min_length..max_length)

    base_chars = "abcdefghijklmnopqrstuvwxyz"
    base_chars = if uppercase, do: base_chars <> "ABCDEFGHIJKLMNOPQRSTUVWXYZ", else: base_chars
    base_chars = if numbers, do: base_chars <> "0123456789", else: base_chars
    base_chars = if symbols, do: base_chars <> @symbols, else: base_chars

    1..length
    |> Enum.map(fn _ -> String.at(base_chars, :rand.uniform(String.length(base_chars)) - 1) end)
    |> Enum.join()
  end

  defp generate_words(min_length, max_length, uppercase, separator) do
    # Filter words based on min and max length
    filtered_words =
      @word_list
      |> Enum.filter(fn word -> String.length(word) >= min_length and String.length(word) <= max_length end)

    # If no words match the criteria, notify the user
    if length(filtered_words) == 0 do
      IO.puts("No words found with the specified length constraints.")
      System.halt(1)
    end

    # Decide the number of words based on min and max length
    num_words = Enum.random(min_length..max_length)

    words =
      1..num_words
      |> Enum.map(fn _ ->
        word = Enum.random(filtered_words)
        if uppercase do
          String.capitalize(word)
        else
          word
        end
      end)

    Enum.join(words, separator)
  end

  defp print_help do
    IO.puts("""
    Usage:
      GENERATOR.exe [options]

    Options:
      --type=chars|words         Type of password to generate (default: chars)
      --min-length=NUMBER        Minimum length (default: 8 for chars, 2 for words)
      --max-length=NUMBER        Maximum length (default: 16 for chars, 5 for words)
      --uppercase                Include uppercase letters (chars) or capitalize words (words)
      --numbers                  Include numbers in the password (chars)
      --symbols                  Include symbols in the password (chars)
      --separator=SEPARATOR      Separator between words (words, default: -)
      --file=PATH                Save the password to a file instead of printing
      -h, --help                 Show this help message
    """)
  end
end

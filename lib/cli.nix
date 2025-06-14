{ lib }:

rec {
  /**
    Automatically convert an attribute set to command-line options.

    This helps protect against malformed command lines and also to reduce
    boilerplate related to command-line construction for simple use cases.

    `toGNUCommandLineShell` returns an escaped shell string.

    # Inputs

    `options`

    : How to format the arguments, see `toGNUCommandLine`

    `attrs`

    : The attributes to transform into arguments.

    # Examples
    :::{.example}
    ## `lib.cli.toGNUCommandLineShell` usage example

    ```nix
    cli.toGNUCommandLineShell {} {
      data = builtins.toJSON { id = 0; };
      X = "PUT";
      retry = 3;
      retry-delay = null;
      url = [ "https://example.com/foo" "https://example.com/bar" ];
      silent = false;
      verbose = true;
    }
    => "'-X' 'PUT' '--data' '{\"id\":0}' '--retry' '3' '--url' 'https://example.com/foo' '--url' 'https://example.com/bar' '--verbose'";
    ```

    :::
  */
  toGNUCommandLineShell = options: attrs: lib.escapeShellArgs (toGNUCommandLine options attrs);

  /**
    Automatically convert an attribute set to a list of command-line options.

    `toGNUCommandLine` returns a list of string arguments.

    # Inputs

    `options`

    : How to format the arguments, see below.

    `attrs`

    : The attributes to transform into arguments.

    # Options

    `mkOptionName`

    : How to string-format the option name;
    By default one character is a short option (`-`), more than one characters a long option (`--`).

    `mkBool`

    : How to format a boolean value to a command list;
    By default it’s a flag option (only the option name if true, left out completely if false).

    `mkList`

    : How to format a list value to a command list;
    By default the option name is repeated for each value and `mkOption` is applied to the values themselves.

    `mkOption`

    : How to format any remaining value to a command list;
    On the toplevel, booleans and lists are handled by `mkBool` and `mkList`, though they can still appear as values of a list.
    By default, everything is printed verbatim and complex types are forbidden (lists, attrsets, functions). `null` values are omitted.

    `optionValueSeparator`

    : How to separate an option from its flag;
    By default, there is no separator, so option `-c` and value `5` would become ["-c" "5"].
    This is useful if the command requires equals, for example, `-c=5`.

    # Examples
    :::{.example}
    ## `lib.cli.toGNUCommandLine` usage example

    ```nix
    cli.toGNUCommandLine {} {
      data = builtins.toJSON { id = 0; };
      X = "PUT";
      retry = 3;
      retry-delay = null;
      url = [ "https://example.com/foo" "https://example.com/bar" ];
      silent = false;
      verbose = true;
    }
    => [
      "-X" "PUT"
      "--data" "{\"id\":0}"
      "--retry" "3"
      "--url" "https://example.com/foo"
      "--url" "https://example.com/bar"
      "--verbose"
    ]
    ```

    :::
  */
  toGNUCommandLine =
    {
      mkOptionName ? k: if builtins.stringLength k == 1 then "-${k}" else "--${k}",

      mkBool ? k: v: lib.optional v (mkOptionName k),

      mkList ? k: v: lib.concatMap (mkOption k) v,

      # any preprocessing of an attribute value of type "override"
      # before we attempt to convert it to a command line option;
      # by default we extract its "content" attribute.
      #
      # See also the mention of this attribute in the comments for `mkOption`.
      unwrapOverride ? v: v.content,

      # NOTE: If you modify this attribute to support attrsets that might
      # have a "_type" attribute named "override", then consider whether
      # to also specify a non-default value for `unwrapOverride`.
      mkOption ?
        k: v:
        if v == null then
          [ ]
        else if optionValueSeparator == null then
          [
            (mkOptionName k)
            (lib.generators.mkValueStringDefault { } v)
          ]
        else
          [ "${mkOptionName k}${optionValueSeparator}${lib.generators.mkValueStringDefault { } v}" ],

      optionValueSeparator ? null,
    }:
    options:
    let
      render =
        k: raw:
        let
          v = if lib.isType "override" raw then
              unwrapOverride raw
            else
              raw;
        in
          if builtins.isBool v then
            mkBool k v
          else if builtins.isList v then
            mkList k v
          else
            mkOption k v;

    in
    builtins.concatLists (lib.mapAttrsToList render options);
}

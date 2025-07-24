# Development

If you're new to chezmoi, you might find these notes useful.

## Preview templating variables

Chezmoi has it's internal variables accessible in templates under 
`.chezmoi`. Additionally, you can extend the variables with your
own, sourced from files in `.chezmoidata` and the main config file
`.chezmoi.toml.tmpl`. You can preview them at any time with:

```
chezmoi data
```

If your main config contains variables that need an input, such as
`.email`, you first need to run `chezmoi init`. It will show prompts
that later will be used to populate variables in `.chezmoi.toml.tmpl`.

> TOML is only one of supported formats. See [the docs](https://www.chezmoi.io/reference/special-files/chezmoi-format-tmpl/).

---
title: "Hugo & dynamic copyright year"
date: 2021-01-06T12:10:39Z
---

# Quick answer

There are only two steps:

1. **Modify your config** to change `copyright` to contain either `%s`/`%d`
   or some type of text placeholder instead of year value.
2. **Modify your footer template** and use either `printf` or `replace` _(depends on the previous decision)_
   to inject `{{ now.Format "2006" }}` as the year value to the copyright text.

# Intro

Most of the pages contains the copyright section in the page's footer.
When we use Hugo, we specify the content of copyright in the _config_ file and we use that value in _footer_ template.

A typical placeholder looks like this: "Copyright © 2021 Rick Sanchez".
What we want to accomplish is to make the year value dynamic, so we don't need to manually update it every year.
We specify it in the config, and the year value is updated when we trigger a new build.

As I mentioned in the quick answer thera are only two steps: config update and template tweak.

# Step 1 - Config change

Here we have a piece of hypothetical `config.yaml`:
```yaml
...
title: "Wubba Lubba Dub Dub!"
copyright: "Copyright © 2021 Rick Sanchez"
description: "Journal of Rick Sanchez"
...
```
We stil want to keep the copyright here, but need to inject the value somehow.

One option would be to use `%s` (or `%d`) and string formatting using `printf` at footer template.
With that option the copyright would look like:
```yaml
copyright: "Copyright © %s Rick Sanchez"
```
It is simple solution, and we know what `%s` means, still it is not expressive.
It is clear for you now, when we write it, but it might not be so clear
for someone using your theme or even for you after a couple of months.
The other option, that is actually more expressive and which I prefer more, is using a placeholder like `:YEAR:`:
```yaml
copyright: "Copyright © :YEAR: Rick Sanchez"
```

In addition, we can provide an optional parameter to customize the placeholder:
```yaml
copyright: "Copyright © <YYYY> Rick Sanchez"
copyrightYearToken: "<YYYY>"
```
Isn't more expressive? Moreover, if your copyright is more complex,
and you wish to more than one dynamic value, this approach really shines.

# Step 2 - Update footer template

We need now update the footer template. We can do it either by:
- modifying the footer at the theme _(in case when you create your own theme or forked someone's theme)_ or
- overriding the footer partial in your project.

Either approach you choose, the footer.html could look like this:
```html
<footer id="footer">
  {{ .Site.Params.copyright }}
</footer>
```

We need now to replace that token. You can do it by using `replace` function like below:
```html
<footer id="footer">
  {{ replace $.Site.Params.copyright ":YEAR:" (string (now.Format "2006")) }}
</footer>
```

In case you want to support placeholder customization:
```html
<footer id="footer">
  {{ $yearToken := (cond (isset .Site.Params (lower "copyrightYearToken")) $.Site.Params.copyrightYearToken ":YEAR:") }}
  {{ replace $.Site.Params.copyright $yearToken (string (now.Format "2006")) }}
</footer>
```
With this code, the token is set depends on existence of `copyrightYearToken` property.
If it exists, use it, if not use the default `:YEAR:`. Simple like that.

# Conclusion

Having a dynamic year value in your copyrights is fairly easy to accomplish.

If you wish you can have a look at my [footer.html][my_footer]
and [my config][my_config] at the time when I wrote this text.

[my_footer]: https://github.com/rynkowsg/etch/blob/06ce3f9/layouts/partials/footer.html
[my_config]: https://github.com/rynkowsg/personal-blog/blob/2655f14/config.yaml#L8

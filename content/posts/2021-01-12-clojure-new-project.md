---
title: "Generate, build & run new project with Clojure"
date: 2021-01-12T07:44:47Z
---

Creating a new running project is a fairly simple task with project generators.
It takes a very little to create a template project and build a uberjar ready to be shipped.
It is not going to do anything, but it helps us to get up to speed quickly and have a artifact we can deploy.

I don't cover here REPL. Yes, it is one of the greatest features of the language,
still my intention is to make here an introduction kinda "how to build and run",
similar to programmers of other languages.

In this article I focus mainly on using Leiningen and deps tooling,
not because they are the best, but because I use them :)

## Leiningen

`lein` has built-in `new` command.
Assuming you have Leiningen installed, to create a new command you just need to type:
```shell
$ lein new app myapp
Generating a project called myapp based on the 'app' template.
```
> Note: If you are running this command for the first time, you might see a long log of fetched dependencies.

Generated project looks like below:
```shell
% tree -a myapp                                                                                                                                                                                                                                    !3999
myapp
├── .gitignore
├── .hgignore
├── CHANGELOG.md
├── LICENSE
├── README.md
├── doc
│   └── intro.md
├── project.clj
├── resources
├── src
│   └── myapp
│       └── core.clj
└── test
    └── myapp
        └── core_test.clj

6 directories, 9 files
```

As you can notice, it contains `project.clj` file which is the heart of Leiningen based projects.
```clojure
(defproject myapp "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies [[org.clojure/clojure "1.10.1"]]
  :main ^:skip-aot myapp.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all
                       :jvm-opts ["-Dclojure.compiler.direct-linking=true"]}})

```
It contains basic configuration: lists needed dependencies, specifies entry namespace and provides uberjar.
Let's try to execute the project:
```shell
$ lein run -m myapp.core                                                                                                                                                                                                                                                !4001
Hello, World!
```
Let's check out the uberjar support:
```shell
$ lein uberjar                                                                                                                                                                                                                                                          !4002
Compiling myapp.core
Created /Users/greg/Sources/rynkowski/example/mypp/target/uberjar/myapp-0.1.0-SNAPSHOT.jar
Created /Users/greg/Sources/rynkowski/example/mypp/target/uberjar/myapp-0.1.0-SNAPSHOT-standalone.jar
```
and then, lets try to run the app from jar:
```shell
java -jar target/uberjar/myapp-0.1.0-SNAPSHOT-standalone.jar                                                                                                                                                                                                          !4003
Hello, World!
```
All good!

## `clj` and "deps" tooling

"deps" tooling has been added to Clojure in version 1.9.
From that point, package managers like Leiningen or Boot are no longer need to use Clojure.

The introduction to `deps.edn` is out-of-scope of this article.
Think about `deps.edl` as a config file, similar to Leiningen's `project.clj`.

To generate a Clojure _deps_ project, the most idiomatic way would be to use
[`seancorfield/clj-new`][github-clj-new].
The most efficient way of using this project is to use it from user deps.edn:

```clojure
{...
 :aliases
 {...
  :new {:extra-deps {seancorfield/clj-new {:mvn/version "1.1.234"}}
        :exec-fn clj-new/create}
  ...}
...}
```
The above block shows adding a simple execution alias that takes the `clj-new` library
and executes the function `clj-new/create`. From that point we can use the `new` alias.
Let's create a new `app` project:
```bash
$ clj -X:new :template app :name example/myapp
Generating a project called myapp based on the 'app' template.
```

This time we used _`app`_ template as well. Besides `app`, `clj-new` supports templates:
`lib` and `template` (template to create a `clj-new` template - pretty cool, right?).

Generated project looks like that:

```shell
$ tree -a myapp                                                                                                                                                                                                                                                         !4035
myapp
├── .gitignore
├── .hgignore
├── CHANGELOG.md
├── LICENSE
├── README.md
├── deps.edn
├── doc
│   └── intro.md
├── pom.xml
├── resources
│   └── .keep
├── src
│   └── example
│       └── myapp.clj
└── test
    └── example
        └── myapp_test.clj

6 directories, 11 files
```

The heart of this project is `deps.edn` file:
```clj
{:paths ["src" "resources"]
 :deps {org.clojure/clojure {:mvn/version "1.10.1"}}
 :aliases
 {:run-m {:main-opts ["-m" "example.myapp"]}
  :run-x {:ns-default example.myapp
          :exec-fn greet
          :exec-args {:name "Clojure"}}
  :test {:extra-paths ["test"]
         :extra-deps {org.clojure/test.check {:mvn/version "1.1.0"}}}
  :runner
  {:extra-deps {com.cognitect/test-runner
                {:git/url "https://github.com/cognitect-labs/test-runner"
                 :sha "b6b3193fcc42659d7e46ecd1884a228993441182"}}
   :main-opts ["-m" "cognitect.test-runner"
               "-d" "test"]}
  :uberjar {:replace-deps {seancorfield/depstar {:mvn/version "2.0.165"}}
            :exec-fn hf.depstar/uberjar
            :exec-args {:aot true
                        :jar "myapp.jar"
                        :main-class "example.myapp"}}}}
```

If you look closer at the `:aliases` section you'll notice `:run-m` and `:run-x` positions.
They present two different ways of running the app using clj deps:
```shell
$ clj -M:run-m                                                                                                                                                                                                                                                          !4052
Hello, World!

$ clj -X:run-x                                                                                                                                                                                                                                                          !4053
Hello, Clojure!
```
There are two different responses.
If you are not familiar with clj deps,
this is a very nice example showing difference between running -m and -X aliases.
I encourage you to have a closer look at the `deps.edn` and main namespace.

This project is also setup to create uberjar. Let's build it:
```shell
$ clojure -X:uberjar
[main] INFO hf.depstar.uberjar - Compiling example.myapp ...
[main] INFO hf.depstar.uberjar - Building uber jar: myapp.jar
[main] INFO hf.depstar.uberjar - Processing pom.xml for {example/myapp {:mvn/version "0.1.0-SNAPSHOT"}}
```
Then let's run it:
```shell
$ java -jar myapp.jar
Hello, World!
```


## `boot-new`

A few year ago, before `deps` tooling has been released, the `boot` had been the main competitor to Leiningen.
I've never used it, still it also supports generation of project, based on Leiningen and Boot templates.
To find more about check [boot-new](https://github.com/boot-clj/boot-new) repo.


## More templates

In all the methods, besides the build-in templates,
it is possible to leverage all the templates published to Clojars. You can find them using these searches:
- [\<template-name\>/clj-template](https://clojars.org/search?q=artifact-id:clj-template)
- [\<template-name\>/lein-template](https://clojars.org/search?q=artifact-id:lein-template)
- [\<template-name\>/boot-template](https://clojars.org/search?q=artifact-id:boot-template)

Example:

Leiningen using 'duct' template:
```shell
lein new duct app
```

Boot useing 'provisdom-clj' template:
```shell
boot -d boot/new new -t provisdom-clj -n app
```

deps using 'electron-app' template
```shell
clj -X:new :template electron-app :name example/myapp
```

## Final words

You know now how to create and run a project.
With plethora of templates you can see how other people setup when you build something from scratch.
Similarly, like others did, you can create, publish your own templates and boost yours and others productivity.

Happy learning Clojure.

[github-clj-new]: https://github.com/seancorfield/clj-new

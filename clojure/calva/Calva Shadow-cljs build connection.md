> I can pick :app :node or :browser REPL what are the differences?

[gpt-4]

When you connect Calva to a Shadow-cljs REPL, you are faced with a choice of the type of REPL environment you would like to use. The options typically include `:app`, `:node`, or `:browser`, and they represent the different targets or environments where your ClojureScript can be executed. 

Here's a brief overview of what each option means:

1. `:app`: This is specific to the configuration in your `shadow-cljs.edn` file. If you have an `:app` build target defined there, it means you want to connect to the REPL associated with that particular build configuration. This could be for a browser, Node.js, or any other environment you’ve set up your `:app` target for. It's a custom build identifier, and you need to check your configuration for the specifics of what `:app` is in your case.

2. `:node`: This REPL is meant for Node.js environments. If you're working on a server-side application or any ClojureScript that is intended to run in a Node.js environment, you would choose this option. When you connect to a `:node` REPL, you're able to load and interact with your ClojureScript code as it would be executed by Node.js, and you can use Node-specific libraries and global objects.

3. `:browser`: This REPL connects you to a browser environment. It is meant for ClojureScript code that is intended to run in a web browser. If your project is a web application, you'll likely choose this option. When you're connected to a `:browser` REPL, you can interact with the Document Object Model (DOM), manipulate web pages, and use browser-specific APIs and functions.

In practice, when using Calva with Shadow-cljs, you’ll often:

1. Choose `:browser` for web applications, where you can evaluate code in the context of the actual page and utilize the browser’s JavaScript environment.
2. Choose `:node` for backend development if you are using ClojureScript with Node.js or developing an isomorphic application that shares code between the server and client.
3. Choose `:app` or other custom build identifiers for more structured or complex projects where the build target is defined according to specific needs that could include different platforms or optimizations.

When you choose the correct REPL type, Calva can better handle the tooling and utilities that are appropriate for that context, such as code completion, debugging, and evaluating ClojureScript code in the context of the running application.
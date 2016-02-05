# How to Read JavaScript Source Code

As a front-end engineer, I have to learn lots of new technologies to catch up with the requirement of my work. It's not easy to learn the latest technology for we have to:

1. Read English documentations for no translation. (It's not a good news for non-English speakers XD)
1. Read the source code for imperfect/no documentation.

But we have to face the music: learn the latest technology or go home. A penniless guy has no choice :b So I try to summarize some tricks to make it a little easier. I wrote an article about [*how to learn English*](https://github.com/benjycui/benjycui.github.io/issues/2), and this article is about how to read source code.

## Find the Entry File

The entry file is a good point to start reading. Here are some tricks about how to find the entry file.

Thanks to NPM, we could find a [package.json](https://docs.npmjs.com/files/package.json) in most of JavaScript Projects. And we may find the entry file of a project in the `main`(for CLI tools, it's `bin`) field of package.json.

But, not all of the JavaScript projects follow this convention. Some of package.json of those projects have no `main` field(e.g. [React](https://github.com/facebook/react/blob/master/package.json)), others' `main` fields point to an inexistent file(e.g. [jQuery](inexistent)). For those cases, we could try to find `script.build`(or something like that) in package.json. The command in `scripts.build` tell us how does this project build, and then, we can read source code in the order of building -- It isn't a good idea for reading source code, but we will learn a lot about how to structure code.

## Search the object/function name in repository

For JavaScript library, it's a good idea to read the implementation of API one by one. To find the implementation of API which you are interested in, just search the API name in repository. We could search in GitHub repository for open source project, or search with `grep` command in local code.

For example, I want to know [the implementation of `Ramda.cond`](https://github.com/ramda/ramda/blob/0ab0058360c618d572cc493299396bdee375dd79/src/cond.js). So, I search 'cond' in [Ramda's repository](https://github.com/ramda/ramda). Then, try to find the source code of `cond` in the result list(Experience is needed, I know).

## Use `console.error` to print call stack

Sometimes, I want to know the call stack of a framework, such as React. It's possibile to infer the call stack from source code after you read most of the code. But there is a smart way: use `console.error` to print call stack.

For example, I tried to understand the call stack of `ReactDOM.render`. So, I wrote this little demo and run:

```jsx
const Demo = React.createClass({
  render() {
    console.error('Hello world!');
    return <h1>Hello world!</h1>;
  }
});

ReactDOM.render(
  <Demo />,
  document.getElementById('container')
);
```

Then, I got the call stack from Chrome Developer Tools:

```bash
Hello world!
    (anonymous function)
    render
    ReactCompositeComponentMixin._renderValidatedComponentWithoutOwnerOrContext
    ReactCompositeComponentMixin._renderValidatedComponent
    wrapper
    ReactCompositeComponentMixin.mountComponent
    wrapper
    ...
```

Now, I can search the object/function name in React repository and read the implementation of it.

## Conclusion

This article are not going to be the general solution for reading every JavaScript project. So, it is normal to find those tricks don't work for some projects. But it will make reading source code a little easier :-)

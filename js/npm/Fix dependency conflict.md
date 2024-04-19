I couldn't install a `package.json` & the error message wasn't enough for me to understand the problem ...
```sh
❯ npm install
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR! 
npm ERR! While resolving: Cheffy@0.0.1
npm ERR! Found: react@17.0.2
npm ERR! node_modules/react
npm ERR!   react@"17.0.2" from the root project
npm ERR! 
npm ERR! Could not resolve dependency:
npm ERR! peer react@"^0.14.0 || ^15.0.0 || ^16.0.0" from react-highlight.js@1.0.7
npm ERR! node_modules/react-highlight.js
npm ERR!   dev react-highlight.js@"1.0.7" from the root project
npm ERR! 
npm ERR! Fix the upstream dependency conflict, or retry
npm ERR! this command with --force or --legacy-peer-deps
npm ERR! to accept an incorrect (and potentially broken) dependency resolution.
npm ERR! 
npm ERR! 
npm ERR! For a full report see:
npm ERR! /Users/rowanm/.npm/_logs/2024-02-15T12_32_00_470Z-eresolve-report.txt

npm ERR! A complete log of this run can be found in: /Users/rowanm/.npm/_logs/2024-02-15T12_32_00_470Z-debug-0.log
```

It turns out that `react-highlight.js@1.0.7` depends on `react@^15`  or  `react@^16` while I have specified `react@17.0.2` so I just have to remove `react-hightlight` & find a compatible version via `npm install react-highlight` ...

God this is a nightmare ...
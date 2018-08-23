
## HouseMates Contract


## Installation

1. Install Truffle globally.
    ```javascript
    npm install -g truffle
    ```
2. CD into your cloned directory. Run `npm install`

3. Run the development console.
    ```javascript
    truffle develop
    ```

4. Compile and migrate the smart contracts. Note inside the development console we don't preface commands with `truffle`.
    ```javascript
    compile
    migrate
    ```

IN A NEW COMMAND LINE-
5. Run the `liteserver` development server (outside the development console) for front-end hot reloading. Smart contract changes must be manually recompiled and migrated.
    ```javascript
    // Serves the front-end on http://localhost:3000
    npm run dev
    ```

 6. Install MetaMask - https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?hl=en

 7. In metamask, top left corner, Connect to your local blockchain server - http://127.0.0.1:9545/

 8. Get one of generated private keys from truffle develop. Use switch accounts on metamasm and add the private key from the truffle develop console.

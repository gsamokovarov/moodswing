     __  __  ____   ____  _____         _______          _______ _   _  _____ 
    |  \/  |/ __ \ / __ \|  __ \   _   / ____\ \        / /_   _| \ | |/ ____|
    | \  / | |  | | |  | | |  | | (_) | (___  \ \  /\  / /  | | |  \| | |  __ 
    | |\/| | |  | | |  | | |  | |      \___ \  \ \/  \/ /   | | | . ` | | |_ |
    | |  | | |__| | |__| | |__| |  _   ____) |  \  /\  /   _| |_| |\  | |__| |
    |_|  |_|\____/ \____/|_____/  (_) |_____/    \/  \/   |_____|_| \_|\_____|
    --------------------------------------------------------------------------
    Node.js testing framework for that time of the software development cycle.
    --------------------------------------------------------------------------

Overview
========

Moodswing uses CoffeeScript to provide assertions which can look like english sentences.

    expect(true).to be: true
    expect([]).to have: length: of: 0
    dontExpect(-> null).to raise: Error
    dontExpect('this').to be: equal: to: 'that'

This is possible because of the CoffeeScript object literal syntax. For example the line ``expect([]).to have: length: of: 0`` is equal to this call ``(new Expectation []).haveLengthOf(0)``.

This means that the object ``have: length: of: 0``, which from now on I would call a _directive_, is translated to a method named ``haveLengthOf`` using camel case notation. This method is then looked for in the ``Expectation.prototype`` and is being called with the _reminder_ of the object.

The ``Expectation`` constructor is publicly available, so you can augment its prototype with your own directives.

    Expectation::beInServerListenersFor = (event) ->
      assert.ok event in server.listeners(event)

    # ...

   expect(connectionHandler).to be: in: server: listeners: for: 'connection'

Installation
============

    npm install moodswing

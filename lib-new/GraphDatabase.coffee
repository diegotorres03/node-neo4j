$ = require 'underscore'
lib = require '../package.json'
Request = require 'request'
URL = require 'url'

module.exports = class GraphDatabase

    # Default HTTP headers:
    headers:
        'User-Agent': "node-neo4j/#{lib.version}"
        'X-Stream': 'true'

    constructor: (opts={}) ->
        if typeof opts is 'string'
            opts = {url: opts}

        {@url, @headers, @proxy} = opts

        if not @url
            throw new TypeError 'URL to Neo4j required'

        # TODO: Do we want to special-case User-Agent? Blacklist X-Stream?
        @headers or= {}
        $(@headers).defaults @constructor::headers

    http: (opts={}, cb) ->
        if typeof opts is 'string'
            opts = {path: opts}

        {method, path, headers, body, raw} = opts

        if not path
            throw new TypeError 'Path required'

        method or= 'GET'
        headers or= {}

        # TODO: Parse response body before calling back.
        # TODO: Do we need to do anything special to support streaming response?
        req = Request
            method: method
            url: URL.resolve @url, path
            headers: $(headers).defaults @headers
            json: body ? true
        , (err, resp) =>

            if err
                # TODO: Properly check error and transform to semantic instance.
                return cb err

            if raw
                # TODO: Do we want to return our own Response object?
                return cb null, resp

            {body, headers, statusCode} = resp

            if statusCode >= 500
                # TODO: Semantic errors.
                err = new Error "Neo4j #{statusCode} response"
                return cb err

            if statusCode >= 400
                # TODO: Semantic errors.
                err = new Error "Neo4j #{statusCode} response"
                return cb err

            # TODO: Parse nodes and relationships.
            return cb null, body

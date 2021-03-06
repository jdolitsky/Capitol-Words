class window.GoogleChart

    constructor: (@width, @height) ->
        @encoded = []
        @data = []
        @chg = ''
        @chf = ''
        @chco = ''
        @chdl = ''
        @chxl = []
        @chxp = []

    types: {'line': 'lc', }

    base_url: 'http://chart.apis.google.com/chart?'

    add_data: (values) ->
        @data.push values

    set_axis_labels: (index, labels) ->
        @chxl.push [index, labels]

    set_axis_positions: (index, positions) ->
        @chxp.push [index, positions]

    set_grid: (x_step, y_step, dash_length, space_length, x_offset, y_offset) ->
        @chg = x_step+ ',' + y_step + ',' +  dash_length + ',' + space_length + ',' +  x_offset + ',' + y_offset

    set_fill: (fill_type, s, color) ->
        @chf = fill_type + ',' + s + ',' + color        

    set_colors: (colors) ->
        @chco = colors.join(',')

    set_legend: (legend) ->
        @chdl = legend.join('|')

    chs: -> [@width, @height].join('x')
    cht: -> @types['line']
    chd: ->
        maxValue = @max _(@data).flatten()
        @encoding() + (@encode(values, maxValue) for values in @data).join(',')

    url: ->
        pieces = {
            'cht': @cht(),
            'chs': @chs(),
            'chd': @chd(),
            'chg': @chg,
            'chf': @chf,
            'chco': @chco,
            'chdlp': 't|l',
        }
        if (@chdl != '')
            pieces['chdl'] = @chdl

        if (@chxl)
            pieces['chxt'] = []
            pieces['chxl'] = []
            for axis_labels in @chxl
                [index, labels] = axis_labels
                pieces['chxl'].push(_i + ':|' + labels.join '|')
                pieces['chxt'].push index
            pieces['chxl'] = pieces['chxl'].join('|')
            pieces['chxt'] = pieces['chxt'].join ','

            if (@chxp)
                pieces['chxp'] = ''
                for axis_positions in @chxp
                    [index, positions] = axis_positions
                    index = {y: 0, x: 1}[index]
                    pieces['chxp'] = index + ',' + positions.join ','

        @base_url + ("#{key}=#{value}" for key, value of pieces).join('&')

    max: (values) ->
        Math.max.apply(Math, values)

    encoding: ->
        if @height > 100 then 'e:' else 's:'

    encode: (values, maxValue) ->
        if @height > 100 then @extendedEncode(values, maxValue) else @simpleEncode(values, maxValue)

    simpleEncoding: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

    simpleEncode: (values, maxValue) ->
        chartData = []
        for currentValue in values
            if not isNaN currentValue and currentValue >= 0
                val = Math.round ((@simpleEncoding.length - 1) * (currentValue / maxValue))
                chartData.push @simpleEncoding.charAt val
            else
                chartData.push '_'
        chartData.join ''

    extendedMap: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-.'

    extendedEncode: (values, maxValue) ->
        chartData = ''
        mapLength = @extendedMap.length
        for currentValue in values
            numericalVal = new Number currentValue
            scaledVal = Math.floor mapLength * mapLength * numericalVal / maxValue
            if scaledVal > (mapLength * mapLength) - 1
                chartData += '..'
            else if scaledVal < 0
                chartData += '__'
            else
                quotient = Math.floor scaledVal / mapLength
                remainder = scaledVal - mapLength * quotient
                chartData += @extendedMap.charAt(quotient) + @extendedMap.charAt(remainder)

        chartData

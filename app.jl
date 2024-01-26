using Oxygen
using HTTP
using Mustache

function render_html(htmlFile::String, cssFile::String, context::Dict = Dict(); status = 200, headers = ["Content-Type" => "text/html; charset=utf-8"]) :: HTTP.Response
    isContextEmpty = isempty(context)

    # Read HTML file
    io = open(htmlFile, "r") do file
        read(file, String)
    end
    template = isContextEmpty ? io |> String : String(Mustache.render(io, context))

    # Read CSS file
    css = ""
    if !isempty(cssFile)
        css_io = open(cssFile, "r") do file
            read(file, String)
        end
        css = "<style>$css_io</style>"
    end

    # Combine HTML and CSS
    template = "<html><head>$css</head><body>$template</body></html>"

    return HTTP.Response(status, headers, body = template)
end


function generate_password(length::Int)
    # Generate a random password of the specified length
    password = ""

    for i in 1:length
        # Generate a random character from the set of allowed characters
        char = rand(('a':'z') ∪ ('A':'Z') ∪ ('0':'9') ∪ ('!', '@', '#', '$', '%', '^', '&', '*', '?'))
        password *= char
    end

    return password
end

@get "/" function(req::HTTP.Request)
    form_data = queryparams(req)
    phrase = get(form_data, "phrase", "")
    password_length = get(form_data, "password_length", "0")
    password = generate_password(parse(Int, password_length))
    results = join([phrase, password], "")
    context = Dict("phrase" => phrase, "results" => results)

    return render_html("index.html", "pico.css", context)
end

serve(port=8001)
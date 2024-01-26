using Oxygen
using HTTP
using Mustache

function render_html(htmlFile::String, context::Dict = Dict(); status = 200, headers = ["Content-Type" => "text/html; charset=utf-8"]) :: HTTP.Response
    isContextEmpty = isempty(context) === true

    # Return raw HTML without context
    if isContextEmpty
        io = open(htmlFile, "r") do file
            read(file, String)
        end
        template = io |> String

    # Return HTML with context
    else
        io = open(htmlFile, "r") do file
            read(file, String)
        end
        template = String(Mustache.render(io, context))
    end
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
    return "Hello Julia Web App"
end

@get "/generate" function(req::HTTP.Request)
    form_data = queryparams(req)
    phrase = get(form_data, "phrase", "")
    password_length = get(form_data, "password_length", "0")
    password = generate_password(parse(Int, password_length))
    results = join([phrase, password], "")
    context = Dict("phrase" => phrase, "results" => results)

    return render_html("generate_password.html", context)
end

serve(port=8001)
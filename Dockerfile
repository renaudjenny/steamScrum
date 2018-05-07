FROM swift:4.1

WORKDIR /app

COPY . /app

CMD swift build
CMD swift run Run serve --hostname 0.0.0.0

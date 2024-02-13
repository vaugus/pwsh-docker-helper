FROM alpine:latest

RUN addgroup -g 1000 fibonacci
RUN adduser -u 1000 -G fibonacci --disabled-password fibonacci

RUN apk add powershell

COPY ./fibonacci.ps1 /home/fibonacci/fibonacci.ps1

WORKDIR /home/fibonacci

USER fibonacci:fibonacci

CMD pwsh fibonacci.ps1 "${NUMBER}"

# Mini Ping

A simple utility to check if a host is reachable on the network.

## Motivation

Trying to discover if a host is available on the local network can be tricky if you want to use the `ping` utility that is shipped with windows. If you try to ping a host on the local network, the exit code will always be 0 (Success), regardless of the hosts existance. Parsing the output can become a real hassle if you have to support multiple languages since the output depends on the locale settings.

This small utility will tell you via exit code if a host is really reachable or not.

## Usage

```
$ MiniPing.exe

MiniPing - A minimal ping program

ExitCodes:
  0: Host is reachable
  1: Host is not reachable
  2: An exception occured
```

To ping a host, add the hostname or IP Address:

```
$ MiniPing.exe 127.0.0.1
Received Response in 0 ms
```


## Acknowledgements

This work is more or less inspired by two code snippets I found on the internet:

* [ICMP-Echo-API ("Ping") Wrapper-Unit v1.04 (german)](https://www.entwickler-ecke.de/topic_ICMPEchoAPI+quotPingquot+WrapperUnit+v104_53259,0.html)
* [How to ping an IP address in Delphi 10.1 without using Indy components?](https://stackoverflow.com/questions/43667816/how-to-ping-an-ip-address-in-delphi-10-1-without-using-indy-components)

I didn't use them, because their use case was much too heavy for the application or the used api is deprecated.

## TODOs

Maybe: Adding a customizable timeout

## Contributing

If you want to contribute, please don't hesitate to open a pull request. If you have any questions, please ask them in a issue.

## License

This project is licensed under the [MIT License](LICENSE).

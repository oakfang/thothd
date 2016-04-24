# Thoth Server

Run the [Thoth](https://github.com/oakfang/thoth) DB as a TCP server.

## Installation

- Git clone
- `mix deps.get` from project dir

## Usage

Run `mix run --no-halt` from the project directory. This starts an instance running on port `4040`.

### Connect to DB

Send `USE <ABSOLUTE_DB_PATH>` to the server.

### Load models

Send `REQUIRE <ABSOLUTE_PATH>` where the absolute path is a path to an elixir file that defines models.
Models should `derive` both Thoth.Model (a must) and Poison.Encoder (increased performance).

### Do stuff!

From here on, just send Elixir code over the wire, using `graph` as the global representing the instance.

Example:

```elixir
Thoth.Query.query(
  graph, 
  :alex_russell,
  [:friends, :friends]
) |> Enum.reduce(%{}, fn vid, acc -> Map.put(acc, vid, Thoth.Entities.get_vertex(graph, vid)) end)
```


## Sample client

A simple python client can be written as such:

```python
from socket import socket
from json import loads

class Thoth(object):
    def __init__(self, host='localhost', port=4040):
        self.conn = socket()
        self.conn.connect((host, port))

    def use(self, db_path):
        self.conn.send('USE {}'.format(db_path))
        assert self.conn.recv(4096) == 'OK'

    def require(self, path):
        self.conn.send('REQUIRE {}'.format(path))
        assert self.conn.recv(4096) == 'OK'

    def execute(self, command):
        self.conn.send(command)
        return loads(self.conn.recv(4096))
```
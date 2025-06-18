# zig-dollar-exchange-rate

## How to Build and Run

1. **Build the project:**
   ```sh
   zig build
   ```

2. **Run the executable:**
   ```sh
   zig-out/bin/zig_cli_exchange <amount_in_usd>
   ```
   Replace `<amount_in_usd>` with the amount you want to convert, for example:
   ```sh
   zig-out/bin/zig_cli_exchange 10
   ```

This will fetch the current USD to BRL exchange rate and print the converted value. Make sure you have an internet connection and that `curl` is installed, as the program uses it to fetch exchange rates over HTTPS.

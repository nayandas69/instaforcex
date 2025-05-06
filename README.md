# InstaForceX

A powerful, fast, and simple Instagram brute-force tool written in Bash by [Nayan Das](https://github.com/nayandas69).

> [!WARNING]  
> **For Educational Use Only** – This tool is intended strictly for **ethical testing, research, and educational purposes**. Misuse may lead to legal consequences. Use responsibly.

## Features

* [x] Resume session support  
* [x] Tor integration for anonymity  
* [x] Password rotation with IP change  
* [x] Colored terminal output for readability  
* [x] Auto session saving on Ctrl+C  
* [x] Username validity check  
* [x] Support for custom or default wordlists  
* [ ] Proxy rotation (Planned)  
* [ ] Multi-device fingerprint spoofing (Planned)

## Installation

```bash
git clone https://github.com/nayandas69/instaforcex.git
cd instaforcex
chmod +x instaforcex.sh
./instaforcex.sh
````

## Requirements

Ensure the following dependencies are installed:

* `openssl`
* `curl`
* `tor`
* `awk`
* `sed`
* `cut`
* `tr`
* `uniq`
* `cat`
* `wc`

On Debian/Ubuntu/Kali, install them with:

```bash
sudo apt install openssl curl tor coreutils
```

> \[!NOTE]
> You must start the Tor service before running the script:
>
> ```bash
> sudo service tor start
> ```

## Wordlist

You can provide your own wordlist or use the default one located at `wordlists/passwords.lst`.

> \[!IMPORTANT]
> The quality of your wordlist significantly impacts success. Use realistic and well-curated password lists.

## Resuming Sessions

If the process is interrupted (e.g., with Ctrl+C), you'll be prompted to save the session.

To resume a saved session:

```bash
./instaforcex.sh --resume
```

> \[!TIP]
> All saved sessions are stored in the `sessions/` directory.

## Output

Successful credentials or challenge detections are saved to:

```
found/instaforcex.found
```

## Example Usage

```bash
./instaforcex.sh
```

1. Enter Instagram username
2. Provide a path to a wordlist (or press Enter to use the default)
3. Choose thread count (1–20)

## Legal Disclaimer

> \[!WARNING]
> This tool is intended for **educational and authorized testing only**.
> You are solely responsible for any misuse.
> By using InstaForceX, you agree not to use it for illegal purposes.

## Contributing
Contributions are welcome! If you have suggestions or improvements, please fork the repository and submit a pull request.

## Author

Nayan Das - [@nayandas69](https://github.com/nayandas69)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
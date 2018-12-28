<h3 align='center'>headless</h3>
<h4 align='center'> 
To setup and launch your VirtualBox VM with ssh, and without leaving your trusty terminal.
</h4>

<br />
<p align='center'>
<img src="https://audio-sequence.github.io/headless_lower.gif" width="80%">
</p>
<br />

#### What does it do ?
- Setup a new VM the first time you run it. Stores its details in `~/.headless`
- SSH automatically, if the VM is already setup and running. And if not it will do that.
- `./headless.sh --stop` if you're too lazy to ssh and `shutdown -h`